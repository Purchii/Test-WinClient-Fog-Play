param(
    [string] $PlanPath,

    [switch] $DryRun,

    [switch] $AllowExecution,

    [switch] $AllowNetwork,

    [switch] $AllowAuth,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/NonProdFoundation/NonProdFoundation.psm1'
Import-Module $modulePath -Force
$prodSafetyModulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $prodSafetyModulePath -Force

if ([string]::IsNullOrWhiteSpace($PlanPath)) {
    $PlanPath = Join-Path $repoRoot 'testdata/nonprod-foundation.example.json'
}

if ($PlanPath -match '(?i)AppData|Cookies|cookie|\.log|logs|crash|dump|Local Storage|IndexedDB|\.db') {
    throw 'M6 non-prod foundation runner must not read unsafe runtime input paths.'
}

if ($AllowExecution) {
    throw 'Execution is not allowed in M6 local-only foundation.'
}

if ($AllowNetwork) {
    throw 'Network calls are not allowed in M6 local-only foundation.'
}

if ($AllowAuth) {
    throw 'Authentication is not allowed in M6 local-only foundation.'
}

if (-not $DryRun) {
    throw 'M6 non-prod foundation runner is dry-run only.'
}

$plan = Read-NonProdFoundationPlan -Path $PlanPath
$tests = @($plan.tests)
if ($tests.Count -eq 0) {
    throw 'Non-prod foundation plan must define at least one NON_PROD_ONLY test metadata entry.'
}

$guard = Invoke-ProdGuard -Tests $tests -Environment local -DryRun:$DryRun
if (-not $guard.passed) {
    $guard | ConvertTo-Json -Depth 8
    throw 'Non-prod foundation plan failed local ProdGuard validation.'
}

$result = Test-NonProdFoundationPlan -Plan $plan -DryRun:$DryRun
$result | ConvertTo-Json -Depth 12

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "Non-prod foundation failed with $($failFindings.Count) fail finding(s)."
}
