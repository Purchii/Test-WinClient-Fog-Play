Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'GameSessionCanary.psm1'
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$prodSafetyModulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $prodSafetyModulePath -Force

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool] $Condition,

        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-FindingId {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Result,

        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $matches = @($Result.findings | Where-Object { $_.id -eq $Id })
    Assert-True ($matches.Count -gt 0) "Expected finding id was not produced: $Id"
}

$plan = Read-GameSessionCanaryPlan -Path (Join-Path $repoRoot 'testdata/game-session-canary.example.json')
$allowedGames = Read-AllowedGamesConfig -Path (Join-Path $repoRoot 'testdata/allowed-games.example.json')
$syntheticUsers = Read-SyntheticUsersConfig -Path (Join-Path $repoRoot 'testdata/synthetic-users.example.json')
$budget = Read-ProdResourceBudget -Path (Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml')

$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True $result.passed 'Game-session canary readiness fixture should pass.'
Assert-True (-not $result.processStarted) 'M5 dry-run must not start the client process.'
Assert-True (-not $result.networkCallAttempted) 'M5 dry-run must not attempt network calls.'
Assert-True (-not $result.authAttempted) 'M5 dry-run must not attempt auth.'
Assert-True (-not $result.gameSessionStarted) 'M5 dry-run must not start game sessions.'
Assert-True (-not $result.cleanupAttempted) 'M5 dry-run must not attempt real cleanup.'
Assert-True (-not $result.readRuntimeUserData) 'M5 dry-run must not read runtime user data.'

$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget
Assert-True (-not $result.passed) 'Game-session canary readiness validator should fail closed without -DryRun.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$missingSuitePlan = $plan | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$missingSuitePlan.tests[0].suites = @('prod-canary')
$result = Test-GameSessionCanaryPlan -Plan $missingSuitePlan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject missing suite metadata.'
Assert-FindingId -Result $result -Id 'missing-canary-suite-metadata'

$extraSuitePlan = $plan | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$extraSuitePlan.tests[0].suites = @('prod-canary', 'game-session-canary-readiness', 'manual-runtime')
$result = Test-GameSessionCanaryPlan -Plan $extraSuitePlan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject extra canary suite metadata.'
Assert-FindingId -Result $result -Id 'canary-suite-metadata-not-exact'

$unsupportedSignalPlan = $plan | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$unsupportedSignalPlan.tests[0].expectedReadinessSignals = @('stream-ready', 'first-frame', 'runtime-probe')
$result = Test-GameSessionCanaryPlan -Plan $unsupportedSignalPlan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject unsupported readiness signals.'
Assert-FindingId -Result $result -Id 'unsupported-readiness-signal'

$duplicateSignalPlan = $plan | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$duplicateSignalPlan.tests[0].expectedReadinessSignals = @('stream-ready', 'stream-ready', 'first-frame')
$result = Test-GameSessionCanaryPlan -Plan $duplicateSignalPlan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject duplicate readiness signals.'
Assert-FindingId -Result $result -Id 'readiness-signals-not-exact'

$runtimePathPlan = $plan | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$runtimePathPlan.runtimePaths = @('C:\Temp\canary.txt')
$result = Test-GameSessionCanaryPlan -Plan $runtimePathPlan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject any requested runtime paths.'
Assert-FindingId -Result $result -Id 'runtime-paths-not-empty'

$nonProductionSyntheticUsers = @(
    [pscustomobject]@{
        alias = 'qa-canary-stream-001'
        purpose = 'prod_conditional_stream_canary'
        allowedEnvironments = @('staging')
        canStartGameSession = $true
        maxSessionDurationSeconds = 120
    }
)
$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -SyntheticUsers $nonProductionSyntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject synthetic users not allowlisted for production.'
Assert-FindingId -Result $result -Id 'synthetic-alias-not-production-allowed'

$overbroadRunFrequencyBudget = [pscustomobject]@{
    maxSessionsPerRun = 1
    maxParallelSessions = 1
    maxSessionDurationSeconds = 120
    maxRunsPerHour = 4
    allowedRegions = @('eu-west')
    allowedGames = @('qa-allowlisted-game-1')
    requireCleanupVerification = $true
    requireExplicitConditionalFlag = $true
}
$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $overbroadRunFrequencyBudget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject overbroad run-frequency budgets.'
Assert-FindingId -Result $result -Id 'unsafe-run-frequency-budget'

$weakenedPolicyBudget = [pscustomobject]@{
    maxSessionsPerRun = 1
    maxParallelSessions = 1
    maxSessionDurationSeconds = 120
    maxRunsPerHour = 3
    allowedRegions = @('eu-west')
    allowedGames = @('qa-allowlisted-game-1')
    requireCleanupVerification = $false
    requireExplicitConditionalFlag = $false
}
$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $weakenedPolicyBudget -DryRun
Assert-True (-not $result.passed) 'Game-session canary readiness validator should reject resource budgets without cleanup and explicit conditional flag requirements.'
Assert-FindingId -Result $result -Id 'cleanup-budget-not-required'
Assert-FindingId -Result $result -Id 'conditional-flag-budget-not-required'

$unsafe = Read-GameSessionCanaryPlan -Path (Join-Path $repoRoot 'testdata/game-session-canary-unsafe.example.json')
$result = Test-GameSessionCanaryPlan -Plan $unsafe -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'Unsafe game-session canary plan should fail.'
Assert-FindingId -Result $result -Id 'policy-not-dry-run-only'
Assert-FindingId -Result $result -Id 'execution-not-disabled'
Assert-FindingId -Result $result -Id 'client-launch-not-disabled'
Assert-FindingId -Result $result -Id 'network-not-disabled'
Assert-FindingId -Result $result -Id 'auth-not-disabled'
Assert-FindingId -Result $result -Id 'unsafe-runtime-path'
Assert-FindingId -Result $result -Id 'non-prod-conditional-canary'
Assert-FindingId -Result $result -Id 'cleanup-not-required'
Assert-FindingId -Result $result -Id 'synthetic-alias-not-canary'
Assert-FindingId -Result $result -Id 'synthetic-alias-not-allowlisted'
Assert-FindingId -Result $result -Id 'duration-exceeds-budget'
Assert-FindingId -Result $result -Id 'duration-exceeds-synthetic-user-budget'
Assert-FindingId -Result $result -Id 'game-not-allowlisted'
Assert-FindingId -Result $result -Id 'uncontrolled-retries'
Assert-FindingId -Result $result -Id 'missing-readiness-signals'

Write-Host 'GameSessionCanary.Tests.ps1 passed.'
