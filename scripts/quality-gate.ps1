param(
    [ValidateSet('Context', 'ProdSafety', 'Release', 'Privacy', 'AppSmoke', 'BridgeContract', 'BackendSmoke', 'GameSessionCanary', 'Full')]
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

function Invoke-AppSmokeGate {
    $required = @(
        'docs/qa/app-webview-smoke.md',
        'src/TestFramework/WindowsSmoke/WindowsSmoke.psm1',
        'src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1',
        'scripts/run-app-webview-smoke.ps1',
        'testdata/app-webview-smoke.example.json',
        'testdata/app-webview-smoke-unsafe-policy.example.json',
        'testdata/app-webview-smoke-fixture'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1')

    $appSmoke = Join-Path $repoRoot 'scripts/run-app-webview-smoke.ps1'
    $result = Invoke-JsonGate {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'App/WebView smoke fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.debugPortUsed -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false) {
        throw 'App/WebView smoke dry-run must report no process/debug/auth/game activity.'
    }

    $negative = Invoke-JsonGate {
        & $appSmoke `
            -ArtifactRoot (Join-Path $repoRoot 'testdata/app-webview-smoke-fixture') `
            -PolicyPath (Join-Path $repoRoot 'testdata/app-webview-smoke-unsafe-policy.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'unsafe-launch-argument'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'

    Write-Host 'AppSmoke gate passed.'
}

function Invoke-BridgeContractGate {
    $required = @(
        'docs/qa/webview-bridge-contract.md',
        'src/TestFramework/WebViewBridge/WebViewBridge.psm1',
        'src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1',
        'scripts/run-webview-bridge-contract.ps1',
        'testdata/webview-bridge-contract.example.json',
        'testdata/webview-bridge-contract-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1')

    $bridgeContract = Join-Path $repoRoot 'scripts/run-webview-bridge-contract.ps1'
    $result = Invoke-JsonGate {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'WebView bridge contract fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.debugPortUsed -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.readRuntimeUserData -ne $false) {
        throw 'WebView bridge contract dry-run must report no process/debug/auth/game/runtime-data activity.'
    }

    $negative = Invoke-JsonGate {
        & $bridgeContract `
            -ContractPath (Join-Path $repoRoot 'testdata/webview-bridge-contract-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'unsafe-diagnostic'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'

    Write-Host 'BridgeContract gate passed.'
}

function Invoke-BackendSmokeGate {
    $required = @(
        'docs/qa/backend-smoke.md',
        'src/TestFramework/BackendSmoke/BackendSmoke.psm1',
        'src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1',
        'scripts/run-backend-smoke.ps1',
        'testdata/backend-smoke.example.json',
        'testdata/backend-smoke-unsafe.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1')

    $backendSmoke = Join-Path $repoRoot 'scripts/run-backend-smoke.ps1'
    $result = Invoke-JsonGate {
        & $backendSmoke `
            -PolicyPath (Join-Path $repoRoot 'testdata/backend-smoke.example.json') `
            -DryRun
    }

    if ($result.passed -ne $true) {
        throw 'Backend smoke fixture should pass.'
    }
    if ($result.networkCallAttempted -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.readRuntimeUserData -ne $false -or $result.mutatingRequestAttempted -ne $false) {
        throw 'Backend smoke dry-run must report no network/auth/game/runtime-data/mutation activity.'
    }

    $negative = Invoke-JsonGate {
        & $backendSmoke `
            -PolicyPath (Join-Path $repoRoot 'testdata/backend-smoke-unsafe.example.json') `
            -DryRun `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'network-not-disabled'
    Assert-FindingId -Result $negative -Id 'unsafe-header'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'
    Assert-FindingId -Result $negative -Id 'state-mutating-endpoint'

    Write-Host 'BackendSmoke gate passed.'
}

function Invoke-GameSessionCanaryGate {
    $required = @(
        'docs/qa/game-session-canary.md',
        'src/TestFramework/GameSessionCanary/GameSessionCanary.psm1',
        'src/TestFramework/GameSessionCanary/GameSessionCanary.Tests.ps1',
        'scripts/run-game-session-canary.ps1',
        'testdata/game-session-canary.example.json',
        'testdata/game-session-canary-unsafe.example.json',
        'testdata/allowed-games.example.json'
    )

    foreach ($item in $required) {
        Assert-PathExists $item
    }

    & (Join-Path $repoRoot 'src/TestFramework/GameSessionCanary/GameSessionCanary.Tests.ps1')

    $gameSessionCanary = Join-Path $repoRoot 'scripts/run-game-session-canary.ps1'
    $missingFlagRejected = $false
    try {
        & $gameSessionCanary `
            -PlanPath (Join-Path $repoRoot 'testdata/game-session-canary.example.json') `
            -DryRun `
            -CleanupVerified | Out-Null
    }
    catch {
        $missingFlagRejected = $true
    }
    if (-not $missingFlagRejected) {
        throw 'Game-session canary runner must reject PROD_CONDITIONAL runs without -AllowProdConditional.'
    }

    $result = Invoke-JsonGate {
        & $gameSessionCanary `
            -PlanPath (Join-Path $repoRoot 'testdata/game-session-canary.example.json') `
            -DryRun `
            -AllowProdConditional `
            -CleanupVerified
    }

    if ($result.passed -ne $true) {
        throw 'Game-session canary readiness fixture should pass.'
    }
    if ($result.processStarted -ne $false -or $result.networkCallAttempted -ne $false -or $result.authAttempted -ne $false -or $result.gameSessionStarted -ne $false -or $result.cleanupAttempted -ne $false -or $result.readRuntimeUserData -ne $false) {
        throw 'Game-session canary dry-run must report no process/network/auth/game/cleanup/runtime-data activity.'
    }

    $negative = Invoke-JsonGate {
        & $gameSessionCanary `
            -PlanPath (Join-Path $repoRoot 'testdata/game-session-canary-unsafe.example.json') `
            -DryRun `
            -AllowProdConditional `
            -CleanupVerified `
            -ReportOnly
    }
    Assert-FindingId -Result $negative -Id 'policy-not-dry-run-only'
    Assert-FindingId -Result $negative -Id 'execution-not-disabled'
    Assert-FindingId -Result $negative -Id 'client-launch-not-disabled'
    Assert-FindingId -Result $negative -Id 'network-not-disabled'
    Assert-FindingId -Result $negative -Id 'auth-not-disabled'
    Assert-FindingId -Result $negative -Id 'unsafe-runtime-path'
    Assert-FindingId -Result $negative -Id 'non-prod-conditional-canary'
    Assert-FindingId -Result $negative -Id 'cleanup-not-required'
    Assert-FindingId -Result $negative -Id 'duration-exceeds-budget'
    Assert-FindingId -Result $negative -Id 'game-not-allowlisted'
    Assert-FindingId -Result $negative -Id 'uncontrolled-retries'
    Assert-FindingId -Result $negative -Id 'missing-readiness-signals'

    Write-Host 'GameSessionCanary gate passed.'
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

if ($Scope -in @('AppSmoke', 'Full')) {
    Invoke-AppSmokeGate
}

if ($Scope -in @('BridgeContract', 'Full')) {
    Invoke-BridgeContractGate
}

if ($Scope -in @('BackendSmoke', 'Full')) {
    Invoke-BackendSmokeGate
}

if ($Scope -in @('GameSessionCanary', 'Full')) {
    Invoke-GameSessionCanaryGate
}
