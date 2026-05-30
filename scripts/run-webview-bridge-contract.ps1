param(
    [string] $ContractPath,

    [switch] $DryRun,

    [switch] $AllowWebViewDebugPort,

    [switch] $AllowClientLaunch,

    [switch] $ReportOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot 'src/TestFramework/WebViewBridge/WebViewBridge.psm1'
Import-Module $modulePath -Force
$prodSafetyModulePath = Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.psm1'
Import-Module $prodSafetyModulePath -Force

if ([string]::IsNullOrWhiteSpace($ContractPath)) {
    $ContractPath = Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json'
}

if ($AllowWebViewDebugPort) {
    throw 'WebView debug/CDP is not allowed in M3 contract dry-run.'
}

if ($AllowClientLaunch) {
    throw 'Real client launch is intentionally not implemented in M3. This runner only performs local contract and fake-host dry-run checks.'
}

if (-not $DryRun) {
    throw 'M3 WebView bridge contract runner is dry-run only.'
}

$contract = Read-WebViewBridgeContract -Path $ContractPath
$tests = @($contract.tests)
if ($tests.Count -eq 0) {
    throw 'WebView bridge contract must define at least one PROD_SAFE test metadata entry.'
}

$guard = Invoke-ProdGuard -Tests $tests -Environment production -DryRun:$DryRun
if (-not $guard.passed) {
    $guard | ConvertTo-Json -Depth 8
    throw 'WebView bridge contract failed ProdGuard validation.'
}

$result = Test-WebViewBridgeContract -Contract $contract -DryRun:$DryRun
$result | ConvertTo-Json -Depth 12

$failFindings = @($result.findings | Where-Object { $_.severity -eq 'fail' })
if ($failFindings.Count -gt 0 -and -not $ReportOnly) {
    throw "WebView bridge contract failed with $($failFindings.Count) fail finding(s)."
}
