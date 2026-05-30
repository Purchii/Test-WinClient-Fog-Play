param(
    [string] $PolicyPath,

    [switch] $DryRun,

    [switch] $AllowNetwork,

    [switch] $AllowAuth,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/BackendSmoke/BackendSmoke.psm1'
Import-Module $modulePath -Force
$prodSafetyModulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $prodSafetyModulePath -Force

if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path $repoRoot 'testdata/backend-smoke.example.json'
}

if ($AllowNetwork) {
    throw 'Real backend network calls are not allowed in M4 dry-run. Use a separately approved backend diagnostic milestone.'
}

if ($AllowAuth) {
    throw 'Authentication is not allowed in M4 backend smoke without a separately approved synthetic-user plan.'
}

if (-not $DryRun) {
    throw 'M4 backend smoke runner is dry-run only.'
}

$policy = Read-BackendSmokePolicy -Path $PolicyPath
$tests = @($policy.tests)
if ($tests.Count -eq 0) {
    throw 'Backend smoke policy must define at least one PROD_SAFE test metadata entry.'
}

$guard = Invoke-ProdGuard -Tests $tests -Environment production -DryRun:$DryRun
if (-not $guard.passed) {
    $guard | ConvertTo-Json -Depth 8
    throw 'Backend smoke policy failed ProdGuard validation.'
}

$result = Test-BackendSmokePolicy -Policy $policy -DryRun:$DryRun
$result | ConvertTo-Json -Depth 12

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "Backend smoke failed with $($failFindings.Count) fail finding(s)."
}
