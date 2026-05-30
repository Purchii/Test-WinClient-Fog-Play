# Active run

Status: Post-M6 static safety gates implemented and verified locally.

Execution mode: autonomous local-safe hardening after explicit user approval to work autonomously and push to `main`.

Current milestone: Post-M6 local/static safety gate hardening complete through QaDocsPowerShellInvocationSafety.

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
Post-M6 QaDocsPowerShellInvocationSafety static gate is complete.
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
Future execution milestones require their own NON_AUTONOMOUS planning step in a separate thread.
Autonomous time extension, push permission or merge permission does not waive thread-per-task.
Each newly selected follow-up gate, hardening item, feature slice or backlog item requires a new Codex thread unless it only repairs verification for the current task.
Thread `019e7aab-dbaf-70d0-b143-ed7e6eb0bde0` is the active task thread after handoff from source thread `019e793c-4e53-7be0-90c7-10ff5a02c8b1`. Previous source thread `019e793c-4e53-7be0-90c7-10ff5a02c8b1` became inactive/history-only after handoff to `019e7aab-dbaf-70d0-b143-ed7e6eb0bde0`, is preserved for history, is not deleted, is not archived automatically unless the user explicitly asks, and must not be used to implement new independent tasks.
```

Current branch:

```text
main
```

Current result:

```text
Local testability gap registry tracks runtime blockers and required evidence without production actions, credentials or runtime user data reads.

TestDataStructuredSyntaxSafety adds `Full` coverage for JSON fixture parsing under `testdata/` and the required top-level production resource budget YAML shape.

QualityGateStructureSafety adds `Full` coverage for `quality-gate.ps1` structural wiring: every `ValidateSet` scope except `Full` must have exactly one matching `Invoke-<Scope>Gate` function and exactly one `Full` dispatch block.

Thread lifecycle reinforcement makes the separate-thread rule explicit for autonomous time extensions and follow-up gate selection.

GovernanceHistoryScopeSafety adds `Full` coverage for `quality-gate.ps1` `*Safety` scope visibility in verification-memory and session-log history.

ScriptsReadmeScopeSafety adds `Full` coverage for `scripts/README.md` so the local script command inventory mentions every supported `quality-gate.ps1 -Scope`.

ActiveSafetyScopeInventorySafety adds `Full` coverage for `quality-gate.ps1` `*Safety` scope visibility in active/current state docs.

QaDocsCommandSafety adds `Full` coverage for command-looking `run-*.ps1` examples in active QA docs so documented runner invocations keep `-DryRun` and do not include forbidden runtime allow flags.

QaDocsPowerShellInvocationSafety adds `Full` coverage for command-looking `run-*.ps1` examples in active QA docs so documented runner invocations use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...` while preserving dry-run guard flags.

RepositoryRootInventorySafety adds `Full` coverage for the repository-root file and directory inventory.

BinaryFixturePlaceholderSafety adds `Full` coverage for binary-like files under `testdata/` so executable/library/package fixtures stay tiny placeholders, real PE files are rejected and dump/database/debug extensions cannot be added silently.

ScriptEncodingSafety adds `Full` coverage for `scripts/*.ps1` byte encoding so local runners stay BOM-free and ASCII-only for Windows PowerShell parser safety.

PowerShellStructuredSyntaxSafety adds `Full` coverage for local PowerShell parser syntax checks across `scripts/*.ps1`, `src/TestFramework/**/*.ps1` and `src/TestFramework/**/*.psm1` without importing modules or executing scripts.

ProdSafetyFrameworkSafety adds `Full` coverage for the ProdSafety README, module exports and regression assertion text around classification, kill switch, synthetic user, resource budget and cleanup guard contracts.

RootPromptSafety adds `Full` coverage for top-level Codex prompt/TZ safety wording around repository source-of-truth, autonomy boundaries, production-impact stops and game-session/credential prerequisites.

Script inventory guard hardening updates `scripts/README.md` and makes the `Context` quality gate fail if any `scripts/*.ps1` runner is undocumented.

M1 dry-run fail-closed hardening makes release and privacy runners reject calls without `-DryRun` before reading artifact roots.

Runner/validator guard hardening makes ProdSafety, AppSmoke, BridgeContract and BackendSmoke fail closed on missing `-DryRun`. AppSmoke and BridgeContract also assert rejection of `-AllowClientLaunch` and `-AllowWebViewDebugPort`.

Dangerous flag negative coverage adds `Full` assertions for UpdateManifest, GameSessionCanary, NonProdFoundation and TestabilityGaps allow-flags.

RunnerSafety static gate adds `Full` coverage for runner dry-run requirements, dangerous allow-switch guards and forbidden runtime/network primitives.

TestDataSafety static gate adds `Full` coverage for risky test fixture content outside explicit unsafe/negative allowlists.

TestDataInventorySafety adds `Full` coverage for the `testdata/` fixture file inventory.

Quality gate scope inventory guard makes `Context` fail if a `quality-gate.ps1 -Scope` value is not documented in `docs/context/engineering/quality-gates.md`.

ProdMatrixSafety static gate adds `Full` coverage for production-safe test matrix classification drift.

BacklogSafety static gate adds `Full` coverage for M0-M6 value/effort backlog drift.

SyntheticUsersSafety, ResourceBudgetSafety, AllowedGamesSafety and ProdMetadataSafety add `Full` coverage for local fixture drift around synthetic aliases, canary game aliases, resource budgets and production test metadata.

ContextDocsInventorySafety adds `Full` coverage for the `docs/context/*.md` handoff/governance/engineering inventory.

SessionLogSafety adds `Full` coverage for guarded session-log entries so mode, branch, scope and core safety notes stay present.

VerificationMemorySafety adds `Full` coverage for verification-memory branch entries so pending markers and missing evidence fields fail closed.

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

QaDocsSafety adds `Full` coverage for the required `docs/qa/*.md` policy inventory and core safety phrases.

ArtifactPolicySafety adds `Full` coverage for release/privacy policy fixture drift around required files, forbidden extensions, finding ids, privacy patterns and scan limits.

ContractFixtureSafety adds `Full` coverage for backend, update manifest and WebView bridge fixture drift around dry-run flags, read-only/local-only constraints, package integrity metadata and bridge safety vocabulary.

StaticSurfaceSafety adds `Full` coverage for App/WebView smoke and non-prod foundation fixture drift around static layout, WebView bundle inventory and schema-only non-runtime placeholders.

WebViewBundleLocalReferenceSafety adds `Full` coverage for fixture WebView bundle entrypoints and manifests so remote URLs, localhost/debug/CDP references, user runtime paths, production endpoints and non-local manifest paths cannot drift into the local smoke bundle.

FixtureInventorySafety adds `Full` coverage for release, privacy and App/WebView smoke fixture directory drift around required positive, negative and clean local fixture files.

ScriptsInventorySafety adds `Full` coverage for the `scripts/` runner/support file inventory.

UnsafeFixtureCoverageSafety adds `Full` coverage for `testdata/*unsafe*.example.json` fixtures so each unsafe fixture keeps a negative coverage block with the fixture path and expected `Assert-FindingId` assertions.
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

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QualityGateStructureSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope TestDataStructuredSyntaxSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope GovernanceHistoryScopeSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ScriptsReadmeScopeSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveSafetyScopeInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaDocsCommandSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaDocsPowerShellInvocationSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope BinaryFixturePlaceholderSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ScriptEncodingSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope PowerShellStructuredSyntaxSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ProdSafetyFrameworkSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope RootPromptSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope RepositoryRootInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope StaticSurfaceSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope WebViewBundleLocalReferenceSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope FixtureInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ScriptsInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope TestDataInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope UnsafeFixtureCoverageSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ContextDocsInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope SessionLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope VerificationMemorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ChecklistSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope DecisionsLogSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope CodexPolicySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope TaskRequestSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope CodexTemplateSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope CodexGoalTemplateSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope CodexDocsInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope QaStrategySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope HandoffProtocolSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope IncomingReferenceSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope FrameworkInventorySafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope TestFrameworkInventorySafety`;
- `git diff --check`.
