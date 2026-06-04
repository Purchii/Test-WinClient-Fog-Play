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

The `QaDocsCommandSafety` quality gate fails if command-looking `run-*.ps1` examples in active QA docs lose `-DryRun` or show forbidden runtime allow flags, including TestabilityGaps production-action and runtime-user-data allow flags.

The `QaDocsCommandLocalPathSafety` quality gate fails if command-looking `run-*.ps1` examples in active QA docs use installed-client paths, user runtime paths, URLs, localhost/debug endpoints, WebView debug/CDP tokens or path arguments outside local `testdata` fixtures.

The `QaDocsPowerShellInvocationSafety` quality gate fails if command-looking `run-*.ps1` examples in active QA docs do not use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...` as the documented local PowerShell invocation shape.

The `QaDocsRunnerExampleCoverageSafety` quality gate fails if an active FrameworkInventorySafety runner/doc contract lacks a command-looking dry-run example for its local runner.

The `QualityGatesDocsScopeSafety` quality gate fails if the preferred `docs/context/engineering/quality-gates.md` command block drifts away from the exact `quality-gate.ps1 -Scope` inventory, gains duplicate scopes, lists unknown scopes, or if selected runner-scope and QA-doc safety summaries drift from `scripts/README.md`.

The `ActiveSafetyScopeInventorySafety` quality gate fails if any `*Safety` scope from `quality-gate.ps1` is missing from active handoff/current-state visibility.

The `ScriptsReadmeScopeSafety` quality gate fails if any `quality-gate.ps1 -Scope` value is missing from this script command inventory.

The `GovernanceHistoryScopeSafety` quality gate fails if any `*Safety` scope from `quality-gate.ps1` is missing from verification-memory or session-log history.

The `TestDataStructuredSyntaxSafety` quality gate fails if JSON fixtures under `testdata/` stop parsing or if the production resource budget YAML loses its required top-level shape.

The `QualityGateStructureSafety` quality gate fails if any `quality-gate.ps1 -Scope` value except `Full` is missing its matching `Invoke-<Scope>Gate` function or exact `Full` dispatch block, if runner rejection assertions regress to manual `*Rejected` flag blocks instead of `Assert-CommandRejected`, or if the shared rejection helper is missing or duplicated.

The `ActiveRunSafety` quality gate fails if the active handoff/current-state docs lose required stop-and-ask triggers, record stale literal latest-commit or live current-branch markers, declare a literal historical thread id as the active task thread, regress installed artifact observations into the current autonomous verification source in current-state or implementation-status, omit current static `*Safety` gates derived from `quality-gate.ps1`, let top-level/current branch-history/active-run Post-M6 status entries drift apart, omit implementation-status Post-M6 headings from those status entries, let active-run verification history blocks repeat commands within a block, or let the active milestone/latest-item markers drift from the latest verification-memory codex branch entry.

The `ContextDocsInventorySafety` quality gate fails if the `docs/context/*.md` handoff/governance/engineering inventory changes without updating the gate.

The `SessionLogSafety` quality gate fails if `docs/context/governance/session-log.md` codex branch entries lose `Mode:`, `Branch:`, `Scope:`, `Safety:` or core no-runtime/no-production safety notes, if codex branch entries describe a previous source/coordinator thread as still active, if the most recent codex branch entry loses discovery-thread lifecycle wording for same-thread selected-task delivery or inactive delegated discovery, or if the latest session-log codex entry title or branch stops matching the latest `docs/context/engineering/verification-memory.md` codex entry title or branch.

The `VerificationMemorySafety` quality gate fails if `docs/context/engineering/verification-memory.md` codex branch entries keep pending markers; lose status, production impact, command or result evidence; omit `Not run:` for no-impact static/local-static entries; lose installed artifact historical command boundaries; or if the latest codex branch entry loses core safety notes.

The `ActiveVerificationCommandSafety` quality gate fails if active/current verification command evidence in `active-run.md` Last verification or the most recent `verification-memory.md` Commands block drifts beyond local/static `quality-gate.ps1` or safe git checks, repeats a command within one source block, or includes installed-client paths, user runtime paths, URLs, localhost/debug/CDP references, direct runners, auth/network/session/update/dependency, TestabilityGaps production-action/runtime-user-data allow flags or CI commands.

The `ChecklistSafety` quality gate fails if executor or context integrity checklists lose required thread isolation, verification, stop-trigger, secrets or production-impact checklist items.

The `DecisionsLogSafety` quality gate fails if durable decisions lose accepted status or core production-safety, autonomy, thread isolation, discovery-thread selected-task delivery, bounded autonomous continuation handoff, push/merge authority and process-error rules.

The `CodexPolicySafety` quality gate fails if Codex or executor policy docs lose autonomy, thread isolation, thread-title-to-task-branch naming, discovery-thread selected-task delivery, bounded autonomous continuation handoff, production-impact, credential, CI/CD, main-merge or game-session boundaries.

The `TaskRequestSafety` quality gate fails if task request template/log docs lose bounded-goal fields, thread lifecycle, thread-title-to-task-branch naming, bounded autonomous continuation handoff, production classification, verification or stop-condition requirements.

The `CodexTemplateSafety` quality gate fails if Codex review/task/communication/agent-role docs lose reporting, role separation, verification, production classification, stop-trigger, secret or no-main-merge requirements.

The `CodexGoalTemplateSafety` quality gate fails if the Codex goal template loses execution mode, scope, forbidden action, acceptance criteria, verification or stop-condition requirements.

The `CodexDocsInventorySafety` quality gate fails if the `docs/codex/*.md` policy/template inventory changes without updating the gate.

The `QaStrategySafety` quality gate fails if QA strategy, testability contract or flakiness policy docs lose layered test order, no-broad-E2E guidance, WebView debug defaults, runtime gap tracking or retry/session-budget rules.

The `HandoffProtocolSafety` quality gate fails if `AGENTS.md`, context protocol or Git workflow docs lose source-of-truth ordering, latest-commit handling, thread isolation, thread-title-to-task-branch naming, bounded autonomous continuation handoff, worktree fallback, local verification or main-merge approval rules.

The `IncomingReferenceSafety` quality gate fails if `docs/_incoming_reference` inventory changes silently or if incoming reference docs are no longer marked reference-only rather than active scope.

The `FrameworkInventorySafety` quality gate fails if implemented TestFramework modules lose matching tests, local runners, QA docs or example/unsafe fixtures.

The `TestFrameworkInventorySafety` quality gate fails if the `src/TestFramework` file inventory changes without updating the gate.

The `IncidentStopSafety` quality gate fails if stop triggers drift out of `docs/qa/incident-stop-policy.md`, active handoff, or testability gap fixtures.

The `QaDocsSafety` quality gate fails if the required `docs/qa/*.md` policy inventory changes without updating the gate, if core safety phrases, release/privacy M1.1 hardening notes, Post-M6 finding coverage summaries including detailed AppSmoke/BackendSmoke/WebViewBridge finding coverage wording, AppSmoke/BackendSmoke/release/privacy runner hardening notes or release/privacy/AppSmoke report-only coverage notes are removed, or if installed artifact defaults in active QA docs lose the manual/explicit-plan and local-fixture autonomous verification boundary.

The `ArtifactPolicySafety` quality gate fails if release/privacy policy fixtures lose required files, forbidden extensions, finding ids, privacy patterns, expected privacy pattern severities or bounded scan limits.

The `ContractFixtureSafety` quality gate fails if backend, update manifest or WebView bridge fixtures lose dry-run flags, read-only/local-only constraints, package integrity metadata or bridge safety vocabulary.

The `StaticSurfaceSafety` quality gate fails if App/WebView smoke or non-prod foundation fixtures lose static layout requirements, WebView bundle inventory, dry-run flags, schema-only non-runtime constraints or required contract properties.

The `WebViewBundleLocalReferenceSafety` quality gate fails if fixture WebView bundle entrypoints or asset manifests include remote URLs, localhost/debug/CDP references, user runtime paths, production endpoints or non-local manifest paths.

The `FixtureInventorySafety` quality gate fails if release, privacy or App/WebView smoke fixture directory trees lose required positive, negative or clean local fixture files.

The `ScriptsInventorySafety` quality gate fails if the `scripts/` runner/support file inventory changes without updating the gate.

The `RunnerSafety` quality gate fails if a `run-*.ps1` runner loses `-DryRun`, stops rejecting missing `-DryRun`, exposes an unguarded dangerous `Allow*` switch, accepts path-like inputs without unsafe runtime input path guards, or introduces forbidden runtime/network primitives.

The `TestDataSafety` quality gate fails if risky fixture content is added outside the explicit unsafe/negative fixture allowlist.

The `TestDataInventorySafety` quality gate fails if the `testdata/` fixture file inventory changes without updating the gate.

The `UnsafeFixtureCoverageSafety` quality gate fails if any `testdata/*unsafe*.example.json` fixture is missing a static negative coverage contract with the fixture path and expected `Assert-FindingId` finding-id assertions in the corresponding TestFramework test or `quality-gate.ps1` scope.

The `SyntheticUsersSafety` quality gate statically checks `testdata/synthetic-users.example.json`, the resource budget fixture and the synthetic users policy so allowlisted users remain alias-only, contain no credential-like fields or values, reserve game-session permission for bounded canary aliases and keep canary user duration within the resource budget.

The `AllowedGamesSafety` quality gate statically checks `testdata/allowed-games.example.json` and the game-session canary policy so production canary games remain alias-only QA entries with bounded `allowedFor` purposes.

The `ResourceBudgetSafety` quality gate statically checks `testdata/prod-resource-budget.example.yaml`, `testdata/allowed-games.example.json` and the resource budget policy so production canary budgets stay single-session, short-duration, cleanup-gated and tied to allowlisted QA game aliases.

The `ProdMetadataSafety` quality gate statically checks `testdata/prod-safety-tests.example.json`, `testdata/synthetic-users.example.json`, production guard allowlist fixtures and the production testing policy so runner suites keep the expected classifications, allowlisted synthetic aliases, canary alias duration budget, target metadata and session/cleanup flags.

The `ProdMatrixSafety` quality gate statically checks `docs/qa/prod-safe-test-matrix.md` so scenario classifications stay within allowed production-safety values, session/stream scenarios are not marked `PROD_SAFE`, and forbidden production scenarios document `NON_PROD_ONLY` handling.

The `BacklogSafety` quality gate statically checks `docs/qa/value-effort-backlog.md` so roadmap rows stay bounded to M0-M6, value/effort stay in the 1-5 range, and runtime/non-prod milestones remain lower priority until prerequisites are approved.

The `ProdSafety` quality gate validates local production-safety guard metadata without launching the client, authenticating or starting sessions, and asserts prod-safe smoke and prod canary runners reject missing `-DryRun`, unsafe runtime metadata, synthetic-user and resource-budget input paths before any read.

The `Release` quality gate validates local release artifact fixtures without launching the installed client, asserts fail-closed negative fixture behavior, asserts `-ReportOnly` explicit artifact discovery behavior, and asserts that unsafe runtime `ArtifactRoot` and `PolicyPath` input paths are rejected before any read or probe.

The `Privacy` quality gate validates local privacy/logging fixtures without launching the installed client, asserts fail-closed negative fixture behavior, asserts `-ReportOnly` explicit artifact discovery behavior, and asserts that unsafe runtime `ArtifactRoot` and `PatternsPath` input paths are rejected before any read or probe.

The `AppSmoke` quality gate validates the local App/WebView smoke scaffold without launching the installed client, asserts static WebView bundle failure finding ids, and asserts that unsafe runtime input paths, `-AllowClientLaunch` and `-AllowWebViewDebugPort` are rejected.

The `BridgeContract` quality gate validates the local WebView/native bridge contract scaffold without WebView debug/CDP or client launch, asserts structural bridge command/event/fake-host finding ids, and asserts that unsafe runtime input paths, unsafe bridge logging policies, `-AllowClientLaunch` and `-AllowWebViewDebugPort` are rejected.

The `BackendSmoke` quality gate validates the local backend smoke contract scaffold without network calls, auth headers or production backend interaction, asserts structural endpoint finding ids, and asserts that unsafe runtime input paths, unsafe endpoint paths, missing mock responses, `-AllowNetwork` and `-AllowAuth` are rejected.

The `GameSessionCanary` quality gate validates the local dry-run canary readiness plan without starting or stopping a game session, requires exactly one canary, exact non-duplicated canary readiness signals, exact non-duplicated canary suite metadata, explicit game-session/state-mutation intent metadata, empty runtime path requests, an allowlisted production canary synthetic alias, matching synthetic-user duration ceiling, single-session concurrency, bounded run-frequency budget, allowlisted target region and cleanup/conditional budget flags in the direct plan validator, and asserts that unsafe runtime input paths, unsafe conditional-flag budget drift, `-AllowClientLaunch`, `-AllowNetwork` and `-AllowAuth` are rejected.

The `NonProdFoundation` quality gate validates future fake/replay/network/hardware placeholder schemas without executing those systems, asserts structural component finding ids including missing required contract properties, and asserts that unsafe runtime input paths, missing `-DryRun`, `-AllowExecution`, `-AllowNetwork` and `-AllowAuth` are rejected.

The `TestabilityGaps` quality gate validates the local testability gap registry without closing runtime gaps, asserts local gap metadata finding ids, and asserts that unsafe runtime input paths, missing `-DryRun`, unsafe next-safe-step text, `-AllowProductionAction`, `-AllowCredentials` and `-AllowRuntimeUserData` are rejected.

The `UpdateManifest` quality gate validates the local update manifest fixture without network, updater execution, rollback or credentials, asserts structural package finding ids, and asserts that unsafe runtime input paths, missing `-DryRun`, `-AllowNetwork`, `-AllowExecution`, `-AllowRollback` and `-AllowCredentials` are rejected.
