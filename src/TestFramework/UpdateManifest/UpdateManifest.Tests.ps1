Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$modulePath = Join-Path $PSScriptRoot 'UpdateManifest.psm1'
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
$policy = Read-UpdateManifestPolicy -Path (Join-Path $repoRoot 'testdata/update-manifest.example.json')

$result = Test-UpdateManifestPolicy -Policy $policy -DryRun
Assert-True $result.passed 'Update manifest fixture should pass.'
Assert-True (-not $result.networkCallAttempted) 'Update manifest dry-run must not call network.'
Assert-True (-not $result.updaterStarted) 'Update manifest dry-run must not start updater.'
Assert-True (-not $result.rollbackAttempted) 'Update manifest dry-run must not attempt rollback.'
Assert-True (-not $result.credentialsUsed) 'Update manifest dry-run must not use credentials.'

$result = Test-UpdateManifestPolicy -Policy $policy
Assert-True (-not $result.passed) 'Update manifest validator should fail closed without -DryRun.'
Assert-FindingId -Result $result -Id 'dry-run-flag-required'

$unsafe = Read-UpdateManifestPolicy -Path (Join-Path $repoRoot 'testdata/update-manifest-unsafe.example.json')
$result = Test-UpdateManifestPolicy -Policy $unsafe -DryRun
Assert-True (-not $result.passed) 'Unsafe update manifest fixture should fail.'
Assert-FindingId -Result $result -Id 'policy-not-dry-run-only'
Assert-FindingId -Result $result -Id 'network-not-disabled'
Assert-FindingId -Result $result -Id 'execution-not-disabled'
Assert-FindingId -Result $result -Id 'rollback-not-disabled'
Assert-FindingId -Result $result -Id 'credentials-not-disabled'
Assert-FindingId -Result $result -Id 'unsafe-endpoint'
Assert-FindingId -Result $result -Id 'command-defined'
Assert-FindingId -Result $result -Id 'invalid-version'
Assert-FindingId -Result $result -Id 'unsafe-artifact-path'
Assert-FindingId -Result $result -Id 'invalid-sha256'
Assert-FindingId -Result $result -Id 'invalid-size'
Assert-FindingId -Result $result -Id 'signature-not-required'
Assert-FindingId -Result $result -Id 'rollback-allowed'
Assert-FindingId -Result $result -Id 'post-install-command-defined'

Write-Host 'UpdateManifest.Tests.ps1 passed.'
