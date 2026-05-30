param(
    [string] $ArtifactRoot = 'C:\Program Files\MTC Fog Play',

    [string] $PolicyPath,

    [switch] $DryRun,

    [switch] $AllowClientLaunch,

    [switch] $AllowWebViewDebugPort,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/WindowsSmoke/WindowsSmoke.psm1'
Import-Module $modulePath -Force
$prodSafetyModulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $prodSafetyModulePath -Force

if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
    $PolicyPath = Join-Path $repoRoot 'testdata/app-webview-smoke.example.json'
}

if ($AllowWebViewDebugPort) {
    throw 'WebView debug port is not allowed by default for production smoke. Use a separately approved diagnostic milestone.'
}

if (-not $DryRun -and -not $AllowClientLaunch) {
    throw 'M2 app smoke is dry-run/static by default. Real client launch requires explicit -AllowClientLaunch and a separate approval.'
}

if ($AllowClientLaunch) {
    throw 'Real client launch is intentionally not implemented in M2. This runner only performs static/dry-run artifact checks.'
}

$policy = Read-AppWebViewSmokePolicy -Path $PolicyPath
$tests = @($policy.tests)
if ($tests.Count -eq 0) {
    throw 'App/WebView smoke policy must define at least one PROD_SAFE test metadata entry.'
}

$guard = Invoke-ProdGuard -Tests $tests -Environment production -DryRun:$DryRun
if (-not $guard.passed) {
    $guard | ConvertTo-Json -Depth 8
    throw 'App/WebView smoke policy failed ProdGuard validation.'
}

$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $ArtifactRoot -Policy $policy -DryRun:$DryRun
$result | ConvertTo-Json -Depth 8

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "App/WebView smoke failed with $($failFindings.Count) fail finding(s)."
}
