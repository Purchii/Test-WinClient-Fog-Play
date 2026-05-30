# Current state

Project: MTC Fog Play Windows client QA automation.

Known context:

- Windows desktop client.
- Native layer: C++.
- Embedded WebView/CEF/WebView-like layer.
- Product: cloud gaming.
- Current automation may run against production.
- Production safety is the first priority.

Current milestone state:

```text
M0: ProdSafety + Git/Handoff/Verification governance foundation - implemented and merged to main.
M1: Release artifact + privacy/logging gates - implemented, hardened and merged to main.
M2: App launch + WebView smoke - static/dry-run scaffold implemented and merged to main.
Thread lifecycle governance correction: implemented and merged to main.
M3: WebView/native bridge contract + fake host - local/dry-run scaffold implemented and merged to main.
M4: Safe backend smoke - local/dry-run scaffold implemented and merged to main.
M5: Minimal game-session canary readiness gate - dry-run plan validator implemented and merged to main.
M6: Future non-prod/fake/replay/network/hardware foundation - local/dry-run schema validator implemented and merged to main.
Post-M6: QualityGateStructureSafety static gate - implemented and verified locally.
Post-M6: TestDataStructuredSyntaxSafety static gate - implemented and verified locally.
Post-M6: GovernanceHistoryScopeSafety static gate - implemented and verified locally.
Post-M6: ScriptsReadmeScopeSafety static gate - implemented and verified locally.
Post-M6: ActiveSafetyScopeInventorySafety static gate - implemented and verified locally.
Post-M6: QaDocsCommandSafety static gate - implemented and verified locally.
Post-M6: BinaryFixturePlaceholderSafety static gate - implemented and verified locally.
Post-M6: ScriptEncodingSafety static gate - implemented and verified locally.
Post-M6: PowerShellStructuredSyntaxSafety static gate - implemented and verified locally.
Post-M6: ProdSafetyFrameworkSafety static gate - implemented and verified locally.
Post-M6: RootPromptSafety static gate - implemented and verified locally.
Post-M6: RepositoryRootInventorySafety static gate - implemented and verified locally.
Post-M6: Script inventory guard - implemented and verified locally.
Post-M6: M1 dry-run fail-closed hardening - implemented and verified locally.
Post-M6: Runner/validator guard hardening - implemented and verified locally.
Post-M6: Dangerous flag negative coverage - implemented and verified locally.
Post-M6: RunnerSafety static gate - implemented and verified locally.
Post-M6: TestDataSafety static gate - implemented and verified locally.
Post-M6: TestDataInventorySafety static gate - implemented and verified locally.
Post-M6: Quality gate scope inventory guard - implemented and verified locally.
Post-M6: ProdMatrixSafety static gate - implemented and verified locally.
Post-M6: BacklogSafety static gate - implemented and verified locally.
Post-M6: SyntheticUsersSafety static gate - implemented and verified locally.
Post-M6: ResourceBudgetSafety static gate - implemented and verified locally.
Post-M6: AllowedGamesSafety static gate - implemented and verified locally.
Post-M6: ProdMetadataSafety static gate - implemented and verified locally.
Post-M6: ContextDocsInventorySafety static gate - implemented and verified locally.
Post-M6: SessionLogSafety static gate - implemented and verified locally.
Post-M6: VerificationMemorySafety static gate - implemented and verified locally.
Post-M6: ChecklistSafety static gate - implemented and verified locally.
Post-M6: DecisionsLogSafety static gate - implemented and verified locally.
Post-M6: CodexPolicySafety static gate - implemented and verified locally.
Post-M6: TaskRequestSafety static gate - implemented and verified locally.
Post-M6: CodexTemplateSafety static gate - implemented and verified locally.
Post-M6: CodexGoalTemplateSafety static gate - implemented and verified locally.
Post-M6: CodexDocsInventorySafety static gate - implemented and verified locally.
Post-M6: QaStrategySafety static gate - implemented and verified locally.
Post-M6: HandoffProtocolSafety static gate - implemented and verified locally.
Post-M6: IncomingReferenceSafety static gate - implemented and verified locally.
Post-M6: FrameworkInventorySafety static gate - implemented and verified locally.
Post-M6: TestFrameworkInventorySafety static gate - implemented and verified locally.
Post-M6: ActiveRunSafety static gate - implemented and verified locally.
Post-M6: IncidentStopSafety static gate - implemented and verified locally.
Post-M6: QaDocsSafety static gate - implemented and verified locally.
Post-M6: ArtifactPolicySafety static gate - implemented and verified locally.
Post-M6: ContractFixtureSafety static gate - implemented and verified locally.
Post-M6: StaticSurfaceSafety static gate - implemented and verified locally.
Post-M6: FixtureInventorySafety static gate - implemented and verified locally.
Post-M6: ScriptsInventorySafety static gate - implemented and verified locally.
```

Do not start real game-session automation. M5 is limited to local readiness-plan validation unless a separate production-conditional execution plan is approved.

Repository bootstrap state:

- This is a new project repository.
- The remote repository was empty during M0 bootstrap.
- Starter governance docs were imported as the initial `main` baseline.
- M0 implementation was completed on `codex/prod-safety-foundation` and merged to `main`.
- M1 implementation was completed on `codex/release-privacy-gates` and merged to `main`.
- M2 implementation was completed on `codex/app-webview-smoke` and merged to `main`.
- M3 implementation was completed on `codex/m3-webview-bridge-contract` and merged to `main`.
- M4 implementation was completed on `codex/m4-backend-smoke` and merged to `main`.
- M5 implementation was completed on `codex/m5-game-session-canary` and merged to `main`.
- M6 implementation was completed on `codex/m6-nonprod-foundation` and merged to `main`.
- Post-M6 QualityGateStructureSafety static gate was completed on `codex/quality-gate-structure-safety-gate`.
- Post-M6 TestDataStructuredSyntaxSafety static gate was completed on `codex/testdata-structured-syntax-safety-gate`.
- Post-M6 GovernanceHistoryScopeSafety static gate was completed on `codex/governance-history-scope-safety-gate`.
- Post-M6 ScriptsReadmeScopeSafety static gate was completed on `codex/scripts-readme-scope-safety-gate`.
- Post-M6 ActiveSafetyScopeInventorySafety static gate was completed on `codex/active-safety-scope-inventory-gate`.
- Post-M6 QaDocsCommandSafety static gate was completed on `codex/qa-docs-command-safety-gate`.
- Post-M6 BinaryFixturePlaceholderSafety static gate was completed on `codex/binary-fixture-placeholder-safety-gate`.
- Post-M6 ScriptEncodingSafety static gate was completed on `codex/script-encoding-safety-gate`.
- Post-M6 PowerShellStructuredSyntaxSafety static gate was completed on `codex/powershell-structured-syntax-safety-gate`.
- Post-M6 ProdSafetyFrameworkSafety static gate was completed on `codex/prodsafety-framework-safety-gate`.
- Post-M6 RepositoryRootInventorySafety static gate was completed on `codex/repository-root-inventory-safety-gate`.
- Post-M6 RootPromptSafety static gate was completed on `codex/root-prompt-safety-gate`.
- Post-M6 script inventory guard hardening was completed on `codex/scripts-inventory-guard`.
- Post-M6 M1 dry-run fail-closed hardening was completed on `codex/m1-dryrun-fail-closed`.
- Post-M6 runner/validator guard hardening was completed on `codex/app-bridge-runner-guard`.
- Post-M6 dangerous flag negative coverage was completed on `codex/danger-flag-negative-coverage`.
- Post-M6 RunnerSafety static gate was completed on `codex/runner-safety-static-gate`.
- Post-M6 TestDataSafety static gate was completed on `codex/testdata-safety-gate`.
- Post-M6 TestDataInventorySafety static gate was completed on `codex/testdata-inventory-safety-gate`.
- Post-M6 quality gate scope inventory guard was completed on `codex/quality-gate-scope-inventory`.
- Post-M6 ProdMatrixSafety static gate was completed on `codex/prod-matrix-safety-gate`.
- Post-M6 BacklogSafety static gate was completed on `codex/backlog-safety-gate`.
- Post-M6 SyntheticUsersSafety static gate was completed on `codex/synthetic-users-safety-gate`.
- Post-M6 ResourceBudgetSafety static gate was completed on `codex/resource-budget-safety-gate`.
- Post-M6 AllowedGamesSafety static gate was completed on `codex/allowed-games-safety-gate`.
- Post-M6 ProdMetadataSafety static gate was completed on `codex/prod-metadata-safety-gate`.
- Post-M6 ContextDocsInventorySafety static gate was completed on `codex/context-docs-inventory-safety-gate`.
- Post-M6 SessionLogSafety static gate was completed on `codex/session-log-safety-gate`.
- Post-M6 VerificationMemorySafety static gate was completed on `codex/verification-memory-safety-gate`.
- Post-M6 ChecklistSafety static gate was completed on `codex/checklist-safety-gate`.
- Post-M6 DecisionsLogSafety static gate was completed on `codex/decisions-log-safety-gate`.
- Post-M6 CodexPolicySafety static gate was completed on `codex/codex-policy-safety-gate`.
- Post-M6 TaskRequestSafety static gate was completed on `codex/task-request-safety-gate`.
- Post-M6 CodexTemplateSafety static gate was completed on `codex/codex-template-safety-gate`.
- Post-M6 CodexGoalTemplateSafety static gate was completed on `codex/goal-template-safety-gate`.
- Post-M6 CodexDocsInventorySafety static gate was completed on `codex/codex-docs-inventory-safety-gate`.
- Post-M6 QaStrategySafety static gate was completed on `codex/qa-strategy-safety-gate`.
- Post-M6 HandoffProtocolSafety static gate was completed on `codex/handoff-protocol-safety-gate`.
- Post-M6 IncomingReferenceSafety static gate was completed on `codex/incoming-reference-safety-gate`.
- Post-M6 FrameworkInventorySafety static gate was completed on `codex/framework-inventory-safety-gate`.
- Post-M6 TestFrameworkInventorySafety static gate was completed on `codex/testframework-inventory-safety-gate`.
- Post-M6 ActiveRunSafety static gate was completed on `codex/active-run-safety-gate`.
- Post-M6 IncidentStopSafety static gate was completed on `codex/incident-stop-safety-gate`.
- Post-M6 QaDocsSafety static gate was completed on `codex/qa-docs-safety-gate`.
- Post-M6 ArtifactPolicySafety static gate was completed on `codex/artifact-policy-safety-gate`.
- Post-M6 ContractFixtureSafety static gate was completed on `codex/contract-fixture-safety-gate`.
- Post-M6 StaticSurfaceSafety static gate was completed on `codex/static-surface-safety-gate`.
- Post-M6 FixtureInventorySafety static gate was completed on `codex/fixture-inventory-safety-gate`.
- Post-M6 ScriptsInventorySafety static gate was completed on `codex/scripts-inventory-safety-gate`.
- New independent autonomous tasks require a separate Codex thread. Continuing M3 implementation in the previous thread is recorded as `PROCESS_ERROR_THREAD_REUSE`.
- Thread `019e7aab-dbaf-70d0-b143-ed7e6eb0bde0` is the active task thread for PowerShellStructuredSyntaxSafety. Previous source thread `019e793c-4e53-7be0-90c7-10ff5a02c8b1` is inactive/history-only after handoff and must not be used to implement new independent tasks.
- Extended autonomous time, push permission and merge permission do not waive thread-per-task.
- Each newly selected follow-up quality gate, hardening item, feature slice, backlog item or milestone is a new independent task unless it only repairs verification for the current task.
- Current installed artifact source for offline checks: `C:\Program Files\MTC Fog Play`.
- Windows client source, WebView/CEF/WebView2 frontend, native bridge handlers, updater/package scripts, existing tests/CI and telemetry/crash code are not present yet.

Current artifact status:

- Release/privacy gate implementation exists.
- Update manifest integrity gate exists as local fixture-based dry-run validation only.
- App/WebView smoke scaffold exists as static/dry-run only.
- WebView/native bridge contract scaffold exists as local/dry-run only.
- Backend smoke scaffold exists as local/dry-run only.
- Game-session canary readiness gate is local/dry-run only and does not execute sessions.
- Non-prod foundation scaffold is local/dry-run only and does not execute fake, replay, network or hardware systems.
- Testability gaps registry exists as local/dry-run validation only.
- QualityGateStructureSafety statically checks `quality-gate.ps1` structural wiring so each supported scope except `Full` has one matching function and one `Full` dispatch.
- TestDataStructuredSyntaxSafety statically checks JSON fixture parsing under `testdata/` and the required top-level production resource budget YAML shape.
- GovernanceHistoryScopeSafety statically checks `quality-gate.ps1` `*Safety` scope visibility in verification-memory and session-log history.
- ScriptsReadmeScopeSafety statically checks `scripts/README.md` so the local script command inventory mentions every supported `quality-gate.ps1 -Scope`.
- ActiveSafetyScopeInventorySafety statically checks `quality-gate.ps1` `*Safety` scope visibility in active/current state docs.
- QaDocsCommandSafety statically checks command-looking `run-*.ps1` examples in active QA docs so documented runner invocations keep `-DryRun` and do not include forbidden runtime allow flags.
- BinaryFixturePlaceholderSafety statically checks binary-like files under `testdata/` so executable/library/package fixtures stay tiny placeholders, real PE files are rejected and dump/database/debug extensions cannot be added silently.
- ScriptEncodingSafety statically checks `scripts/*.ps1` byte encoding so local runners stay BOM-free and ASCII-only for Windows PowerShell parser safety.
- PowerShellStructuredSyntaxSafety statically checks local PowerShell parser syntax across `scripts/*.ps1`, `src/TestFramework/**/*.ps1` and `src/TestFramework/**/*.psm1` without importing modules or executing scripts.
- ProdSafetyFrameworkSafety statically checks the ProdSafety README, module exports and regression assertion text around classification, kill switch, synthetic user, resource budget and cleanup guard contracts.
- RepositoryRootInventorySafety statically checks the repository-root file and directory inventory.
- RootPromptSafety statically checks top-level Codex prompt/TZ safety wording around repository source-of-truth, autonomy boundaries, production-impact stops and game-session/credential prerequisites.
- Script runner inventory is documented in `scripts/README.md` and checked by the `Context` quality gate.
- Release and privacy runners require `-DryRun` before reading artifact roots.
- ProdSafety, App/WebView, WebView bridge and BackendSmoke runners/validators fail closed on missing `-DryRun`; App/WebView and WebView bridge runners also reject client launch and WebView debug/CDP flags.
- UpdateManifest, GameSessionCanary, NonProdFoundation and TestabilityGaps quality gates assert rejection of dangerous allow flags.
- RunnerSafety statically checks runner dry-run requirements, dangerous allow-switch guards and forbidden runtime/network primitives.
- TestDataSafety statically checks risky test fixtures against an explicit unsafe/negative allowlist.
- TestDataInventorySafety statically checks the `testdata/` fixture file inventory.
- Context gate checks that `docs/context/engineering/quality-gates.md` lists every supported `quality-gate.ps1 -Scope` value.
- ActiveRunSafety statically checks active handoff/current-state safety boundaries, stop triggers and stale literal latest-commit markers.
- ActiveRunSafety also checks that active-run's current milestone marker and last-verification notes stay synced with current static gate coverage.
- SessionLogSafety statically checks guarded session-log branch entries for mode, branch, scope and core no-runtime/no-production safety notes.
- VerificationMemorySafety statically checks verification-memory branch entries for pending markers and missing evidence fields.
- ChecklistSafety statically checks executor and context integrity checklists for required thread isolation, verification, stop-trigger, secrets and production-impact items.
- DecisionsLogSafety statically checks durable decisions for production safety, autonomy, thread isolation, push/merge authority and process-error rules.
- CodexPolicySafety statically checks Codex and executor policies for autonomy, thread isolation, production-impact, credential, CI/CD, main-merge and game-session boundaries.
- TaskRequestSafety statically checks task request template/log docs for bounded-goal fields, production classification, verification and stop conditions.
- CodexTemplateSafety statically checks Codex review/task/communication/agent-role docs for reporting, role separation, verification, production classification, stop-trigger, secret and no-main-merge requirements.
- CodexGoalTemplateSafety statically checks the Codex goal template for execution mode, scope, forbidden actions, acceptance criteria, verification and stop conditions.
- CodexDocsInventorySafety statically checks the `docs/codex/*.md` policy/template inventory.
- QaStrategySafety statically checks QA strategy, testability contract and flakiness policy docs for layered order, no broad E2E, WebView debug defaults, runtime gap tracking and retry/session-budget rules.
- HandoffProtocolSafety statically checks context protocol and Git workflow docs for source-of-truth ordering, latest-commit handling, thread isolation, worktree fallback, local verification and main-merge approval rules.
- IncomingReferenceSafety statically checks incoming reference inventory and source-of-truth wording so historical reference docs do not silently become active scope.
- FrameworkInventorySafety statically checks TestFramework modules for matching tests, local runners, QA docs and example/unsafe fixtures.
- TestFrameworkInventorySafety statically checks the `src/TestFramework` file inventory.
- ProdMatrixSafety statically checks the production-safe test matrix for safe scenario classifications.
- BacklogSafety statically checks the M0-M6 value/effort backlog shape and priority bounds.
- SyntheticUsersSafety, ResourceBudgetSafety, AllowedGamesSafety and ProdMetadataSafety statically check production guard fixture drift around aliases, canary budgets, game allowlists and production metadata.
- ContextDocsInventorySafety statically checks the `docs/context/*.md` handoff/governance/engineering inventory.
- IncidentStopSafety statically checks the incident stop trigger vocabulary against active handoff and testability gap fixtures.
- QaDocsSafety statically checks the required `docs/qa/*.md` policy inventory and core safety phrases.
- ArtifactPolicySafety statically checks release/privacy policy fixtures for required file, forbidden extension, finding id, privacy pattern and scan-limit drift.
- ContractFixtureSafety statically checks backend, update manifest and WebView bridge fixtures for dry-run, local-only and safety-vocabulary drift.
- StaticSurfaceSafety statically checks App/WebView smoke and non-prod foundation fixtures for static layout, WebView bundle inventory and schema-only non-runtime drift.
- FixtureInventorySafety statically checks release, privacy and App/WebView smoke fixture directory trees for required positive, negative and clean local fixture files.
- ScriptsInventorySafety statically checks the `scripts/` runner/support file inventory.
- The installed artifact is not release-clean by current policy: unsigned `rds-client.exe`/`Uninstall.exe`/`crashpad_handler.exe`, sourcemaps, source map references and a local path in `installer_info.txt` were reported.
