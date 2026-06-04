Set-StrictMode -Version Latest

function Add-AppSmokeFinding {
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

function ConvertTo-AppSmokeRelativePath {
    param([Parameter(Mandatory = $true)][string] $Path)

    return ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Get-AppSmokePolicyArray {
    param(
        [Parameter(Mandatory = $true)][object] $Policy,
        [Parameter(Mandatory = $true)][string] $Name
    )

    $property = $Policy.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) {
        return @()
    }

    return @($property.Value)
}

function Read-AppWebViewSmokePolicy {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "App/WebView smoke policy not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Test-AppWebViewSmokeArtifact {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ArtifactRoot,

        [Parameter(Mandatory = $true)]
        [object] $Policy,

        [switch] $DryRun
    )

    if (-not (Test-Path -LiteralPath $ArtifactRoot -PathType Container)) {
        throw "Artifact root not found: $ArtifactRoot"
    }

    $findings = @()
    $checks = @()

    if (-not $DryRun) {
        $findings += Add-AppSmokeFinding -Id 'dry-run-flag-required' -Severity 'fail' -Path '<runner>' -Message 'M2 App/WebView smoke validator requires the dry-run flag.'
    }

    $dryRunOnlyProperty = $Policy.PSObject.Properties['dryRunOnly']
    $dryRunOnly = $null -ne $dryRunOnlyProperty -and $dryRunOnlyProperty.Value -eq $true
    $checks += [pscustomobject]@{
        type = 'policy-safety'
        name = 'dryRunOnly'
        passed = $dryRunOnly
    }
    if (-not $dryRunOnly) {
        $findings += Add-AppSmokeFinding -Id 'policy-not-dry-run-only' -Severity 'fail' -Path '<policy>' -Message 'M2 App/WebView smoke policy must be dry-run only.'
    }

    foreach ($argument in (Get-AppSmokePolicyArray -Policy $Policy -Name 'launchArguments')) {
        $argumentText = [string]$argument
        if ($argumentText -match '--remote-debugging-port|--auto-open-devtools-for-tabs|--enable-logging|auth|token|session|game') {
            $findings += Add-AppSmokeFinding -Id 'unsafe-launch-argument' -Severity 'fail' -Path '<policy>' -Message 'M2 App/WebView smoke policy contains an unsafe launch argument.'
        }
    }

    foreach ($runtimePath in (Get-AppSmokePolicyArray -Policy $Policy -Name 'runtimePaths')) {
        $runtimePathText = [string]$runtimePath
        if ($runtimePathText -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump') {
            $findings += Add-AppSmokeFinding -Id 'unsafe-runtime-path' -Severity 'fail' -Path '<policy>' -Message 'M2 App/WebView smoke policy must not read user runtime paths, logs, cookies or dumps.'
        }
    }

    foreach ($relativePath in @($Policy.requiredFiles)) {
        $normalized = ConvertTo-AppSmokeRelativePath -Path ([string]$relativePath)
        $path = Join-Path $ArtifactRoot $normalized
        $exists = Test-Path -LiteralPath $path -PathType Leaf
        $checks += [pscustomobject]@{
            type = 'required-file'
            path = [string]$relativePath
            passed = $exists
        }
        if (-not $exists) {
            $findings += Add-AppSmokeFinding -Id 'missing-required-file' -Severity 'fail' -Path ([string]$relativePath) -Message 'Required app smoke artifact file is missing.'
        }
    }

    foreach ($bundle in @($Policy.webViewBundles)) {
        $bundleName = [string]$bundle.name
        $bundleRoot = ConvertTo-AppSmokeRelativePath -Path ([string]$bundle.path)
        $bundleRootPath = Join-Path $ArtifactRoot $bundleRoot
        if (-not (Test-Path -LiteralPath $bundleRootPath -PathType Container)) {
            $checks += [pscustomobject]@{
                type = 'webview-bundle'
                name = $bundleName
                path = [string]$bundle.path
                passed = $false
            }
            $findings += Add-AppSmokeFinding -Id 'missing-webview-bundle' -Severity 'fail' -Path ([string]$bundle.path) -Message "WebView bundle '$bundleName' is missing."
            continue
        }

        foreach ($entrypoint in @($bundle.requiredFiles)) {
            $relative = Join-Path $bundleRoot (ConvertTo-AppSmokeRelativePath -Path ([string]$entrypoint))
            $path = Join-Path $ArtifactRoot $relative
            $exists = Test-Path -LiteralPath $path -PathType Leaf
            $checks += [pscustomobject]@{
                type = 'webview-entrypoint'
                name = $bundleName
                path = ($relative -replace '\\', '/')
                passed = $exists
            }
            if (-not $exists) {
                $findings += Add-AppSmokeFinding -Id 'missing-webview-entrypoint' -Severity 'fail' -Path ($relative -replace '\\', '/') -Message "WebView bundle '$bundleName' is missing a required entrypoint."
            }
        }

        $manifestRelative = Join-Path $bundleRoot 'asset-manifest.json'
        $manifestPath = Join-Path $ArtifactRoot $manifestRelative
        if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
            try {
                $manifest = Get-Content -LiteralPath $manifestPath -Raw -ErrorAction Stop | ConvertFrom-Json
                foreach ($key in @($bundle.requiredManifestKeys)) {
                    $property = $manifest.files.PSObject.Properties[[string]$key]
                    $present = $null -ne $property -and -not [string]::IsNullOrWhiteSpace([string]$property.Value)
                    $checks += [pscustomobject]@{
                        type = 'manifest-key'
                        name = $bundleName
                        path = ($manifestRelative -replace '\\', '/')
                        key = [string]$key
                        passed = $present
                    }
                    if (-not $present) {
                        $findings += Add-AppSmokeFinding -Id 'missing-manifest-key' -Severity 'fail' -Path ($manifestRelative -replace '\\', '/') -Message "WebView bundle '$bundleName' manifest is missing key '$key'."
                    }
                }
            }
            catch {
                $findings += Add-AppSmokeFinding -Id 'invalid-asset-manifest' -Severity 'fail' -Path ($manifestRelative -replace '\\', '/') -Message "WebView bundle '$bundleName' asset manifest could not be parsed."
            }
        }
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'AppWebViewSmoke'
        artifactRoot = $ArtifactRoot
        dryRun = [bool]$DryRun
        launchedClient = $false
        processStarted = $false
        enabledWebViewDebugPort = $false
        debugPortUsed = $false
        authAttempted = $false
        gameSessionStarted = $false
        passed = ($failFindings.Count -eq 0)
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-AppWebViewSmokePolicy, `
    Test-AppWebViewSmokeArtifact
