Set-StrictMode -Version Latest

function Add-GameSessionCanaryFinding {
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

function Get-GameSessionCanaryArray {
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

function Get-GameSessionCanaryValue {
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

function Read-GameSessionCanaryPlan {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Game-session canary plan not found: $Path"
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Read-AllowedGamesConfig {
    param([Parameter(Mandatory = $true)][string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Allowed games config not found: $Path"
    }

    $data = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if ($null -eq $data.allowedGames) {
        throw "Allowed games config must contain a top-level 'allowedGames' array: $Path"
    }

    return @($data.allowedGames)
}

function Test-GameSessionCanaryPlan {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Plan,

        [Parameter(Mandatory = $true)]
        [object[]] $AllowedGames,

        [Parameter(Mandatory = $true)]
        [object] $ResourceBudget,

        [switch] $DryRun
    )

    $findings = @()
    $checks = @()

    $dryRunOnly = (Get-GameSessionCanaryValue -Object $Plan -Name 'dryRunOnly' -Default $false) -eq $true
    $executionDisabled = (Get-GameSessionCanaryValue -Object $Plan -Name 'executionDisabled' -Default $false) -eq $true
    $clientLaunchDisabled = (Get-GameSessionCanaryValue -Object $Plan -Name 'clientLaunchDisabled' -Default $false) -eq $true
    $networkDisabled = (Get-GameSessionCanaryValue -Object $Plan -Name 'networkDisabled' -Default $false) -eq $true
    $authDisabled = (Get-GameSessionCanaryValue -Object $Plan -Name 'authDisabled' -Default $false) -eq $true
    $dryRunFlagProvided = [bool]$DryRun

    foreach ($policyCheck in @(
        @{ Name = 'dryRunFlag'; Passed = $dryRunFlagProvided; Id = 'dry-run-flag-required'; Message = 'M5 readiness gate must be invoked with the dry-run flag.' },
        @{ Name = 'dryRunOnly'; Passed = $dryRunOnly; Id = 'policy-not-dry-run-only'; Message = 'M5 readiness gate must be dry-run only.' },
        @{ Name = 'executionDisabled'; Passed = $executionDisabled; Id = 'execution-not-disabled'; Message = 'M5 readiness gate must disable real game-session execution.' },
        @{ Name = 'clientLaunchDisabled'; Passed = $clientLaunchDisabled; Id = 'client-launch-not-disabled'; Message = 'M5 readiness gate must not launch the installed client.' },
        @{ Name = 'networkDisabled'; Passed = $networkDisabled; Id = 'network-not-disabled'; Message = 'M5 readiness gate must not call production backend or streaming services.' },
        @{ Name = 'authDisabled'; Passed = $authDisabled; Id = 'auth-not-disabled'; Message = 'M5 readiness gate must not authenticate or use credentials.' }
    )) {
        $checks += [pscustomobject]@{
            type = 'policy-safety'
            name = $policyCheck.Name
            passed = $policyCheck.Passed
        }
        if (-not $policyCheck.Passed) {
            $findings += Add-GameSessionCanaryFinding -Id $policyCheck.Id -Severity 'fail' -Path '<policy>' -Message $policyCheck.Message
        }
    }

    foreach ($runtimePath in @(Get-GameSessionCanaryArray -Object $Plan -Name 'runtimePaths')) {
        $runtimePathText = [string]$runtimePath
        if ($runtimePathText -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump|Local Storage|IndexedDB|\.db') {
            $findings += Add-GameSessionCanaryFinding -Id 'unsafe-runtime-path' -Severity 'fail' -Path '<policy>' -Message 'M5 readiness gate must not read user runtime paths, logs, cookies, DBs or dumps.'
        }
    }

    $tests = @(Get-GameSessionCanaryArray -Object $Plan -Name 'tests')
    if ($tests.Count -ne 1) {
        $findings += Add-GameSessionCanaryFinding -Id 'invalid-canary-count' -Severity 'fail' -Path '<policy>' -Message 'M5 readiness gate must define exactly one canary test.'
    }

    $maxSessionsPerRun = [int](Get-GameSessionCanaryValue -Object $ResourceBudget -Name 'maxSessionsPerRun' -Default 0)
    $maxParallelSessions = [int](Get-GameSessionCanaryValue -Object $ResourceBudget -Name 'maxParallelSessions' -Default 0)
    $maxSessionDurationSeconds = [int](Get-GameSessionCanaryValue -Object $ResourceBudget -Name 'maxSessionDurationSeconds' -Default 0)
    $allowedRegions = @(Get-GameSessionCanaryValue -Object $ResourceBudget -Name 'allowedRegions' -Default @())
    $allowedBudgetGames = @(Get-GameSessionCanaryValue -Object $ResourceBudget -Name 'allowedGames' -Default @())

    foreach ($test in $tests) {
        $name = [string](Get-GameSessionCanaryValue -Object $test -Name 'name' -Default '<unnamed>')
        $path = "tests/$name"
        $classification = [string](Get-GameSessionCanaryValue -Object $test -Name 'classification' -Default '')
        $startsGameSession = (Get-GameSessionCanaryValue -Object $test -Name 'startsGameSession' -Default $false) -eq $true
        $mutatesState = (Get-GameSessionCanaryValue -Object $test -Name 'mutatesState' -Default $false) -eq $true
        $requiresCleanupVerification = (Get-GameSessionCanaryValue -Object $test -Name 'requiresCleanupVerification' -Default $false) -eq $true
        $targetRegion = [string](Get-GameSessionCanaryValue -Object $test -Name 'targetRegion' -Default '')
        $targetGame = [string](Get-GameSessionCanaryValue -Object $test -Name 'targetGame' -Default '')
        $durationSeconds = [int](Get-GameSessionCanaryValue -Object $test -Name 'maxSessionDurationSeconds' -Default 0)
        $retries = [int](Get-GameSessionCanaryValue -Object $test -Name 'maxRetries' -Default 0)
        $expectedSignals = @(Get-GameSessionCanaryArray -Object $test -Name 'expectedReadinessSignals')

        $allowedGameMatches = @($AllowedGames | Where-Object {
            $_.alias -eq $targetGame -and
            $_.environment -eq 'production' -and
            @($_.allowedFor) -contains 'prod_conditional_stream_canary'
        })

        $checks += [pscustomobject]@{
            type = 'game-session-canary-plan'
            name = $name
            classification = $classification
            targetRegion = $targetRegion
            targetGame = $targetGame
            passed = (
                $classification -eq 'PROD_CONDITIONAL' -and
                $startsGameSession -and
                $mutatesState -and
                $requiresCleanupVerification -and
                $durationSeconds -ge 1 -and
                $durationSeconds -le $maxSessionDurationSeconds -and
                $maxSessionsPerRun -eq 1 -and
                $maxParallelSessions -eq 1 -and
                $allowedRegions -contains $targetRegion -and
                $allowedBudgetGames -contains $targetGame -and
                $allowedGameMatches.Count -eq 1 -and
                $retries -eq 0 -and
                $expectedSignals -contains 'stream-ready' -and
                $expectedSignals -contains 'first-frame'
            )
        }

        if ($classification -ne 'PROD_CONDITIONAL') {
            $findings += Add-GameSessionCanaryFinding -Id 'non-prod-conditional-canary' -Severity 'fail' -Path $path -Message 'M5 game-session canary must be classified as PROD_CONDITIONAL.'
        }
        if (-not $startsGameSession) {
            $findings += Add-GameSessionCanaryFinding -Id 'missing-game-session-intent' -Severity 'fail' -Path $path -Message 'M5 canary metadata must explicitly mark startsGameSession=true.'
        }
        if (-not $mutatesState) {
            $findings += Add-GameSessionCanaryFinding -Id 'missing-state-mutation-intent' -Severity 'fail' -Path $path -Message 'M5 canary metadata must explicitly mark mutatesState=true.'
        }
        if (-not $requiresCleanupVerification) {
            $findings += Add-GameSessionCanaryFinding -Id 'cleanup-not-required' -Severity 'fail' -Path $path -Message 'M5 canary must require cleanup verification.'
        }
        if ($durationSeconds -lt 1 -or $durationSeconds -gt $maxSessionDurationSeconds) {
            $findings += Add-GameSessionCanaryFinding -Id 'duration-exceeds-budget' -Severity 'fail' -Path $path -Message 'M5 canary duration must fit within prodResourceBudget.maxSessionDurationSeconds.'
        }
        if ($maxSessionsPerRun -ne 1 -or $maxParallelSessions -ne 1) {
            $findings += Add-GameSessionCanaryFinding -Id 'unsafe-session-concurrency-budget' -Severity 'fail' -Path '<resourceBudget>' -Message 'M5 canary requires exactly one session per run and one parallel session.'
        }
        if (-not ($allowedRegions -contains $targetRegion)) {
            $findings += Add-GameSessionCanaryFinding -Id 'region-not-allowlisted' -Severity 'fail' -Path $path -Message 'M5 canary targetRegion must be allowlisted by resource budget.'
        }
        if (-not ($allowedBudgetGames -contains $targetGame)) {
            $findings += Add-GameSessionCanaryFinding -Id 'game-not-in-budget' -Severity 'fail' -Path $path -Message 'M5 canary targetGame must be allowlisted by resource budget.'
        }
        if ($allowedGameMatches.Count -ne 1) {
            $findings += Add-GameSessionCanaryFinding -Id 'game-not-allowlisted' -Severity 'fail' -Path $path -Message 'M5 canary targetGame must be present in allowed-games config for prod_conditional_stream_canary.'
        }
        if ($retries -ne 0) {
            $findings += Add-GameSessionCanaryFinding -Id 'uncontrolled-retries' -Severity 'fail' -Path $path -Message 'M5 readiness gate forbids retries that could create additional sessions.'
        }
        if (-not ($expectedSignals -contains 'stream-ready') -or -not ($expectedSignals -contains 'first-frame')) {
            $findings += Add-GameSessionCanaryFinding -Id 'missing-readiness-signals' -Severity 'fail' -Path $path -Message 'M5 canary plan must require stream-ready and first-frame readiness signals.'
        }
    }

    $failFindings = @($findings | Where-Object { $_.severity -eq 'fail' })
    return [pscustomobject]@{
        gate = 'GameSessionCanary'
        dryRun = [bool]$DryRun
        processStarted = $false
        networkCallAttempted = $false
        authAttempted = $false
        gameSessionStarted = $false
        cleanupAttempted = $false
        readRuntimeUserData = $false
        passed = ($failFindings.Count -eq 0)
        checks = $checks
        findings = $findings
    }
}

Export-ModuleMember -Function `
    Read-GameSessionCanaryPlan, `
    Read-AllowedGamesConfig, `
    Test-GameSessionCanaryPlan
