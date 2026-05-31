param(
    [string] $PlanPath,

    [string] $SyntheticUsersPath,

    [string] $ResourceBudgetPath,

    [string] $AllowedGamesPath,

    [switch] $DryRun,

    [switch] $AllowProdConditional,

    [switch] $CleanupVerified,

    [switch] $AllowClientLaunch,

    [switch] $AllowNetwork,

    [switch] $AllowAuth,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/GameSessionCanary/GameSessionCanary.psm1'
Import-Module $modulePath -Force
$prodSafetyModulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $prodSafetyModulePath -Force

if ([string]::IsNullOrWhiteSpace($PlanPath)) {
    $PlanPath = Join-Path $repoRoot 'testdata/game-session-canary.example.json'
}
if ([string]::IsNullOrWhiteSpace($SyntheticUsersPath)) {
    $SyntheticUsersPath = Join-Path $repoRoot 'testdata/synthetic-users.example.json'
}
if ([string]::IsNullOrWhiteSpace($ResourceBudgetPath)) {
    $ResourceBudgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
}
if ([string]::IsNullOrWhiteSpace($AllowedGamesPath)) {
    $AllowedGamesPath = Join-Path $repoRoot 'testdata/allowed-games.example.json'
}

function Assert-GameSessionCanaryInputPathSafe {
    param(
        [Parameter(Mandatory = $true)][string] $Name,
        [Parameter(Mandatory = $true)][string] $Path
    )

    if ($Path -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump|Local Storage|IndexedDB|\.db') {
        throw "M5 game-session canary readiness gate must not read unsafe runtime input path '$Name'."
    }
}

Assert-GameSessionCanaryInputPathSafe -Name 'PlanPath' -Path $PlanPath
Assert-GameSessionCanaryInputPathSafe -Name 'SyntheticUsersPath' -Path $SyntheticUsersPath
Assert-GameSessionCanaryInputPathSafe -Name 'ResourceBudgetPath' -Path $ResourceBudgetPath
Assert-GameSessionCanaryInputPathSafe -Name 'AllowedGamesPath' -Path $AllowedGamesPath

if (-not $DryRun) {
    throw 'M5 game-session canary readiness gate is dry-run only. Real game-session execution requires a separately approved milestone.'
}
if ($AllowClientLaunch) {
    throw 'Installed client launch is forbidden in the M5 readiness gate.'
}
if ($AllowNetwork) {
    throw 'Production backend or streaming network calls are forbidden in the M5 readiness gate.'
}
if ($AllowAuth) {
    throw 'Authentication and credentials are forbidden in the M5 readiness gate.'
}

$plan = Read-GameSessionCanaryPlan -Path $PlanPath
$syntheticUsers = Read-SyntheticUsersConfig -Path $SyntheticUsersPath
$budget = Read-ProdResourceBudget -Path $ResourceBudgetPath
$allowedGames = Read-AllowedGamesConfig -Path $AllowedGamesPath

$tests = @($plan.tests)
if ($tests.Count -eq 0) {
    throw 'Game-session canary plan must define one PROD_CONDITIONAL test metadata entry.'
}

$guard = Invoke-ProdGuard `
    -Tests $tests `
    -Environment production `
    -SyntheticUsers $syntheticUsers `
    -ResourceBudget $budget `
    -AllowProdConditional:$AllowProdConditional `
    -CleanupVerified:$CleanupVerified `
    -DryRun:$DryRun

if (-not $guard.passed) {
    if (-not $ReportOnly) {
        $guard | ConvertTo-Json -Depth 8
        throw 'Game-session canary plan failed ProdGuard validation.'
    }
}

$result = Test-GameSessionCanaryPlan -Plan $plan -AllowedGames $allowedGames -SyntheticUsers $syntheticUsers -ResourceBudget $budget -DryRun:$DryRun
$result | ConvertTo-Json -Depth 12

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "Game-session canary readiness gate failed with $($failFindings.Count) fail finding(s)."
}
