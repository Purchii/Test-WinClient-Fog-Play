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

function Assert-FindingId {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Result,

        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $match = @($Result.findings | Where-Object { $_.id -eq $Id })
    if ($match.Count -eq 0) {
        throw "Expected finding id '$Id'."
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
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$brokenPolicy = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
$brokenPolicy.requiredFiles = @('bin/missing-client.exe')
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $brokenPolicy -DryRun
Assert-True (-not $result.passed) 'Missing required artifact files must fail.'
Assert-FindingId -Result $result -Id 'missing-required-file'

$brokenPolicy = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
$brokenPolicy.webViewBundles[0].path = 'bin/resources/missing-settings'
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $brokenPolicy -DryRun
Assert-True (-not $result.passed) 'Missing WebView bundles must fail.'
Assert-FindingId -Result $result -Id 'missing-webview-bundle'

$brokenPolicy = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
$brokenPolicy.webViewBundles[0].requiredFiles = @('index.html', 'missing-entrypoint.html')
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $brokenPolicy -DryRun
Assert-True (-not $result.passed) 'Missing WebView entrypoints must fail.'
Assert-FindingId -Result $result -Id 'missing-webview-entrypoint'

$brokenPolicy = $policy | ConvertTo-Json -Depth 8 | ConvertFrom-Json
$brokenPolicy.webViewBundles[0].requiredManifestKeys = @('main.css', 'missing.js')
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $brokenPolicy -DryRun
Assert-True (-not $result.passed) 'Missing WebView manifest keys must fail.'
Assert-FindingId -Result $result -Id 'missing-manifest-key'

$invalidManifestRoot = Join-Path $repoRoot '.tmp/windows-smoke-invalid-manifest-fixture'
$invalidManifestBundle = Join-Path $invalidManifestRoot 'bin/resources/settings'
if (-not ($invalidManifestRoot -like (Join-Path $repoRoot '.tmp') + '*')) {
    throw 'Invalid manifest fixture root must stay under repo .tmp.'
}
if (Test-Path -LiteralPath $invalidManifestRoot) {
    Remove-Item -LiteralPath $invalidManifestRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $invalidManifestBundle -Force | Out-Null
Set-Content -LiteralPath (Join-Path $invalidManifestBundle 'asset-manifest.json') -Value '{ invalid json' -NoNewline
try {
    $invalidManifestPolicy = [pscustomobject]@{
        dryRunOnly = $true
        launchArguments = @()
        runtimePaths = @()
        requiredFiles = @()
        webViewBundles = @(
            [pscustomobject]@{
                name = 'settings'
                path = 'bin/resources/settings'
                requiredFiles = @()
                requiredManifestKeys = @('main.js')
            }
        )
    }
    $result = Test-AppWebViewSmokeArtifact -ArtifactRoot $invalidManifestRoot -Policy $invalidManifestPolicy -DryRun
    Assert-True (-not $result.passed) 'Invalid WebView asset manifests must fail.'
    Assert-FindingId -Result $result -Id 'invalid-asset-manifest'
}
finally {
    if (Test-Path -LiteralPath $invalidManifestRoot) {
        Remove-Item -LiteralPath $invalidManifestRoot -Recurse -Force
    }
    $tmpRoot = Join-Path $repoRoot '.tmp'
    if ((Test-Path -LiteralPath $tmpRoot) -and ((Get-ChildItem -LiteralPath $tmpRoot -Force | Measure-Object).Count -eq 0)) {
        Remove-Item -LiteralPath $tmpRoot -Force
    }
}

$unsafePolicy = Read-AppWebViewSmokePolicy -Path (Join-Path $repoRoot 'testdata/app-webview-smoke-unsafe-policy.example.json')
$result = Test-AppWebViewSmokeArtifact -ArtifactRoot $fixtureRoot -Policy $unsafePolicy -DryRun
Assert-True (-not $result.passed) 'Unsafe App/WebView smoke policy must fail.'
Assert-FindingId -Result $result -Id 'unsafe-launch-argument'
Assert-FindingId -Result $result -Id 'unsafe-runtime-path'

Write-Host 'WindowsSmoke.Tests.ps1 passed.'
