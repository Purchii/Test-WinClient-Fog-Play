Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'BackendSmoke.psm1'
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
$policy = Read-BackendSmokePolicy -Path (Join-Path $repoRoot 'testdata/backend-smoke.example.json')

$result = Test-BackendSmokePolicy -Policy $policy -DryRun
Assert-True $result.passed 'Backend smoke fixture should pass.'
Assert-True (-not $result.networkCallAttempted) 'M4 dry-run must not attempt network calls.'
Assert-True (-not $result.authAttempted) 'M4 dry-run must not attempt auth.'
Assert-True (-not $result.gameSessionStarted) 'M4 dry-run must not start game sessions.'
Assert-True (-not $result.readRuntimeUserData) 'M4 dry-run must not read runtime user data.'
Assert-True (-not $result.mutatingRequestAttempted) 'M4 dry-run must not attempt mutating requests.'

$result = Test-BackendSmokePolicy -Policy $policy
Assert-True (-not $result.passed) 'Backend smoke validator should fail closed without -DryRun.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$broken = $policy | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$broken.endpoints[0].method = 'POST'
$broken.endpoints[1].requiresAuth = $true
$broken.endpoints[2].responseSchema = $null
$result = Test-BackendSmokePolicy -Policy $broken -DryRun
Assert-True (-not $result.passed) 'Broken backend smoke policy should fail.'
Assert-FindingId -Result $result -Id 'unsafe-http-method'
Assert-FindingId -Result $result -Id 'auth-required'
Assert-FindingId -Result $result -Id 'missing-response-schema'

$broken = $policy | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$broken.endpoints[0].name = 'Invalid Endpoint Name'
$broken.endpoints[1].classification = 'PROD_CONDITIONAL'
$result = Test-BackendSmokePolicy -Policy $broken -DryRun
Assert-True (-not $result.passed) 'Invalid backend smoke endpoint identity and classification should fail.'
Assert-FindingId -Result $result -Id 'invalid-endpoint-name'
Assert-FindingId -Result $result -Id 'non-prod-safe-endpoint'

$broken = $policy | ConvertTo-Json -Depth 12 | ConvertFrom-Json
$broken.endpoints = @()
$result = Test-BackendSmokePolicy -Policy $broken -DryRun
Assert-True (-not $result.passed) 'Backend smoke policy without endpoints should fail.'
Assert-FindingId -Result $result -Id 'missing-endpoints'

$unsafe = Read-BackendSmokePolicy -Path (Join-Path $repoRoot 'testdata/backend-smoke-unsafe.example.json')
$result = Test-BackendSmokePolicy -Policy $unsafe -DryRun
Assert-True (-not $result.passed) 'Unsafe backend smoke policy should fail.'
Assert-FindingId -Result $result -Id 'policy-not-dry-run-only'
Assert-FindingId -Result $result -Id 'network-not-disabled'
Assert-FindingId -Result $result -Id 'unsafe-header'
Assert-FindingId -Result $result -Id 'unsafe-runtime-path'
Assert-FindingId -Result $result -Id 'state-mutating-endpoint'
Assert-FindingId -Result $result -Id 'unsafe-endpoint-path'
Assert-FindingId -Result $result -Id 'missing-mock-response'

Write-Host 'BackendSmoke.Tests.ps1 passed.'
