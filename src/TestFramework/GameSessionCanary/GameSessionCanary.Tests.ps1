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
$budget = Read-ProdResourceBudget -Path (Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml')

$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -ResourceBudget $budget -DryRun
Assert-True $result.passed 'Game-session canary readiness fixture should pass.'
Assert-True (-not $result.processStarted) 'M5 dry-run must not start the client process.'
Assert-True (-not $result.networkCallAttempted) 'M5 dry-run must not attempt network calls.'
Assert-True (-not $result.authAttempted) 'M5 dry-run must not attempt auth.'
Assert-True (-not $result.gameSessionStarted) 'M5 dry-run must not start game sessions.'
Assert-True (-not $result.cleanupAttempted) 'M5 dry-run must not attempt real cleanup.'
Assert-True (-not $result.readRuntimeUserData) 'M5 dry-run must not read runtime user data.'

$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -ResourceBudget $budget
Assert-True (-not $result.passed) 'Game-session canary readiness validator should fail closed without -DryRun.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$unsafe = Read-GameSessionCanaryPlan -Path (Join-Path $repoRoot 'testdata/game-session-canary-unsafe.example.json')
$result = Test-GameSessionCanaryPlan -Plan $unsafe -AllowedGames $allowedGames -ResourceBudget $budget -DryRun
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
Assert-FindingId -Result $result -Id 'duration-exceeds-budget'
Assert-FindingId -Result $result -Id 'game-not-allowlisted'
Assert-FindingId -Result $result -Id 'uncontrolled-retries'
Assert-FindingId -Result $result -Id 'missing-readiness-signals'

Write-Host 'GameSessionCanary.Tests.ps1 passed.'
