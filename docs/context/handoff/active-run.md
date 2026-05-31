# Active run

Status: Post-M6 static safety gates implemented and verified locally.

Execution mode: autonomous local-safe hardening after explicit user approval to work autonomously and push to `main`.

Current milestone: Post-M6 local/static safety gate hardening complete through VerificationMemorySafety.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current roadmap M0-M6 has local/dry-run foundations implemented through M6.
Post-M6 QualityGateStructureSafety static gate is complete.
Post-M6 TestDataStructuredSyntaxSafety static gate is complete.
Post-M6 GovernanceHistoryScopeSafety static gate is complete.
Post-M6 ScriptsReadmeScopeSafety static gate is complete.
Post-M6 ActiveSafetyScopeInventorySafety static gate is complete.
Post-M6 QaDocsCommandSafety static gate is complete.
Post-M6 QaDocsCommandSafety TestabilityGaps allow-flag hardening is complete.
Post-M6 QaDocsCommandSafety TestabilityGaps allow-flag implementation-status sync is complete.
Post-M6 QaDocsCommandLocalPathSafety static gate is complete.
Post-M6 QaDocsPowerShellInvocationSafety static gate is complete.
Post-M6 QaDocsRunnerExampleCoverageSafety static gate is complete.
Post-M6 QualityGatesDocsScopeSafety static gate is complete.
Post-M6 BinaryFixturePlaceholderSafety static gate is complete.
Post-M6 ScriptEncodingSafety static gate is complete.
Post-M6 PowerShellStructuredSyntaxSafety static gate is complete.
Post-M6 ProdSafetyFrameworkSafety static gate is complete.
Post-M6 RootPromptSafety static gate is complete.
Post-M6 RepositoryRootInventorySafety static gate is complete.
Post-M6 update manifest hardening is complete.
Post-M6 testability gaps registry is complete.
Post-M6 script inventory guard hardening is complete.
Post-M6 M1 dry-run fail-closed hardening is complete.
Post-M6 runner/validator guard hardening is complete.
Post-M6 dangerous flag negative coverage is complete.
Post-M6 RunnerSafety static gate is complete.
Post-M6 TestDataSafety static gate is complete.
Post-M6 TestDataInventorySafety static gate is complete.
Post-M6 quality gate scope inventory guard is complete.
Post-M6 ProdMatrixSafety static gate is complete.
Post-M6 BacklogSafety static gate is complete.
Post-M6 SyntheticUsersSafety static gate is complete.
Post-M6 ResourceBudgetSafety static gate is complete.
Post-M6 AllowedGamesSafety static gate is complete.
Post-M6 ProdMetadataSafety static gate is complete.
Post-M6 ContextDocsInventorySafety static gate is complete.
Post-M6 SessionLogSafety static gate is complete.
Post-M6 VerificationMemorySafety static gate is complete.
Post-M6 ActiveVerificationCommandSafety static gate is complete.
Post-M6 ActiveVerificationCommandSafety TestabilityGaps allow-flag hardening is complete.
Post-M6 ChecklistSafety static gate is complete.
Post-M6 DecisionsLogSafety static gate is complete.
Post-M6 CodexPolicySafety static gate is complete.
Post-M6 TaskRequestSafety static gate is complete.
Post-M6 CodexTemplateSafety static gate is complete.
Post-M6 CodexGoalTemplateSafety static gate is complete.
Post-M6 CodexDocsInventorySafety static gate is complete.
Post-M6 QaStrategySafety static gate is complete.
Post-M6 HandoffProtocolSafety static gate is complete.
Post-M6 IncomingReferenceSafety static gate is complete.
Post-M6 FrameworkInventorySafety static gate is complete.
Post-M6 TestFrameworkInventorySafety static gate is complete.
Post-M6 IncidentStopSafety static gate is complete.
Post-M6 QaDocsSafety static gate is complete.
Post-M6 ArtifactPolicySafety static gate is complete.
Post-M6 ContractFixtureSafety static gate is complete.
Post-M6 StaticSurfaceSafety static gate is complete.
Post-M6 WebViewBundleLocalReferenceSafety static gate is complete.
Post-M6 FixtureInventorySafety static gate is complete.
Post-M6 ScriptsInventorySafety static gate is complete.
Post-M6 UnsafeFixtureCoverageSafety static gate is complete.
Post-M6 GameSessionCanary conditional flag unsafe coverage hardening is complete.
Future execution milestones require their own NON_AUTONOMOUS planning step in a separate thread.
Post-M6 ProdMetadataSafety canary target allowlist hardening is complete.
Post-M6 ProdMetadataSafety synthetic alias allowlist hardening is complete.
Post-M6 SyntheticUsersSafety resource budget duration hardening is complete.
Post-M6 ProdMetadataSafety canary alias duration hardening is complete.
Post-M6 ProdMetadataSafety canary alias duration policy phrase hardening is complete.
Post-M6 GameSessionCanary synthetic alias direct validator hardening is complete.
Post-M6 GameSessionCanary synthetic alias allowlist hardening is complete.
Post-M6 GameSessionCanary synthetic alias duration hardening is complete.
Post-M6 GameSessionCanary synthetic alias environment hardening is complete.
Post-M6 GameSessionCanary run-frequency budget hardening is complete.
Post-M6 GameSessionCanary resource-budget policy flag hardening is complete.
Post-M6 GameSessionCanary suite metadata hardening is complete.
Post-M6 GameSessionCanary readiness signal allowlist hardening is complete.
Post-M6 GameSessionCanary readiness signal uniqueness hardening is complete.
Post-M6 GameSessionCanary runtime path empty-list hardening is complete.
Post-M6 GameSessionCanary suite metadata exact-set hardening is complete.
Post-M6 GameSessionCanary unsafe fixture finding coverage hardening is complete.
Post-M6 GameSessionCanary runner input path safety hardening is complete.
Post-M6 GameSessionCanary remaining finding coverage hardening is complete.
Post-M6 GameSessionCanary/WebViewBridge QA docs finding coverage sync is complete.
Post-M6 NonProdFoundation runner input path safety hardening is complete.
Post-M6 TestabilityGaps runner input path safety hardening is complete.
Post-M6 UpdateManifest runner input path safety hardening is complete.
Post-M6 UpdateManifest structural package finding coverage hardening is complete.
Post-M6 BackendSmoke runner input path safety hardening is complete.
Post-M6 BackendSmoke unsafe endpoint coverage hardening is complete.
Post-M6 BackendSmoke structural endpoint finding coverage hardening is complete.
Post-M6 WebViewBridge runner input path safety hardening is complete.
Post-M6 WebViewBridge unsafe logging policy coverage hardening is complete.
Post-M6 WebViewBridge structural finding coverage hardening is complete.
Post-M6 WebViewBridge remaining finding coverage hardening is complete.
Post-M6 AppSmoke runner input path safety hardening is complete.
Post-M6 AppSmoke static fixture finding coverage hardening is complete.
Post-M6 NonProdFoundation structural finding coverage hardening is complete.
Post-M6 Release runner input path safety hardening is complete.
Post-M6 Privacy runner input path safety hardening is complete.
Post-M6 ProdSafeSmoke runner input path safety hardening is complete.
Post-M6 ProdCanary runner input path safety hardening is complete.
Post-M6 RunnerSafety input path coverage hardening is complete.
Post-M6 TestabilityGaps next-safe-step vocabulary hardening is complete.
Post-M6 TestabilityGaps local finding coverage hardening is complete.
Post-M6 Structural finding QA docs coverage sync is complete.
Post-M6 Scripts Readme Scope Safety TestabilityGaps duplicate cleanup is complete.
Post-M6 QaDocsSafety finding coverage wording guard is complete.
Post-M6 QaDocsSafety detailed finding coverage wording guard is complete.
Post-M6 QaDocsSafety release/privacy hardening wording guard is complete.
Post-M6 QaDocsSafety release/privacy M1.1 hardening wording guard is complete.
Post-M6 Release/Privacy report-only local coverage hardening is complete.
Post-M6 QaDocsSafety release/privacy report-only coverage wording guard is complete.
Post-M6 Privacy pattern finding coverage hardening is complete.
Post-M6 QualityGatesDocsScopeSafety input path summary sync is complete.
Post-M6 RunnerSafety implementation-status input path sync is complete.
Post-M6 ActiveRunSafety current-state installed artifact wording sync is complete.
Post-M6 ActiveRunSafety installed artifact source wording guard is complete.
Post-M6 Implementation-status M1 installed artifact history wording sync is complete.
Post-M6 ActiveRunSafety implementation-status installed artifact source wording guard is complete.
Post-M6 QA docs installed artifact manual-boundary wording sync is complete.
Post-M6 QaDocsSafety installed artifact manual-boundary wording guard is complete.
Post-M6 VerificationMemorySafety installed artifact historical command boundary is complete.
Autonomous time extension, push permission or merge permission does not waive thread-per-task.
Each newly selected follow-up gate, hardening item, feature slice or backlog item requires a new Codex thread unless it only repairs verification for the current task.
Each dedicated task thread is active only for its own task and becomes inactive/history-only after handoff, completion or takeover. Old source, coordinator and delegated task threads are preserved for history, are not deleted, are not archived automatically unless the user explicitly asks, and must not be used to implement new independent tasks. Previous source thread `019e793c-4e53-7be0-90c7-10ff5a02c8b1` became inactive/history-only after handoff to `019e7aab-dbaf-70d0-b143-ed7e6eb0bde0`.
```

Current branch/status source:

```text
Use `git status --short --branch` as the authoritative current branch/worktree source. Do not store a live literal branch name here; task branch history belongs in verification-memory and session-log entries.
```

Current result:

```text
BackendSmoke unsafe endpoint coverage hardening requires the unsafe backend smoke fixture, unit tests and quality gate to cover unsafe endpoint path and missing mock response findings.

BackendSmoke structural endpoint finding coverage hardening requires local tests to assert invalid endpoint name, non-`PROD_SAFE` endpoint classification and missing endpoint registry finding ids without making backend calls.

WebViewBridge unsafe logging policy coverage hardening requires the unsafe bridge contract fixture, unit tests and quality gate to cover unsafe command/event logging policy findings.

WebViewBridge structural finding coverage hardening requires local tests to assert invalid/duplicate command names, missing command effect/error behavior, missing event payload/error behavior and missing command/event registry finding ids without launching the client or enabling WebView debug/CDP.

WebViewBridge remaining finding coverage hardening requires local tests to assert invalid command direction, missing command/event production-safety metadata, invalid/duplicate event names and fake native host case validation finding ids without launching the client or enabling WebView debug/CDP.

GameSessionCanary/WebViewBridge QA docs finding coverage sync keeps active QA docs aligned with the latest local direct finding assertions without adding any runtime, auth, network, installed-client or game-session steps.

Structural finding QA docs coverage sync keeps AppSmoke, BackendSmoke, UpdateManifest, NonProdFoundation and TestabilityGaps QA docs aligned with existing local direct finding assertions without adding any runtime, auth, network, installed-client or game-session steps.

TestabilityGaps next-safe-step vocabulary hardening rejects gap next-safe-step text that requests runtime, credential, production backend, game-session or user data actions.

TestabilityGaps local finding coverage hardening requires local tests to assert missing gap registry, missing next safe step and runtime gap without stop trigger finding ids without closing runtime gaps or performing production actions.

VerificationMemorySafety installed artifact historical command boundary requires old verification-memory entries with installed artifact commands to preserve 2026-05-30 historical evidence wording and a no-rerun-without-approved-plan boundary.

QaDocsSafety installed artifact manual-boundary wording guard fails if active release, privacy or App/WebView smoke docs lose the manual/explicit-plan and local-fixture autonomous verification boundary for installed artifact defaults.

QaDocsSafety finding coverage wording guard fails if active QA docs lose the Post-M6 finding coverage summaries for local/static direct assertions.

QaDocsSafety detailed finding coverage wording guard fails if AppSmoke docs lose missing required asset-manifest key wording or WebViewBridge docs lose malformed fake host case wording.

QaDocsSafety release/privacy hardening wording guard fails if release/privacy QA docs lose the fail-closed `-DryRun`, unsafe runtime input path, `-ExpectFindings` or `-ReportOnly` boundaries.

QaDocsSafety release/privacy M1.1 hardening wording guard fails if release/privacy QA docs lose negative/clean fixture, signature/version, large/unreadable artifact, privacy bearer/generic/unquoted password or expected finding-id assertion wording.

Release/Privacy report-only local coverage hardening asserts local negative fixtures preserve `-ReportOnly` explicit artifact discovery behavior without reading installed artifacts or runtime user data.

QaDocsSafety release/privacy report-only coverage wording guard fails if release/privacy QA docs lose the Post-M6 report-only coverage notes for local finding-producing fixtures.

Privacy pattern finding coverage hardening asserts local negative fixtures cover access-token, refresh-token, bearer-token, generic-token, api-key, private-key, turn-credential and password finding ids in both `-ExpectFindings` and `-ReportOnly` paths.

QA docs installed artifact manual-boundary wording sync keeps release, privacy and App/WebView smoke docs explicit that installed artifact defaults require a separate approved plan and autonomous verification uses committed local fixtures only.

ActiveRunSafety implementation-status installed artifact source wording guard rejects implementation-status wording that regresses historical installed artifact observations into the current autonomous verification source.

Implementation-status M1 installed artifact history wording sync records installed artifact scans as historical observations and preserves local-fixture-only autonomous verification wording.

ActiveRunSafety installed artifact source wording guard rejects active current-state wording that makes installed artifacts the current autonomous verification source.

ActiveRunSafety current-state installed artifact wording sync makes active context say current autonomous verification uses committed local fixtures only, while installed artifact reads require a separate explicit approved plan.

RunnerSafety implementation-status input path sync records the current path-like runner input guard coverage in implementation-status.

QualityGatesDocsScopeSafety input path summary sync updates quality-gates docs so RunnerSafety and runner scope descriptions reflect unsafe runtime input path guard coverage.

Scripts Readme Scope Safety TestabilityGaps duplicate cleanup removes the stale duplicate quality gate description while preserving the current unsafe runtime input path wording.

RunnerSafety input path coverage hardening requires each run-*.ps1 path-like top-level parameter to keep an unsafe runtime input path guard.

ProdCanary runner input path safety hardening rejects AppData/log/cookie/DB/dump-like TestMetadataPath, SyntheticUsersPath and ResourceBudgetPath overrides before the runner reads them.

ProdSafeSmoke runner input path safety hardening rejects AppData/log/cookie/DB/dump-like TestMetadataPath and SyntheticUsersPath overrides before the runner reads them.

Privacy runner input path safety hardening rejects AppData/log/cookie/DB/dump-like ArtifactRoot and PatternsPath overrides before the runner reads or probes them.

Release runner input path safety hardening rejects AppData/log/cookie/DB/dump-like ArtifactRoot and PolicyPath overrides before the runner reads or probes them.

AppSmoke runner input path safety hardening rejects AppData/log/cookie/DB/dump-like ArtifactRoot and PolicyPath overrides before the runner reads or probes them.

AppSmoke static fixture finding coverage hardening requires local tests to assert missing required files, missing WebView bundles, missing entrypoints, missing manifest keys and invalid asset manifest finding ids without launching the client or reading installed artifacts.

WebViewBridge runner input path safety hardening rejects AppData/log/cookie/DB/dump-like ContractPath overrides before the runner reads them.

BackendSmoke runner input path safety hardening rejects AppData/log/cookie/DB/dump-like PolicyPath overrides before the runner reads them.

UpdateManifest runner input path safety hardening rejects AppData/log/cookie/DB/dump-like PolicyPath overrides before the runner reads them.

UpdateManifest structural package finding coverage hardening requires local tests to assert missing package registry and invalid package id finding ids without network, updater execution, rollback or credentials.

TestabilityGaps runner input path safety hardening rejects AppData/log/cookie/DB/dump-like PolicyPath overrides before the runner reads them.

NonProdFoundation runner input path safety hardening rejects AppData/log/cookie/DB/dump-like PlanPath overrides before the runner reads them.

NonProdFoundation structural finding coverage hardening requires local tests to assert invalid component name, invalid component type and missing components finding ids without executing fake/replay/network/hardware systems.

GameSessionCanary runner input path safety hardening rejects AppData/log/cookie/DB/dump-like PlanPath, SyntheticUsersPath, ResourceBudgetPath and AllowedGamesPath overrides before the runner reads them.

GameSessionCanary remaining finding coverage hardening requires local tests to assert invalid canary count, missing game-session intent, missing state-mutation intent, unsafe session concurrency budget and non-allowlisted region finding ids without launching the client, calling network or starting game sessions.

GameSessionCanary unsafe fixture finding coverage hardening requires the unsafe canary fixture contract and runner negative assertions to cover all current local fail findings emitted by `game-session-canary-unsafe.example.json`, including `conditional-flag-budget-not-required`.

GameSessionCanary suite metadata exact-set hardening requires M5 readiness plans to declare exactly `prod-canary` and `game-session-canary-readiness` suites once each before the direct dry-run validator can pass.

GameSessionCanary runtime path empty-list hardening requires M5 readiness plans to keep `runtimePaths` empty before the direct dry-run validator can pass.

GameSessionCanary readiness signal uniqueness hardening requires M5 readiness plans to declare exactly `stream-ready` and `first-frame` once each before the direct dry-run validator can pass.

GameSessionCanary readiness signal allowlist hardening requires M5 readiness plans to declare only `stream-ready` and `first-frame` readiness signals before the direct dry-run validator can pass.

GameSessionCanary suite metadata hardening requires M5 readiness plans to declare `prod-canary` and `game-session-canary-readiness` suites before the direct dry-run validator can pass.

GameSessionCanary resource-budget policy flag hardening requires M5 readiness plans to keep cleanup verification and explicit conditional flag requirements enabled in `prodResourceBudget` before the direct dry-run validator can pass.

GameSessionCanary run-frequency budget hardening requires M5 readiness plans to keep `prodResourceBudget.maxRunsPerHour` within the local policy range 1..3 before the direct dry-run validator can pass.

GameSessionCanary synthetic alias environment hardening requires M5 readiness plans to use a matched synthetic user that explicitly includes `production` in `allowedEnvironments` before the local dry-run plan can pass.

GameSessionCanary synthetic alias duration hardening requires M5 readiness plan duration to fit the matched synthetic user's own `maxSessionDurationSeconds` ceiling before the local dry-run plan can pass.

GameSessionCanary synthetic alias allowlist hardening requires M5 readiness plans to use a `qa-canary-*` synthetic alias that exists in the synthetic users fixture with `prod_conditional_stream_canary` purpose and game-session permission before the local dry-run plan can pass.

GameSessionCanary synthetic alias direct validator hardening requires M5 readiness plans to declare a qa-canary synthetic alias before the local dry-run plan can pass.

ProdMetadataSafety canary alias duration policy phrase hardening keeps production testing policy wording synced with metadata-scoped canary alias duration budget checks.

ProdMetadataSafety canary alias duration hardening cross-checks the prod-canary synthetic alias maxSessionDurationSeconds against prodResourceBudget.maxSessionDurationSeconds inside the scoped metadata gate.

SyntheticUsersSafety resource budget duration hardening cross-checks canary synthetic user maxSessionDurationSeconds against prodResourceBudget.maxSessionDurationSeconds.

ProdMetadataSafety synthetic alias allowlist hardening cross-checks prod-safe and prod-canary metadata aliases against the synthetic users fixture with expected purpose and game-session permission.

ProdMetadataSafety canary target allowlist hardening cross-checks prod-canary metadata targetRegion and targetGame against resource budget and allowed-games fixtures.

ActiveRunSafety docs summary sync updates scripts README and quality-gates summaries for dynamic `*Safety` coverage and git-status branch policy checks.

ActiveRunSafety implementation-status hardening summary sync records scope coverage and branch/status policy checks in implementation-status.

ActiveRunSafety current-state hardening summary sync records the completed scope coverage and branch/status policy hardening in current-state.

ActiveRunSafety current branch/status policy replaces the live literal branch field with authoritative `git status --short --branch` guidance so active-run does not drift after task branches are fast-forwarded to `main`.

ActiveRunSafety scope coverage hardening derives current static safety scope checks from `quality-gate.ps1` so RunnerSafety, TestDataSafety, ProdMatrixSafety, BacklogSafety and future `*Safety` scopes cannot silently drift out of active/current context checks.

Active-run current branch sync records `main` after the verification-memory template cleanup was fast-forwarded and pushed.

Verification memory template cleanup replaces the non-ASCII heading separator with ASCII while preserving local/static documentation-only boundaries.

Local testability gap registry tracks runtime blockers and required evidence without production actions, credentials or runtime user data reads.

TestDataStructuredSyntaxSafety adds `Full` coverage for JSON fixture parsing under `testdata/` and the required top-level production resource budget YAML shape.

QualityGateStructureSafety adds `Full` coverage for `quality-gate.ps1` structural wiring: every `ValidateSet` scope except `Full` must have exactly one matching `Invoke-<Scope>Gate` function and exactly one `Full` dispatch block.

Thread lifecycle reinforcement makes the separate-thread rule explicit for autonomous time extensions and follow-up gate selection.

GovernanceHistoryScopeSafety adds `Full` coverage for `quality-gate.ps1` `*Safety` scope visibility in verification-memory and session-log history.

ScriptsReadmeScopeSafety adds `Full` coverage for `scripts/README.md` so the local script command inventory mentions every supported `quality-gate.ps1 -Scope`.

ActiveSafetyScopeInventorySafety adds `Full` coverage for `quality-gate.ps1` `*Safety` scope visibility in active/current state docs.

QaDocsCommandSafety adds `Full` coverage for command-looking `run-*.ps1` examples in active QA docs so documented runner invocations keep `-DryRun` and do not include forbidden runtime allow flags, including TestabilityGaps production-action and runtime-user-data allow flags.

QaDocsCommandSafety TestabilityGaps allow-flag implementation-status sync keeps implementation status aligned with the current QA docs command forbidden allow-flag set.

QaDocsCommandLocalPathSafety adds `Full` coverage for command-looking `run-*.ps1` examples in active QA docs so documented runner invocations stay local fixture-oriented and do not include installed-client paths, user runtime paths, endpoints, localhost or WebView debug/CDP references.

QaDocsPowerShellInvocationSafety adds `Full` coverage for command-looking `run-*.ps1` examples in active QA docs so documented runner invocations use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...` while preserving dry-run guard flags.

QaDocsRunnerExampleCoverageSafety adds `Full` coverage for active QA runner/doc contracts so each local FrameworkInventorySafety runner has a command-looking dry-run example in its mapped QA doc.

QualityGatesDocsScopeSafety adds `Full` coverage for the preferred `docs/context/engineering/quality-gates.md` command block so supported `quality-gate.ps1 -Scope` commands cannot drift, duplicate or list unknown scopes.

RepositoryRootInventorySafety adds `Full` coverage for the repository-root file and directory inventory.

BinaryFixturePlaceholderSafety adds `Full` coverage for binary-like files under `testdata/` so executable/library/package fixtures stay tiny placeholders, real PE files are rejected and dump/database/debug extensions cannot be added silently.

ScriptEncodingSafety adds `Full` coverage for `scripts/*.ps1` byte encoding so local runners stay BOM-free and ASCII-only for Windows PowerShell parser safety.

PowerShellStructuredSyntaxSafety adds `Full` coverage for local PowerShell parser syntax checks across `scripts/*.ps1`, `src/TestFramework/**/*.ps1` and `src/TestFramework/**/*.psm1` without importing modules or executing scripts.

ProdSafetyFrameworkSafety adds `Full` coverage for the ProdSafety README, module exports and regression assertion text around classification, kill switch, synthetic user, resource budget and cleanup guard contracts.

RootPromptSafety adds `Full` coverage for top-level Codex prompt/TZ safety wording around repository source-of-truth, autonomy boundaries, production-impact stops and game-session/credential prerequisites.

Script inventory guard hardening updates `scripts/README.md` and makes the `Context` quality gate fail if any `scripts/*.ps1` runner is undocumented.

M1 dry-run fail-closed hardening makes release and privacy runners reject calls without `-DryRun` before reading artifact roots.

Runner/validator guard hardening makes ProdSafety, AppSmoke, BridgeContract and BackendSmoke fail closed on missing `-DryRun`. AppSmoke and BridgeContract also assert rejection of `-AllowClientLaunch` and `-AllowWebViewDebugPort`; BackendSmoke asserts rejection of `-AllowNetwork` and `-AllowAuth`.

Dangerous flag negative coverage adds `Full` assertions for UpdateManifest, BackendSmoke, GameSessionCanary, NonProdFoundation and TestabilityGaps allow-flags.

RunnerSafety static gate adds `Full` coverage for runner dry-run requirements, dangerous allow-switch guards and forbidden runtime/network primitives.

TestDataSafety static gate adds `Full` coverage for risky test fixture content outside explicit unsafe/negative allowlists.

TestDataInventorySafety adds `Full` coverage for the `testdata/` fixture file inventory.

Quality gate scope inventory guard makes `Context` fail if a `quality-gate.ps1 -Scope` value is not documented in `docs/context/engineering/quality-gates.md`.

ProdMatrixSafety static gate adds `Full` coverage for production-safe test matrix classification drift.

BacklogSafety static gate adds `Full` coverage for M0-M6 value/effort backlog drift.

SyntheticUsersSafety, ResourceBudgetSafety, AllowedGamesSafety, ProdMetadataSafety and GameSessionCanary add `Full` coverage for local fixture drift around synthetic aliases, canary game aliases, canary duration budgets, session-concurrency budgets, run-frequency budgets, cleanup/conditional budget flags, canary suite metadata, readiness signal allowlists, production metadata, synthetic alias allowlist links, direct canary plan alias metadata, game-session/state-mutation intent metadata, allowlisting, production environment permission and matched synthetic-user duration, metadata-scoped alias duration, policy wording and canary target allowlist consistency.

ContextDocsInventorySafety adds `Full` coverage for the `docs/context/*.md` handoff/governance/engineering inventory.

SessionLogSafety adds `Full` coverage for guarded session-log entries so mode, branch, scope and core safety notes stay present. It also validates the latest codex branch entry for thread lifecycle wording and keeps the latest session-log codex branch synced with verification-memory.

VerificationMemorySafety adds `Full` coverage for verification-memory branch entries so pending markers, missing evidence fields, missing static `Not run:` rationale and missing latest-entry safety notes fail closed.

ActiveVerificationCommandSafety adds `Full` coverage for active/current verification command evidence in active-run Last verification and the newest verification-memory Commands block so command evidence stays local/static and excludes installed-client paths, user runtime paths, endpoints, localhost/debug/CDP references, direct runners, auth/network/session/update/dependency, TestabilityGaps production-action/runtime-user-data allow flags and CI commands.

ChecklistSafety adds `Full` coverage for executor and context integrity checklist drift around thread isolation, verification records, stop triggers, secrets and production-impact checks.

DecisionsLogSafety adds `Full` coverage for durable decision drift around production safety, autonomy, thread isolation, push/merge authority and process-error rules.

CodexPolicySafety adds `Full` coverage for Codex and executor policy drift around autonomy, thread isolation, production-impact, credential, CI/CD, main-merge and game-session boundaries.

TaskRequestSafety adds `Full` coverage for task request template/log drift around bounded goals, forbidden actions, production classification, verification commands and stop conditions.

CodexTemplateSafety adds `Full` coverage for Codex review/task/communication/agent-role drift around Russian reporting, role separation, verification evidence, production classification, stop triggers, secrets and no-main-merge rules.

CodexGoalTemplateSafety adds `Full` coverage for the Codex goal template so future goals keep execution mode, scope, forbidden actions, acceptance criteria, verification and stop conditions.

CodexDocsInventorySafety adds `Full` coverage for the `docs/codex/*.md` policy/template inventory.

QaStrategySafety adds `Full` coverage for QA strategy/testability/flakiness drift around layered test order, no broad E2E, WebView debug defaults, runtime gap tracking and retry/session-budget rules.

HandoffProtocolSafety adds `Full` coverage for context protocol and Git workflow drift around source-of-truth ordering, latest-commit handling, thread isolation, worktree fallback, local verification and main-merge approval rules.

IncomingReferenceSafety adds `Full` coverage for incoming reference inventory and source-of-truth wording so historical reference docs do not silently become active scope.

FrameworkInventorySafety adds `Full` coverage for TestFramework module inventory, matching tests, local runners, QA docs and example/unsafe fixtures.

TestFrameworkInventorySafety adds `Full` coverage for the `src/TestFramework` file inventory.

IncidentStopSafety adds `Full` coverage for the centralized incident stop trigger vocabulary and testability gap stop-trigger drift.

QaDocsSafety adds `Full` coverage for the required `docs/qa/*.md` policy inventory, core safety phrases, Post-M6 finding coverage summaries and release/privacy runner hardening notes.

ArtifactPolicySafety adds `Full` coverage for release/privacy policy fixture drift around required files, forbidden extensions, finding ids, privacy patterns and scan limits.

ContractFixtureSafety adds `Full` coverage for backend, update manifest and WebView bridge fixture drift around dry-run flags, read-only/local-only constraints, package integrity metadata, bridge structural/fake-host finding coverage and bridge safety vocabulary.

StaticSurfaceSafety adds `Full` coverage for App/WebView smoke and non-prod foundation fixture drift around static layout, WebView bundle inventory and schema-only non-runtime placeholders.

WebViewBundleLocalReferenceSafety adds `Full` coverage for fixture WebView bundle entrypoints and manifests so remote URLs, localhost/debug/CDP references, user runtime paths, production endpoints and non-local manifest paths cannot drift into the local smoke bundle.

FixtureInventorySafety adds `Full` coverage for release, privacy and App/WebView smoke fixture directory drift around required positive, negative and clean local fixture files.

ScriptsInventorySafety adds `Full` coverage for the `scripts/` runner/support file inventory.

UnsafeFixtureCoverageSafety adds `Full` coverage for `testdata/*unsafe*.example.json` fixtures so each unsafe fixture keeps a negative coverage block with the fixture path and expected `Assert-FindingId` assertions.

ActiveRunSafety rejects active-run/current-state wording that declares a literal historical thread id as the active task thread, while preserving historical inactive/history-only thread references.
```

Forbidden without a new approved plan:

- installed client launch;
- WebView debug/CDP port;
- authentication;
- real game session execution;
- production backend or streaming network interaction;
- fake/replay server runtime execution;
- network shaping;
- hardware inspection;
- credentials, secrets, bearer tokens, cookies or session headers;
- reading user AppData, cookies, local DB, logs or crash dumps;
- update/rollback execution;
- CI/CD enablement;
- dependency upgrades;
- weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier.

Stop-and-ask triggers:

- any need to start `rds-client.exe`;
- any need for credentials or synthetic login;
- any need for WebView debug port;
- any need for real backend URL, streaming URL or network calls;
- any need for auth headers, cookies, tokens or secrets;
- any need to read user runtime files;
- any need to execute a fake/replay server, network shaper or hardware probe;
- any need to execute or stop a real game session;
- any production-impacting action;
- scope expansion beyond local dry-run/schema validation.

Last verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope PowerShellStructuredSyntaxSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Previous verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaDocsSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Earlier verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaDocsSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Older verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaDocsSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Oldest verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope BridgeContract`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Oldest retained verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope GameSessionCanary`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Archived verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaDocsSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.

Archived older verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveSafetyScopeInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QualityGateStructureSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`.
