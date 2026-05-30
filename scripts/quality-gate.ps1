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

if ($Scope -in @('Context', 'Full')) {
    Invoke-ContextGate
}

if ($Scope -in @('ProdSafety', 'Full')) {
    Invoke-ProdSafetyGate
}

if ($Scope -in @('Release', 'Full')) {
    Invoke-StubGate -Name 'Release'
}

if ($Scope -in @('Privacy', 'Full')) {
    Invoke-StubGate -Name 'Privacy'
}
