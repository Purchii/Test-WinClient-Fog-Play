Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'ProdSafety.psm1'
Import-Module $modulePath -Force

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

$syntheticUsers = @(
    [pscustomobject]@{
        alias = 'qa-smoke-001'
        allowedEnvironments = @('production')
        canStartGameSession = $false
    },
    [pscustomobject]@{
        alias = 'qa-canary-stream-001'
        allowedEnvironments = @('production')
        canStartGameSession = $true
        maxSessionDurationSeconds = 120
    }
)

$budget = [pscustomobject]@{
    maxSessionsPerRun = 1
    maxParallelSessions = 1
    maxSessionDurationSeconds = 120
    maxRunsPerHour = 3
    allowedRegions = @('eu-west')
    allowedGames = @('qa-allowlisted-game-1')
    requireCleanupVerification = $true
    requireExplicitConditionalFlag = $true
}

$oversizedBudget = [pscustomobject]@{
    maxSessionsPerRun = 999
    maxParallelSessions = 1
    maxSessionDurationSeconds = 120
    maxRunsPerHour = 999
    allowedRegions = @()
    allowedGames = @()
    requireCleanupVerification = $true
    requireExplicitConditionalFlag = $true
}

$unclassified = New-TestMetadata -Name 'unclassified-test' -Classification $null
$forbidden = New-TestMetadata -Name 'load-test' -Classification 'PROD_FORBIDDEN'
$conditional = New-TestMetadata `
    -Name 'short-game-session-canary' `
    -Classification 'PROD_CONDITIONAL' `
    -RequiresSyntheticUserAlias 'qa-canary-stream-001' `
    -StartsGameSession $true `
    -RequiresCleanupVerification $true
$conditional | Add-Member -NotePropertyName targetRegion -NotePropertyValue 'eu-west'
$conditional | Add-Member -NotePropertyName targetGame -NotePropertyValue 'qa-allowlisted-game-1'
$conditionalDisallowedTarget = New-TestMetadata `
    -Name 'short-game-session-canary-disallowed-target' `
    -Classification 'PROD_CONDITIONAL' `
    -RequiresSyntheticUserAlias 'qa-canary-stream-001' `
    -StartsGameSession $true `
    -RequiresCleanupVerification $true
$conditionalDisallowedTarget | Add-Member -NotePropertyName targetRegion -NotePropertyValue 'not-allowlisted'
$conditionalDisallowedTarget | Add-Member -NotePropertyName targetGame -NotePropertyValue 'not-allowlisted-game'
$safe = New-TestMetadata `
    -Name 'catalog-read-only' `
    -Classification 'PROD_SAFE' `
    -RequiresSyntheticUserAlias 'qa-smoke-001'
$nonProdOnly = New-TestMetadata -Name 'update-rollback' -Classification 'NON_PROD_ONLY'
$mutatingSafeWithoutAlias = New-TestMetadata `
    -Name 'mutating-safe-without-alias' `
    -Classification 'PROD_SAFE' `
    -MutatesState $true `
    -RequiresCleanupVerification $true

$result = Invoke-ProdGuard -Tests @($unclassified) -Environment production -SyntheticUsers $syntheticUsers -DryRun
Assert-True (-not $result.passed) 'Unclassified tests must be rejected on production.'

$result = Invoke-ProdGuard -Tests @($forbidden) -Environment production -SyntheticUsers $syntheticUsers -DryRun
Assert-True (-not $result.passed) 'PROD_FORBIDDEN tests must be rejected on production.'

$result = Invoke-ProdGuard -Tests @($nonProdOnly) -Environment production -SyntheticUsers $syntheticUsers -DryRun
Assert-True (-not $result.passed) 'NON_PROD_ONLY tests must be rejected on production.'

$result = Invoke-ProdGuard -Tests @($conditional) -Environment production -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun
Assert-True (-not $result.passed) 'PROD_CONDITIONAL tests must require an explicit flag.'

$result = Invoke-ProdGuard -Tests @($conditional) -Environment production -SyntheticUsers $syntheticUsers -ResourceBudget $oversizedBudget -AllowProdConditional -CleanupVerified -DryRun
Assert-True (-not $result.passed) 'PROD_CONDITIONAL tests must reject oversized or incomplete resource budgets.'

$result = Invoke-ProdGuard -Tests @($conditionalDisallowedTarget) -Environment production -SyntheticUsers $syntheticUsers -ResourceBudget $budget -AllowProdConditional -CleanupVerified -DryRun
Assert-True (-not $result.passed) 'PROD_CONDITIONAL tests must reject target regions and games outside the resource budget allowlists.'

$result = Invoke-ProdGuard -Tests @($conditional) -Environment production -SyntheticUsers $syntheticUsers -AllowProdConditional -DryRun
Assert-True (-not $result.passed) 'PROD_CONDITIONAL tests must require a resource budget.'

$result = Invoke-ProdGuard -Tests @($conditional) -Environment production -SyntheticUsers $syntheticUsers -ResourceBudget $budget -AllowProdConditional -DryRun
Assert-True (-not $result.passed) 'Game-session tests must require cleanup verification.'

$result = Invoke-ProdGuard -Tests @($conditional) -Environment production -SyntheticUsers $syntheticUsers -ResourceBudget $budget -AllowProdConditional -CleanupVerified -DryRun
Assert-True $result.passed 'PROD_CONDITIONAL dry-run should pass only with explicit flag, budget, synthetic user and cleanup verification.'

$result = Invoke-ProdGuard -Tests @($safe) -Environment production -SyntheticUsers $syntheticUsers -DryRun
Assert-True $result.passed 'PROD_SAFE read-only test with synthetic user should pass dry-run production guard.'

$result = Invoke-ProdGuard -Tests @($mutatingSafeWithoutAlias) -Environment production -SyntheticUsers @() -CleanupVerified -DryRun
Assert-True (-not $result.passed) 'State-mutating PROD_SAFE tests must require an allowlisted synthetic user.'

$killSwitch = Test-KillSwitch -Environment production
Assert-True (-not $killSwitch.passed) 'Non-dry-run production automation must require PROD_AUTOMATION_ENABLED.'

Write-Host 'ProdSafety.Tests.ps1 passed.'
