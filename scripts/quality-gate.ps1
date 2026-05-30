param(
    [ValidateSet('Context', 'ProdSafety', 'Release', 'Privacy', 'Full')]
    [string] $Scope = 'Full'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string] $RelativePath
    )

    $path = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Required path is missing: $RelativePath"
    }
}

function Invoke-ContextGate {
    $required = @(
        'AGENTS.md',
        'docs/context/current-state.md',
        'docs/context/handoff/active-run.md',
        'docs/context/handoff/context-protocol.md',
        'docs/context/handoff/executor-policy.md',
        'docs/context/handoff/executor-checklist.md',
        'docs/context/governance/decisions-log.md',
        'docs/context/governance/session-log.md',
        'docs/context/governance/context-integrity-checklist.md',
        'docs/context/engineering/git-workflow.md',
        'docs/context/engineering/implementation-status.md',
        'docs/context/engineering/verification-memory.md',
        'docs/context/engineering/quality-gates.md',
        'docs/codex/autonomy-modes.md',
        'docs/codex/milestone-planning-policy.md',
        'docs/codex/communication-policy.md',
        'docs/codex/agent-roles.md',
        'docs/codex/prod-safe-codex-rules.md'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    Write-Host 'Context gate passed.'
}

function Invoke-ProdSafetyGate {
    $required = @(
        'docs/qa/prod-testing-policy.md',
        'docs/qa/synthetic-users-policy.md',
        'docs/qa/resource-budget-policy.md',
        'docs/qa/prod-safe-test-matrix.md',
        'docs/qa/artifacts-policy.md',
        'docs/qa/flakiness-policy.md',
        'testdata/synthetic-users.example.json',
        'testdata/prod-resource-budget.example.yaml',
        'testdata/prod-safety-tests.example.json',
        'src/TestFramework/ProdSafety/ProdSafety.psm1',
        'src/TestFramework/ProdSafety/ProdSafety.Tests.ps1',
        'scripts/run-prod-safe-smoke.ps1',
        'scripts/run-prod-canary.ps1'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/ProdSafety/ProdSafety.Tests.ps1')
    & (Join-Path $repoRoot 'scripts/run-prod-safe-smoke.ps1') -Environment production -DryRun

    $canaryScript = Join-Path $repoRoot 'scripts/run-prod-canary.ps1'
    & $canaryScript -Environment production -DryRun -ExpectFailure
    & $canaryScript -Environment production -DryRun -AllowProdConditional -CleanupVerified

    Write-Host 'ProdSafety gate passed.'
}

function Invoke-StubGate {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    Write-Host "$Name gate is documented but not implemented in M0."
}

function Invoke-JsonGate {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock] $Command
    )

    $output = & $Command
    $json = ($output | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($json)) {
        throw 'Gate command did not return JSON output.'
    }

    return $json | ConvertFrom-Json
}

function Assert-FindingId {
    param(
        [Parameter(Mandatory = $true)]
        [object] $Result,

        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    $matches = @($Result.findings | Where-Object { $_.id -eq $Id })
    if ($matches.Count -eq 0) {
        throw "Expected finding id was not produced: $Id"
    }
}

function Invoke-ReleaseGate {
    $required = @(
        'docs/qa/release-gates.md',
        'testdata/release-gate-policy.example.json',
        'testdata/release-gate-policy.clean-fixture.json',
        'testdata/release-fixture',
        'testdata/release-clean-fixture',
        'scripts/run-release-gate.ps1'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    $releaseGate = Join-Path $repoRoot 'scripts/run-release-gate.ps1'
    $negative = Invoke-JsonGate {
        & $releaseGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/release-gate-policy.example.json') `
            -DryRun `
            -ExpectFindings
    }

    if ($negative.passed -ne $false) {
        throw 'Release negative fixture should report passed=false.'
    }
    if (@($negative.signatureResults).Count -lt 4) {
        throw 'Release negative fixture did not exercise signature checks.'
    }
    if (@($negative.versionResults).Count -lt 1) {
        throw 'Release negative fixture did not exercise version metadata checks.'
    }
    Assert-FindingId -Result $negative -Id 'invalid-signature'
    Assert-FindingId -Result $negative -Id 'missing-version-metadata'
    Assert-FindingId -Result $negative -Id 'forbidden-extension'
    Assert-FindingId -Result $negative -Id 'local-user-path'

    $clean = Invoke-JsonGate {
        & $releaseGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-clean-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/release-gate-policy.clean-fixture.json') `
            -DryRun
    }

    if ($clean.passed -ne $true) {
        throw 'Release clean fixture should report passed=true.'
    }

    Write-Host 'Release gate passed.'
}

function Invoke-PrivacyGate {
    $required = @(
        'docs/qa/privacy-and-logging-checks.md',
        'testdata/privacy-patterns.example.json',
        'testdata/privacy-patterns-small-limit.example.json',
        'testdata/release-fixture',
        'testdata/privacy-clean-fixture',
        'testdata/privacy-negative-fixture',
        'testdata/privacy-large-fixture',
        'scripts/run-privacy-gate.ps1'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    $privacyGate = Join-Path $repoRoot 'scripts/run-privacy-gate.ps1'
    $installedLike = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/release-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun `
            -ExpectFindings
    }
    Assert-FindingId -Result $installedLike -Id 'local-user-path'

    $negative = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-negative-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun `
            -ExpectFindings
    }
    Assert-FindingId -Result $negative -Id 'bearer-token'
    Assert-FindingId -Result $negative -Id 'password'
    Assert-FindingId -Result $negative -Id 'generic-token'

    $large = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-large-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns-small-limit.example.json') `
            -DryRun `
            -ExpectFindings
    }
    Assert-FindingId -Result $large -Id 'text-file-too-large'

    $clean = Invoke-JsonGate {
        & $privacyGate `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/privacy-clean-fixture') `
            -PatternsPath (Join-Path $repoRoot 'testdata/privacy-patterns.example.json') `
            -DryRun
    }
    if ($clean.passed -ne $true) {
        throw 'Privacy clean fixture should report passed=true.'
    }

    Write-Host 'Privacy gate passed.'
}

if ($Scope -in @('Context', 'Full')) {
    Invoke-ContextGate
}

if ($Scope -in @('ProdSafety', 'Full')) {
    Invoke-ProdSafetyGate
}

if ($Scope -in @('Release', 'Full')) {
    Invoke-ReleaseGate
}

if ($Scope -in @('Privacy', 'Full')) {
    Invoke-PrivacyGate
}
