Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'NonProdFoundation.psm1'
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
$plan = Read-NonProdFoundationPlan -Path (Join-Path $repoRoot 'testdata/nonprod-foundation.example.json')

$result = Test-NonProdFoundationPlan -Plan $plan -DryRun
Assert-True $result.passed 'Non-prod foundation fixture should pass.'
Assert-True (-not $result.processStarted) 'M6 dry-run must not start processes.'
Assert-True (-not $result.debugPortUsed) 'M6 dry-run must not use WebView debug/CDP.'
Assert-True (-not $result.networkCallAttempted) 'M6 dry-run must not call network.'
Assert-True (-not $result.authAttempted) 'M6 dry-run must not authenticate.'
Assert-True (-not $result.gameSessionStarted) 'M6 dry-run must not start game sessions.'
Assert-True (-not $result.readRuntimeUserData) 'M6 dry-run must not read runtime user data.'
Assert-True (-not $result.ciCdEnabled) 'M6 dry-run must not enable CI/CD.'
Assert-True (-not $result.dependencyChanged) 'M6 dry-run must not change dependencies.'

$result = Test-NonProdFoundationPlan -Plan $plan
Assert-True (-not $result.passed) 'Direct validator invocation without -DryRun should fail.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$broken = $plan | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$broken.components[0].classification = 'PROD_SAFE'
$broken.components[1].executionEnabled = $true
$broken.components[2].contractSchema = $null
$result = Test-NonProdFoundationPlan -Plan $broken -DryRun
Assert-True (-not $result.passed) 'Broken non-prod foundation plan should fail.'
Assert-FindingId -Result $result -Id 'non-nonprod-classification'
Assert-FindingId -Result $result -Id 'component-execution-enabled'
Assert-FindingId -Result $result -Id 'missing-contract-schema'

$unsafe = Read-NonProdFoundationPlan -Path (Join-Path $repoRoot 'testdata/nonprod-foundation-unsafe.example.json')
$result = Test-NonProdFoundationPlan -Plan $unsafe -DryRun
Assert-True (-not $result.passed) 'Unsafe non-prod foundation plan should fail.'
Assert-FindingId -Result $result -Id 'policy-not-dry-run-only'
Assert-FindingId -Result $result -Id 'client-launch-not-disabled'
Assert-FindingId -Result $result -Id 'webview-debug-not-disabled'
Assert-FindingId -Result $result -Id 'network-not-disabled'
Assert-FindingId -Result $result -Id 'auth-not-disabled'
Assert-FindingId -Result $result -Id 'unsafe-runtime-path'
Assert-FindingId -Result $result -Id 'production-endpoint-defined'
Assert-FindingId -Result $result -Id 'component-uses-production'
Assert-FindingId -Result $result -Id 'component-requires-credentials'
Assert-FindingId -Result $result -Id 'component-mutates-state'
Assert-FindingId -Result $result -Id 'component-starts-game-session'
Assert-FindingId -Result $result -Id 'unsafe-component-reference'

Write-Host 'NonProdFoundation.Tests.ps1 passed.'
