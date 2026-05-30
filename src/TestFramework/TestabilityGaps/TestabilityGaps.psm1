Set-StrictMode -Version Latest

function Add-TestabilityGapFinding {
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

function Get-TestabilityGapArray {
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

function Get-TestabilityGapValue {
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

function Read-TestabilityGapsPolicy {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Testability gaps policy not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Test-TestabilityGapsPolicy {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Policy,

        [switch] $DryRun
    )

    $findings = @()
    $checks = @()
    $allowedStatuses = @('open', 'blocked', 'needs-owner-input', 'deferred')
    $allowedAreas = @('client-launch', 'webview-runtime', 'auth', 'backend', 'game-session', 'update-runtime', 'fake-replay-lab', 'hardware-lab', 'release-artifact')
    $allowedRequiredEvidence = @('source-code', 'offline-fixture', 'sanitized-artifact-report', 'owner-approval', 'non-prod-environment', 'synthetic-user-config')

    $policyChecks = @(
        @{ Name = 'dryRunFlag'; Passed = [bool]$DryRun; Id = 'dry-run-flag-required'; Message = 'Testability gaps validator must be invoked with -DryRun.' },
        @{ Name = 'dryRunOnly'; Passed = (Get-TestabilityGapValue -Object $Policy -Name 'dryRunOnly' -Default $false) -eq $true; Id = 'policy-not-dry-run-only'; Message = 'Testability gaps policy must be dry-run only.' },
        @{ Name = 'productionExecutionDisabled'; Passed = (Get-TestabilityGapValue -Object $Policy -Name 'productionExecutionDisabled' -Default $false) -eq $true; Id = 'production-execution-not-disabled'; Message = 'Testability gaps policy must disable production execution.' },
        @{ Name = 'runtimeDataReadsDisabled'; Passed = (Get-TestabilityGapValue -Object $Policy -Name 'runtimeDataReadsDisabled' -Default $false) -eq $true; Id = 'runtime-data-read-not-disabled'; Message = 'Testability gaps policy must not require AppData/log/cookie/DB/dump reads.' },
        @{ Name = 'credentialsDisabled'; Passed = (Get-TestabilityGapValue -Object $Policy -Name 'credentialsDisabled' -Default $false) -eq $true; Id = 'credentials-not-disabled'; Message = 'Testability gaps policy must not require credentials.' }
    )

    foreach ($policyCheck in $policyChecks) {
        $checks += [pscustomobject]@{
            type = 'policy-safety'
            name = $policyCheck.Name
            passed = $policyCheck.Passed
        }
        if (-not $policyCheck.Passed) {
            $findings += Add-TestabilityGapFinding -Id $policyCheck.Id -Severity 'fail' -Path '<policy>' -Message $policyCheck.Message
        }
    }

    $gaps = @(Get-TestabilityGapArray -Object $Policy -Name 'gaps')
    if ($gaps.Count -eq 0) {
        $findings += Add-TestabilityGapFinding -Id 'missing-gaps' -Severity 'fail' -Path '<policy>' -Message 'Testability gaps policy must define at least one gap.'
    }

    foreach ($gap in $gaps) {
        $id = [string](Get-TestabilityGapValue -Object $gap -Name 'id' -Default '<unnamed>')
        $path = "gaps/$id"
        $area = [string](Get-TestabilityGapValue -Object $gap -Name 'area' -Default '')
        $status = [string](Get-TestabilityGapValue -Object $gap -Name 'status' -Default '')
        $productionSafeNow = (Get-TestabilityGapValue -Object $gap -Name 'productionSafeNow' -Default $true) -eq $true
        $requiresRuntime = (Get-TestabilityGapValue -Object $gap -Name 'requiresRuntime' -Default $true) -eq $true
        $requiresCredentials = (Get-TestabilityGapValue -Object $gap -Name 'requiresCredentials' -Default $true) -eq $true
        $requiresUserData = (Get-TestabilityGapValue -Object $gap -Name 'requiresUserData' -Default $true) -eq $true
        $requiredEvidence = @(Get-TestabilityGapArray -Object $gap -Name 'requiredEvidence')
        $stopTriggers = @(Get-TestabilityGapArray -Object $gap -Name 'stopTriggers')
        $nextSafeStep = [string](Get-TestabilityGapValue -Object $gap -Name 'nextSafeStep' -Default '')

        $evidenceAllowed = $requiredEvidence.Count -gt 0 -and @($requiredEvidence | Where-Object { -not ($allowedRequiredEvidence -contains [string]$_) }).Count -eq 0
        $hasStopTrigger = $stopTriggers.Count -gt 0

        $checks += [pscustomobject]@{
            type = 'testability-gap'
            id = $id
            area = $area
            status = $status
            passed = (
                $id -match '^GAP-[0-9]{3}$' -and
                $allowedAreas -contains $area -and
                $allowedStatuses -contains $status -and
                -not $productionSafeNow -and
                -not $requiresCredentials -and
                -not $requiresUserData -and
                $evidenceAllowed -and
                $hasStopTrigger -and
                -not [string]::IsNullOrWhiteSpace($nextSafeStep)
            )
        }

        if ($id -notmatch '^GAP-[0-9]{3}$') {
            $findings += Add-TestabilityGapFinding -Id 'invalid-gap-id' -Severity 'fail' -Path $path -Message 'Gap id must use GAP-### format.'
        }
        if (-not ($allowedAreas -contains $area)) {
            $findings += Add-TestabilityGapFinding -Id 'invalid-area' -Severity 'fail' -Path $path -Message 'Gap area is not recognized.'
        }
        if (-not ($allowedStatuses -contains $status)) {
            $findings += Add-TestabilityGapFinding -Id 'invalid-status' -Severity 'fail' -Path $path -Message 'Gap status is not recognized.'
        }
        if ($productionSafeNow) {
            $findings += Add-TestabilityGapFinding -Id 'gap-marked-production-safe' -Severity 'fail' -Path $path -Message 'Open runtime/testability gaps must not be marked productionSafeNow.'
        }
        if ($requiresCredentials) {
            $findings += Add-TestabilityGapFinding -Id 'gap-requires-credentials' -Severity 'fail' -Path $path -Message 'Gap tracking must not require credentials.'
        }
        if ($requiresUserData) {
            $findings += Add-TestabilityGapFinding -Id 'gap-requires-user-data' -Severity 'fail' -Path $path -Message 'Gap tracking must not require user runtime data.'
        }
        if (-not $evidenceAllowed) {
            $findings += Add-TestabilityGapFinding -Id 'invalid-required-evidence' -Severity 'fail' -Path $path -Message 'Gap must list approved evidence needed to close it.'
        }
        if (-not $hasStopTrigger) {
            $findings += Add-TestabilityGapFinding -Id 'missing-stop-trigger' -Severity 'fail' -Path $path -Message 'Gap must list stop-and-ask triggers.'
        }
        if ([string]::IsNullOrWhiteSpace($nextSafeStep)) {
            $findings += Add-TestabilityGapFinding -Id 'missing-next-safe-step' -Severity 'fail' -Path $path -Message 'Gap must list a safe next step.'
        }
        if ($requiresRuntime -and -not $hasStopTrigger) {
            $findings += Add-TestabilityGapFinding -Id 'runtime-gap-without-stop-trigger' -Severity 'fail' -Path $path -Message 'Runtime gaps must have explicit stop triggers.'
        }
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'TestabilityGaps'
        dryRun = [bool]$DryRun
        productionActionAttempted = $false
        credentialsUsed = $false
        runtimeUserDataRead = $false
        passed = ($failFindings.Count -eq 0)
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-TestabilityGapsPolicy, `
    Test-TestabilityGapsPolicy
