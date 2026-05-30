# Scripts

Implemented local runners:

```text
quality-gate.ps1
run-app-webview-smoke.ps1
run-backend-smoke.ps1
run-game-session-canary.ps1
run-nonprod-foundation.ps1
run-privacy-gate.ps1
run-prod-canary.ps1
run-prod-safe-smoke.ps1
run-release-gate.ps1
run-testability-gaps.ps1
run-update-manifest-gate.ps1
run-webview-bridge-contract.ps1
```

These runners are guard/dry-run first. They must not launch the Windows client, enable WebView debug/CDP, authenticate, start a game session, call production backend or streaming services, mutate production state, read user AppData/logs/cookies/DB/dumps, enable CI/CD, or change dependencies by default.

Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...` on machines where local script execution is restricted by PowerShell policy.

The `Context` quality gate fails if this inventory stops listing any `scripts/*.ps1` runner.

The `Context` quality gate also fails if any `quality-gate.ps1 -Scope` value is documented but not wired into the `Full` dispatch.

The `RepositoryRootInventorySafety` quality gate fails if the repository-root file or directory inventory changes without updating the gate.

The `RootPromptSafety` quality gate fails if top-level Codex prompt/TZ documents lose source-of-truth wording, autonomy-mode boundaries, production-impact stop rules or game-session/credential guard prerequisites.

The `ProdSafetyFrameworkSafety` quality gate fails if the ProdSafety README, module exports or regression assertion text lose the core classification, kill switch, synthetic user, resource budget or cleanup guard contract.

The `ScriptEncodingSafety` quality gate fails if any `scripts/*.ps1` file gains a UTF-8 BOM or non-ASCII bytes that can make Windows PowerShell parsing brittle.

The `PowerShellStructuredSyntaxSafety` quality gate fails if any local PowerShell file in `scripts/*.ps1`, `src/TestFramework/**/*.ps1` or `src/TestFramework/**/*.psm1` has parser syntax errors under `[System.Management.Automation.Language.Parser]::ParseFile(...)`.

The `BinaryFixturePlaceholderSafety` quality gate fails if binary-like files under `testdata/` stop being tiny placeholders, gain a real PE header, or introduce dump/database/debug extensions outside the approved fixture inventory.

The `QaDocsCommandSafety` quality gate fails if command-looking `run-*.ps1` examples in active QA docs lose `-DryRun` or show forbidden runtime allow flags.

The `QaDocsPowerShellInvocationSafety` quality gate fails if command-looking `run-*.ps1` examples in active QA docs do not use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...` as the documented local PowerShell invocation shape.

The `QaDocsRunnerExampleCoverageSafety` quality gate fails if an active FrameworkInventorySafety runner/doc contract lacks a command-looking dry-run example for its local runner.

The `QualityGatesDocsScopeSafety` quality gate fails if the preferred `docs/context/engineering/quality-gates.md` command block drifts away from the exact `quality-gate.ps1 -Scope` inventory, gains duplicate scopes or lists unknown scopes.

The `ActiveSafetyScopeInventorySafety` quality gate fails if any `*Safety` scope from `quality-gate.ps1` is missing from active handoff/current-state visibility.

The `ScriptsReadmeScopeSafety` quality gate fails if any `quality-gate.ps1 -Scope` value is missing from this script command inventory.

The `GovernanceHistoryScopeSafety` quality gate fails if any `*Safety` scope from `quality-gate.ps1` is missing from verification-memory or session-log history.

The `TestDataStructuredSyntaxSafety` quality gate fails if JSON fixtures under `testdata/` stop parsing or if the production resource budget YAML loses its required top-level shape.

The `QualityGateStructureSafety` quality gate fails if any `quality-gate.ps1 -Scope` value except `Full` is missing its matching `Invoke-<Scope>Gate` function or exact `Full` dispatch block.

The `ActiveRunSafety` quality gate fails if the active handoff/current-state docs lose required stop-and-ask triggers, record stale literal latest-commit markers, or omit current static safety gates.

The `ContextDocsInventorySafety` quality gate fails if the `docs/context/*.md` handoff/governance/engineering inventory changes without updating the gate.

The `SessionLogSafety` quality gate fails if guarded session-log branch entries lose their mode, branch, scope or core no-runtime/no-production safety notes.

The `VerificationMemorySafety` quality gate fails if verification-memory entries for codex branches keep pending markers or lose status, production impact, command or result evidence.

The `ChecklistSafety` quality gate fails if executor or context integrity checklists lose required thread isolation, verification, stop-trigger, secrets or production-impact checklist items.

The `DecisionsLogSafety` quality gate fails if durable decisions lose accepted status or core production-safety, autonomy, thread isolation, push/merge authority and process-error rules.

The `CodexPolicySafety` quality gate fails if Codex or executor policy docs lose autonomy, thread isolation, production-impact, credential, CI/CD, main-merge or game-session boundaries.

The `TaskRequestSafety` quality gate fails if task request template/log docs lose bounded-goal fields, production classification, verification or stop-condition requirements.

The `CodexTemplateSafety` quality gate fails if Codex review/task/communication/agent-role docs lose reporting, role separation, verification, production classification, stop-trigger, secret or no-main-merge requirements.

The `CodexGoalTemplateSafety` quality gate fails if the Codex goal template loses execution mode, scope, forbidden action, acceptance criteria, verification or stop-condition requirements.

The `CodexDocsInventorySafety` quality gate fails if the `docs/codex/*.md` policy/template inventory changes without updating the gate.

The `QaStrategySafety` quality gate fails if QA strategy, testability contract or flakiness policy docs lose layered test order, no-broad-E2E guidance, WebView debug defaults, runtime gap tracking or retry/session-budget rules.

The `HandoffProtocolSafety` quality gate fails if context protocol or Git workflow docs lose source-of-truth ordering, latest-commit handling, thread isolation, worktree fallback, local verification or main-merge approval rules.

The `IncomingReferenceSafety` quality gate fails if `docs/_incoming_reference` inventory changes silently or if incoming reference docs are no longer marked reference-only rather than active scope.

The `FrameworkInventorySafety` quality gate fails if implemented TestFramework modules lose matching tests, local runners, QA docs or example/unsafe fixtures.

The `TestFrameworkInventorySafety` quality gate fails if the `src/TestFramework` file inventory changes without updating the gate.

The `IncidentStopSafety` quality gate fails if stop triggers drift out of `docs/qa/incident-stop-policy.md`, active handoff, or testability gap fixtures.

The `QaDocsSafety` quality gate fails if the required `docs/qa/*.md` policy inventory changes without updating the gate, or if core safety phrases are removed.

The `ArtifactPolicySafety` quality gate fails if release/privacy policy fixtures lose required files, forbidden extensions, finding ids, privacy patterns or bounded scan limits.

The `ContractFixtureSafety` quality gate fails if backend, update manifest or WebView bridge fixtures lose dry-run flags, read-only/local-only constraints, package integrity metadata or bridge safety vocabulary.

The `StaticSurfaceSafety` quality gate fails if App/WebView smoke or non-prod foundation fixtures lose static layout requirements, WebView bundle inventory, dry-run flags or schema-only non-runtime constraints.

The `WebViewBundleLocalReferenceSafety` quality gate fails if fixture WebView bundle entrypoints or asset manifests include remote URLs, localhost/debug/CDP references, user runtime paths, production endpoints or non-local manifest paths.

The `FixtureInventorySafety` quality gate fails if release, privacy or App/WebView smoke fixture directory trees lose required positive, negative or clean local fixture files.

The `ScriptsInventorySafety` quality gate fails if the `scripts/` runner/support file inventory changes without updating the gate.

The `RunnerSafety` quality gate fails if a `run-*.ps1` runner loses `-DryRun`, stops rejecting missing `-DryRun`, exposes an unguarded dangerous `Allow*` switch, or introduces forbidden runtime/network primitives.

The `TestDataSafety` quality gate fails if risky fixture content is added outside the explicit unsafe/negative fixture allowlist.

The `TestDataInventorySafety` quality gate fails if the `testdata/` fixture file inventory changes without updating the gate.

The `UnsafeFixtureCoverageSafety` quality gate fails if any `testdata/*unsafe*.example.json` fixture is missing a static negative coverage contract with the fixture path and expected `Assert-FindingId` finding-id assertions in the corresponding TestFramework test or `quality-gate.ps1` scope.

The `SyntheticUsersSafety` quality gate fails if the synthetic users fixture stops being alias-only, gains credential-like data, or grants game-session permission outside bounded canary aliases.

The `AllowedGamesSafety` quality gate fails if the allowed-games fixture stops being alias-only, gains real game metadata, or allows purposes outside the production canary plan.

The `ResourceBudgetSafety` quality gate fails if the production resource budget stops being single-session, short-duration, cleanup-gated, explicitly conditional, or tied to production canary game aliases.

The `ProdMetadataSafety` quality gate fails if production test metadata suites drift away from their required classifications, aliases, targets or session/cleanup flags.

The `ProdMatrixSafety` quality gate fails if the production-safe test matrix drifts into unsafe classifications.

The `BacklogSafety` quality gate fails if the value/effort backlog drifts out of the approved M0-M6 roadmap shape.

The `AppSmoke` quality gate validates the local App/WebView smoke scaffold and dangerous flag rejection without launching the installed client.

The `BridgeContract` quality gate validates the local WebView/native bridge contract scaffold without WebView debug/CDP or client launch.

The `BackendSmoke` quality gate validates the local backend smoke contract scaffold without network calls, auth headers or production backend interaction.

The `GameSessionCanary` quality gate validates the local dry-run canary readiness plan without starting or stopping a game session.

The `NonProdFoundation` quality gate validates future fake/replay/network/hardware placeholder schemas without executing those systems.

The `UpdateManifest` quality gate validates the local update manifest fixture without network, updater execution, rollback or credentials.

The `TestabilityGaps` quality gate validates the local testability gap registry without closing gaps through runtime actions.
