Set-StrictMode -Version Latest

function Add-UpdateManifestFinding {
    param(
        [Parameter(Mandatory = $true)][string] $Id,
        [Parameter(Mandatory = $true)][string] $Severity,
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][string] $Message
    )

    return [pscustomobject]@{
        id = $Id
        severity = $Severity
        path = $Path
        message = $Message
    }
}

function Get-UpdateManifestArray {
    param(
        [Parameter(Mandatory = $true)][object] $Object,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        return @()
    }

    return @($property.Value)
}

function Get-UpdateManifestValue {
    param(
        [Parameter(Mandatory = $true)][object] $Object,
        [Parameter(Mandatory = $true)][string] $Name,
        [AllowNull()][object] $Default = $null
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $Default
    }

    return $property.Value
}

function Read-UpdateManifestPolicy {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Update manifest policy not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Test-UpdateManifestUnsafeText {
    param([AllowNull()][object] $Value)

    $text = [string]$Value
    return $text -match '(?i)^https?://|authorization|bearer|cookie|token|secret|password|client_secret|AppData|Local Storage|IndexedDB|\.db|\.log|logs|crash|dump'
}

function Test-UpdateManifestRelativePath {
    param([AllowNull()][object] $Value)

    $text = [string]$Value
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $false
    }
    if ($text -match '^[A-Za-z]:\\|^\\\\|^\.\.|/\.\.|\\\.\.|^https?://') {
        return $false
    }
    return $text -match '^[a-zA-Z0-9_./-]+$'
}

function Test-UpdateManifestPolicy {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Policy,

        [switch] $DryRun
    )

    $findings = @()
    $checks = @()

    $policyChecks = @(
        @{ Name = 'dryRunFlag'; Passed = [bool]$DryRun; Id = 'dry-run-flag-required'; Message = 'Update manifest gate must be invoked with -DryRun.' },
        @{ Name = 'dryRunOnly'; Passed = (Get-UpdateManifestValue -Object $Policy -Name 'dryRunOnly' -Default $false) -eq $true; Id = 'policy-not-dry-run-only'; Message = 'Update manifest gate must be dry-run only.' },
        @{ Name = 'networkDisabled'; Passed = (Get-UpdateManifestValue -Object $Policy -Name 'networkDisabled' -Default $false) -eq $true; Id = 'network-not-disabled'; Message = 'Update manifest gate must not download manifests or packages.' },
        @{ Name = 'executionDisabled'; Passed = (Get-UpdateManifestValue -Object $Policy -Name 'executionDisabled' -Default $false) -eq $true; Id = 'execution-not-disabled'; Message = 'Update manifest gate must not run updater or installer actions.' },
        @{ Name = 'rollbackDisabled'; Passed = (Get-UpdateManifestValue -Object $Policy -Name 'rollbackDisabled' -Default $false) -eq $true; Id = 'rollback-not-disabled'; Message = 'Update rollback execution must stay disabled.' },
        @{ Name = 'credentialsDisabled'; Passed = (Get-UpdateManifestValue -Object $Policy -Name 'credentialsDisabled' -Default $false) -eq $true; Id = 'credentials-not-disabled'; Message = 'Update manifest gate must not use credentials.' }
    )

    foreach ($policyCheck in $policyChecks) {
        $checks += [pscustomobject]@{
            type = 'policy-safety'
            name = $policyCheck.Name
            passed = $policyCheck.Passed
        }
        if (-not $policyCheck.Passed) {
            $findings += Add-UpdateManifestFinding -Id $policyCheck.Id -Severity 'fail' -Path '<policy>' -Message $policyCheck.Message
        }
    }

    foreach ($endpoint in @(Get-UpdateManifestArray -Object $Policy -Name 'endpoints')) {
        if (Test-UpdateManifestUnsafeText -Value $endpoint) {
            $findings += Add-UpdateManifestFinding -Id 'unsafe-endpoint' -Severity 'fail' -Path '<policy>' -Message 'Update manifest gate must not define real or production endpoints.'
        }
    }

    foreach ($command in @(Get-UpdateManifestArray -Object $Policy -Name 'commands')) {
        if (-not [string]::IsNullOrWhiteSpace([string]$command)) {
            $findings += Add-UpdateManifestFinding -Id 'command-defined' -Severity 'fail' -Path '<policy>' -Message 'Update manifest gate must not define executable commands.'
        }
    }

    $packages = @(Get-UpdateManifestArray -Object $Policy -Name 'packages')
    if ($packages.Count -eq 0) {
        $findings += Add-UpdateManifestFinding -Id 'missing-packages' -Severity 'fail' -Path '<policy>' -Message 'Update manifest policy must define at least one package entry.'
    }

    foreach ($package in $packages) {
        $id = [string](Get-UpdateManifestValue -Object $package -Name 'id' -Default '<unnamed>')
        $path = "packages/$id"
        $version = [string](Get-UpdateManifestValue -Object $package -Name 'version' -Default '')
        $artifactPath = [string](Get-UpdateManifestValue -Object $package -Name 'artifactPath' -Default '')
        $sha256 = [string](Get-UpdateManifestValue -Object $package -Name 'sha256' -Default '')
        $sizeBytes = [int64](Get-UpdateManifestValue -Object $package -Name 'sizeBytes' -Default 0)
        $signatureRequired = (Get-UpdateManifestValue -Object $package -Name 'signatureRequired' -Default $false) -eq $true
        $rollbackAllowed = (Get-UpdateManifestValue -Object $package -Name 'rollbackAllowed' -Default $true) -eq $true
        $postInstallCommand = [string](Get-UpdateManifestValue -Object $package -Name 'postInstallCommand' -Default '')

        $checks += [pscustomobject]@{
            type = 'update-manifest-package'
            id = $id
            version = $version
            artifactPath = $artifactPath
            passed = (
                $id -match '^[a-z][a-z0-9.-]*$' -and
                $version -match '^\d+\.\d+\.\d+([.-][a-zA-Z0-9]+)?$' -and
                (Test-UpdateManifestRelativePath -Value $artifactPath) -and
                $sha256 -match '^[a-fA-F0-9]{64}$' -and
                $sizeBytes -gt 0 -and
                $signatureRequired -and
                -not $rollbackAllowed -and
                [string]::IsNullOrWhiteSpace($postInstallCommand)
            )
        }

        if ($id -notmatch '^[a-z][a-z0-9.-]*$') {
            $findings += Add-UpdateManifestFinding -Id 'invalid-package-id' -Severity 'fail' -Path $path -Message 'Package id must be a stable lower-case identifier.'
        }
        if ($version -notmatch '^\d+\.\d+\.\d+([.-][a-zA-Z0-9]+)?$') {
            $findings += Add-UpdateManifestFinding -Id 'invalid-version' -Severity 'fail' -Path $path -Message 'Package version must be explicit semantic-like version metadata.'
        }
        if (-not (Test-UpdateManifestRelativePath -Value $artifactPath)) {
            $findings += Add-UpdateManifestFinding -Id 'unsafe-artifact-path' -Severity 'fail' -Path $path -Message 'Package artifactPath must be a local relative path, not an absolute path or URL.'
        }
        if ($sha256 -notmatch '^[a-fA-F0-9]{64}$') {
            $findings += Add-UpdateManifestFinding -Id 'invalid-sha256' -Severity 'fail' -Path $path -Message 'Package sha256 must be a 64-character hex digest.'
        }
        if ($sizeBytes -le 0) {
            $findings += Add-UpdateManifestFinding -Id 'invalid-size' -Severity 'fail' -Path $path -Message 'Package sizeBytes must be positive.'
        }
        if (-not $signatureRequired) {
            $findings += Add-UpdateManifestFinding -Id 'signature-not-required' -Severity 'fail' -Path $path -Message 'Package signatureRequired must be true.'
        }
        if ($rollbackAllowed) {
            $findings += Add-UpdateManifestFinding -Id 'rollback-allowed' -Severity 'fail' -Path $path -Message 'Rollback execution must not be allowed by this gate.'
        }
        if (-not [string]::IsNullOrWhiteSpace($postInstallCommand)) {
            $findings += Add-UpdateManifestFinding -Id 'post-install-command-defined' -Severity 'fail' -Path $path -Message 'Post-install commands must not be defined in dry-run manifest validation.'
        }
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'UpdateManifest'
        dryRun = [bool]$DryRun
        networkCallAttempted = $false
        updaterStarted = $false
        rollbackAttempted = $false
        credentialsUsed = $false
        passed = ($failFindings.Count -eq 0)
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-UpdateManifestPolicy, `
    Test-UpdateManifestPolicy
