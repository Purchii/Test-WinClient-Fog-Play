Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'TestabilityGaps.psm1'
Import-Module $modulePath -Force

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool] $Condition,
        [Parameter(Mandatory = $true)][string] $Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-FindingId {
    param(
        [Parameter(Mandatory = $true)][object] $Result,
        [Parameter(Mandatory = $true)][string] $Id
    )

    $matches = @($Result.findings | Where-Object { $_.id -eq $Id })
    Assert-True ($matches.Count -gt 0) "Expected finding id was not produced: $Id"
}

$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$policy = Read-TestabilityGapsPolicy -Path (Join-Path $repoRoot 'testdata/testability-gaps.example.json')

$result = Test-TestabilityGapsPolicy -Policy $policy -DryRun
Assert-True $result.passed 'Testability gaps fixture should pass.'
Assert-True (-not $result.productionActionAttempted) 'Gap tracking must not attempt production actions.'
Assert-True (-not $result.credentialsUsed) 'Gap tracking must not use credentials.'
Assert-True (-not $result.runtimeUserDataRead) 'Gap tracking must not read runtime user data.'

$result = Test-TestabilityGapsPolicy -Policy $policy
Assert-True (-not $result.passed) 'Testability gaps validator should fail closed without -DryRun.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$unsafe = Read-TestabilityGapsPolicy -Path (Join-Path $repoRoot 'testdata/testability-gaps-unsafe.example.json')
$result = Test-TestabilityGapsPolicy -Policy $unsafe -DryRun
Assert-True (-not $result.passed) 'Unsafe testability gaps fixture should fail.'
Assert-FindingId -Result $result -Id 'policy-not-dry-run-only'
Assert-FindingId -Result $result -Id 'production-execution-not-disabled'
Assert-FindingId -Result $result -Id 'runtime-data-read-not-disabled'
Assert-FindingId -Result $result -Id 'credentials-not-disabled'
Assert-FindingId -Result $result -Id 'invalid-gap-id'
Assert-FindingId -Result $result -Id 'invalid-area'
Assert-FindingId -Result $result -Id 'invalid-status'
Assert-FindingId -Result $result -Id 'gap-marked-production-safe'
Assert-FindingId -Result $result -Id 'gap-requires-credentials'
Assert-FindingId -Result $result -Id 'gap-requires-user-data'
Assert-FindingId -Result $result -Id 'invalid-required-evidence'
Assert-FindingId -Result $result -Id 'missing-stop-trigger'
Assert-FindingId -Result $result -Id 'unsafe-next-safe-step'

Write-Host 'TestabilityGaps.Tests.ps1 passed.'
