Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'WindowsSmoke.psm1'
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

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$policy = Read-AppWebViewSmokePolicy -Path (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json')
$fixtureRoot = Join-Path $repoRoot 'testdata/app-webview-smoke-fixture'

$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $policy -DryRun
Assert-True $result.passed 'App/WebView smoke fixture should pass.'
Assert-True (-not $result.launchedClient) 'Dry-run fixture must not launch the client.'
Assert-True (-not $result.enabledWebViewDebugPort) 'Dry-run fixture must not enable WebView debug port.'
Assert-True (-not $result.processStarted) 'Dry-run fixture must report processStarted=false.'
Assert-True (-not $result.debugPortUsed) 'Dry-run fixture must report debugPortUsed=false.'
Assert-True (-not $result.authAttempted) 'Dry-run fixture must report authAttempted=false.'
Assert-True (-not $result.gameSessionStarted) 'Dry-run fixture must report gameSessionStarted=false.'

$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $policy
Assert-True (-not $result.passed) 'App/WebView smoke validator should fail closed without -DryRun.'

$brokenPolicy = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
$brokenPolicy.webViewBundles[0].requiredManifestKeys = @('main.css', 'missing.js')
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $brokenPolicy -DryRun
Assert-True (-not $result.passed) 'Missing WebView manifest keys must fail.'

$unsafePolicy = Read-AppWebViewSmokePolicy -Path (Join-Path $repoRoot 'testdata/app-webview-smoke-unsafe-policy.example.json')
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $unsafePolicy -DryRun
Assert-True (-not $result.passed) 'Unsafe App/WebView smoke policy must fail.'

Write-Host 'WindowsSmoke.Tests.ps1 passed.'
