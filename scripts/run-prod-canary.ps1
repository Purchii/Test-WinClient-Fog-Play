param(
    [ValidateSet('local', 'staging', 'production')]
    [string] $Environment = 'production',

    [string] $TestMetadataPath,

    [string] $SyntheticUsersPath,

    [string] $ResourceBudgetPath,

    [switch] $AllowProdConditional,

    [switch] $CleanupVerified,

    [switch] $DryRun,

    [switch] $ExpectFailure
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $modulePath -Force

if ([string]::IsNullOrWhiteSpace($TestMetadataPath)) {
    $TestMetadataPath = Join-Path $repoRoot 'testdata/prod-safety-tests.example.json'
}
if ([string]::IsNullOrWhiteSpace($SyntheticUsersPath)) {
    $SyntheticUsersPath = Join-Path $repoRoot 'testdata/synthetic-users.example.json'
}
if ([string]::IsNullOrWhiteSpace($ResourceBudgetPath)) {
    $ResourceBudgetPath = Join-Path $repoRoot 'testdata/prod-resource-budget.example.yaml'
}

$allTests = Read-TestMetadataFile -Path $TestMetadataPath
$canaryTests = @($allTests | Where-Object { $_.classification -eq 'PROD_CONDITIONAL' })
if ($canaryTests.Count -eq 0) {
    throw 'No PROD_CONDITIONAL canary tests are available.'
}

$syntheticUsers = Read-SyntheticUsersConfig -Path $SyntheticUsersPath
$budget = Read-ProdResourceBudget -Path $ResourceBudgetPath

$result = Invoke-ProdGuard `
    -Tests $canaryTests `
    -Environment $Environment `
    -SyntheticUsers $syntheticUsers `
    -ResourceBudget $budget `
    -AllowProdConditional:$AllowProdConditional `
    -CleanupVerified:$CleanupVerified `
    -DryRun:$DryRun

$result | ConvertTo-Json -Depth 8

if ($ExpectFailure) {
    if ($result.passed) {
        throw 'Expected canary guard rejection, but the guard passed.'
    }
    Write-Host 'Expected canary guard rejection observed.'
    exit 0
}

if (-not $result.passed) {
    throw 'Prod canary guard rejected the requested run.'
}

if (-not $DryRun) {
    Write-Host 'Guard passed. M0 does not implement real game-session execution; no production action was performed by this script.'
}
