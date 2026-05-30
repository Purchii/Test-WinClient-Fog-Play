Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'WebViewBridge.psm1'
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

    $matches = @($Result.findings | Where-Object { $_.id -eq $Id })
    Assert-True ($matches.Count -gt 0) "Expected finding id was not produced: $Id"
}

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$contract = Read-WebViewBridgeContract -Path (Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json')

$result = Test-WebViewBridgeContract -Contract $contract -DryRun
Assert-True $result.passed 'WebView bridge contract fixture should pass.'
Assert-True (-not $result.launchedClient) 'M3 dry-run must not launch the client.'
Assert-True (-not $result.enabledWebViewDebugPort) 'M3 dry-run must not enable WebView debug port.'
Assert-True (-not $result.processStarted) 'M3 dry-run must report processStarted=false.'
Assert-True (-not $result.debugPortUsed) 'M3 dry-run must report debugPortUsed=false.'
Assert-True (-not $result.authAttempted) 'M3 dry-run must report authAttempted=false.'
Assert-True (-not $result.gameSessionStarted) 'M3 dry-run must report gameSessionStarted=false.'
Assert-True (-not $result.readRuntimeUserData) 'M3 dry-run must not read runtime user data.'

$result = Test-WebViewBridgeContract -Contract $contract
Assert-True (-not $result.passed) 'WebView bridge contract validator should fail closed without -DryRun.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$broken = $contract | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$broken.commands[0].payloadSchema = $null
$broken.events[0].direction = 'web -> native'
$broken.fakeNativeHostCases[0].target = 'unknown.command'
$result = Test-WebViewBridgeContract -Contract $broken -DryRun
Assert-True (-not $result.passed) 'Broken WebView bridge contract should fail.'
Assert-FindingId -Result $result -Id 'missing-command-payload-schema'
Assert-FindingId -Result $result -Id 'invalid-event-direction'
Assert-FindingId -Result $result -Id 'unknown-fake-host-target'

$unsafe = Read-WebViewBridgeContract -Path (Join-Path $repoRoot 'testdata/webview-bridge-contract-unsafe.example.json')
$result = Test-WebViewBridgeContract -Contract $unsafe -DryRun
Assert-True (-not $result.passed) 'Unsafe WebView bridge contract policy should fail.'
Assert-FindingId -Result $result -Id 'policy-not-dry-run-only'
Assert-FindingId -Result $result -Id 'unsafe-diagnostic'
Assert-FindingId -Result $result -Id 'unsafe-runtime-path'

Write-Host 'WebViewBridge.Tests.ps1 passed.'
