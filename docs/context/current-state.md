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
Post-M6: QaDocsCommandLocalPathSafety static gate - implemented and verified locally.
Post-M6: QaDocsPowerShellInvocationSafety static gate - implemented and verified locally.
Post-M6: QaDocsRunnerExampleCoverageSafety static gate - implemented and verified locally.
Post-M6: QualityGatesDocsScopeSafety static gate - implemented and verified locally.
Post-M6: BinaryFixturePlaceholderSafety static gate - implemented and verified locally.
Post-M6: ScriptEncodingSafety static gate - implemented and verified locally.
Post-M6: PowerShellStructuredSyntaxSafety static gate - implemented and verified locally.
Post-M6: Thread inactive/history-only lifecycle wording - implemented and verified locally.
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
Post-M6: ActiveVerificationCommandSafety static gate - implemented and verified locally.
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
Post-M6: WebViewBundleLocalReferenceSafety static gate - implemented and verified locally.
Post-M6: FixtureInventorySafety static gate - implemented and verified locally.
Post-M6: ScriptsInventorySafety static gate - implemented and verified locally.
Post-M6: UnsafeFixtureCoverageSafety static gate - implemented and verified locally.
Post-M6: ActiveRunSafety scope coverage hardening - implemented and verified locally.
Post-M6: ActiveRunSafety current branch/status policy - implemented and verified locally.
Post-M6: ProdMetadataSafety canary target allowlist hardening - implemented and verified locally.
Post-M6: ProdMetadataSafety synthetic alias allowlist hardening - implemented and verified locally.
Post-M6: SyntheticUsersSafety resource budget duration hardening - implemented and verified locally.
Post-M6: ProdMetadataSafety canary alias duration hardening - implemented and verified locally.
Post-M6: ProdMetadataSafety canary alias duration policy phrase hardening - implemented and verified locally.
Post-M6: GameSessionCanary synthetic alias direct validator hardening - implemented and verified locally.
Post-M6: GameSessionCanary synthetic alias allowlist hardening - implemented and verified locally.
Post-M6: GameSessionCanary synthetic alias duration hardening - implemented and verified locally.
Post-M6: GameSessionCanary synthetic alias environment hardening - implemented and verified locally.
Post-M6: GameSessionCanary run-frequency budget hardening - implemented and verified locally.
Post-M6: GameSessionCanary resource-budget policy flag hardening - implemented and verified locally.
Post-M6: GameSessionCanary suite metadata hardening - implemented and verified locally.
Post-M6: GameSessionCanary readiness signal allowlist hardening - implemented and verified locally.
Post-M6: GameSessionCanary readiness signal uniqueness hardening - implemented and verified locally.
Post-M6: GameSessionCanary runtime path empty-list hardening - implemented and verified locally.
Post-M6: GameSessionCanary suite metadata exact-set hardening - implemented and verified locally.
Post-M6: GameSessionCanary unsafe fixture finding coverage hardening - implemented and verified locally.
Post-M6: GameSessionCanary runner input path safety hardening - implemented and verified locally.
Post-M6: NonProdFoundation runner input path safety hardening - implemented and verified locally.
Post-M6: TestabilityGaps runner input path safety hardening - implemented and verified locally.
Post-M6: UpdateManifest runner input path safety hardening - implemented and verified locally.
Post-M6: BackendSmoke runner input path safety hardening - implemented and verified locally.
Post-M6: WebViewBridge runner input path safety hardening - implemented and verified locally.
Post-M6: AppSmoke runner input path safety hardening - implemented and verified locally.
Post-M6: Release runner input path safety hardening - implemented and verified locally.
Post-M6: Privacy runner input path safety hardening - implemented and verified locally.
Post-M6: ProdSafeSmoke runner input path safety hardening - implemented and verified locally.
Post-M6: ProdCanary runner input path safety hardening - implemented and verified locally.
Post-M6: RunnerSafety input path coverage hardening - implemented and verified locally.
Post-M6: Scripts Readme Scope Safety TestabilityGaps duplicate cleanup - implemented and verified locally.
Post-M6: QualityGatesDocsScopeSafety input path summary sync - implemented and verified locally.
Post-M6: RunnerSafety implementation-status input path sync - implemented and verified locally.
Post-M6: Active current-state installed artifact wording sync - implemented and verified locally.
Post-M6: ActiveRunSafety installed artifact source wording guard - implemented and verified locally.
Post-M6: Implementation-status M1 installed artifact history wording sync - implemented and verified locally.
Post-M6: ActiveRunSafety implementation-status installed artifact source wording guard - implemented and verified locally.
Post-M6: QA docs installed artifact manual-boundary wording sync - implemented and verified locally.
Post-M6: QaDocsSafety installed artifact manual-boundary wording guard - implemented and verified locally.
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
- Post-M6 QaDocsCommandLocalPathSafety static gate was completed on `codex/qa-docs-command-local-path-safety`.
- Post-M6 QaDocsPowerShellInvocationSafety static gate was completed on `codex/qa-docs-powershell-invocation-safety-gate`.
- Post-M6 QaDocsRunnerExampleCoverageSafety static gate was completed on `codex/qa-docs-runner-example-coverage-safety`.
- Post-M6 QualityGatesDocsScopeSafety static gate was completed on `codex/quality-gates-docs-scope-safety-2`.
- Post-M6 BinaryFixturePlaceholderSafety static gate was completed on `codex/binary-fixture-placeholder-safety-gate`.
- Post-M6 ScriptEncodingSafety static gate was completed on `codex/script-encoding-safety-gate`.
- Post-M6 PowerShellStructuredSyntaxSafety static gate was completed on `codex/powershell-structured-syntax-safety-gate`.
- Post-M6 thread inactive/history-only lifecycle wording was completed on `codex/thread-inactive-history-docs`.
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
- Post-M6 ActiveVerificationCommandSafety static gate was completed on `codex/active-verification-command-safety`.
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
- Post-M6 WebViewBundleLocalReferenceSafety static gate was completed on `codex/webview-bundle-local-reference-safety-gate`.
- Post-M6 FixtureInventorySafety static gate was completed on `codex/fixture-inventory-safety-gate`.
- Post-M6 ScriptsInventorySafety static gate was completed on `codex/scripts-inventory-safety-gate`.
- Post-M6 UnsafeFixtureCoverageSafety static gate was completed on `codex/unsafe-fixture-coverage-safety-gate`.
- Post-M6 ActiveRunSafety scope coverage hardening was completed on `codex/active-run-safety-scope-coverage-hardening`.
- Post-M6 ActiveRunSafety current branch/status policy was completed on `codex/active-run-current-branch-status-policy`.
- Post-M6 ProdMetadataSafety canary target allowlist hardening was completed on `codex/prod-metadata-canary-target-allowlist-safety`.
- Post-M6 ProdMetadataSafety synthetic alias allowlist hardening was completed on `codex/prod-metadata-synthetic-alias-allowlist-safety`.
- Post-M6 SyntheticUsersSafety resource budget duration hardening was completed on `codex/synthetic-users-duration-safety`.
- Post-M6 ProdMetadataSafety canary alias duration hardening was completed on `codex/prod-metadata-canary-alias-duration-safety`.
- Post-M6 ProdMetadataSafety canary alias duration policy phrase hardening was completed on `codex/prod-metadata-canary-alias-duration-policy-safety`.
- Post-M6 GameSessionCanary synthetic alias direct validator hardening was completed on `codex/synthetic-users-game-session-canary-alias-safety`.
- Post-M6 GameSessionCanary synthetic alias allowlist hardening was completed on `codex/synthetic-users-game-session-canary-allowlist-safety`.
- Post-M6 GameSessionCanary synthetic alias duration hardening was completed on `codex/synthetic-users-game-session-canary-duration-safety`.
- Post-M6 GameSessionCanary synthetic alias environment hardening was completed on `codex/synthetic-users-game-session-canary-env-safety`.
- Post-M6 GameSessionCanary run-frequency budget hardening was completed on `codex/resource-budget-game-session-canary-runs-safety`.
- Post-M6 GameSessionCanary resource-budget policy flag hardening was completed on `codex/resource-budget-game-session-canary-policy-flags-safety`.
- Post-M6 GameSessionCanary suite metadata hardening was completed on `codex/game-session-canary-suite-metadata-safety`.
- Post-M6 GameSessionCanary readiness signal allowlist hardening was completed on `codex/prod-metadata-game-session-canary-readiness-signal-safety`.
- Post-M6 GameSessionCanary readiness signal uniqueness hardening was completed on `codex/prod-metadata-game-session-canary-readiness-signal-unique-safety`.
- Post-M6 GameSessionCanary runtime path empty-list hardening was completed on `codex/prod-metadata-game-session-canary-runtime-path-empty-safety`.
- Post-M6 GameSessionCanary suite metadata exact-set hardening was completed on `codex/prod-metadata-game-session-canary-suite-exact-safety`.
- Post-M6 GameSessionCanary unsafe fixture finding coverage hardening was completed on `codex/unsafe-fixture-game-session-canary-finding-coverage-safety`.
- Post-M6 GameSessionCanary runner input path safety hardening was completed on `codex/runner-game-session-canary-input-path-safety`.
- Post-M6 NonProdFoundation runner input path safety hardening was completed on `codex/runner-nonprod-foundation-input-path-safety`.
- Post-M6 TestabilityGaps runner input path safety hardening was completed on `codex/runner-testability-gaps-input-path-safety`.
- Post-M6 UpdateManifest runner input path safety hardening was completed on `codex/runner-update-manifest-input-path-safety`.
- Post-M6 BackendSmoke runner input path safety hardening was completed on `codex/runner-backend-smoke-input-path-safety`.
- Post-M6 WebViewBridge runner input path safety hardening was completed on `codex/runner-webview-bridge-input-path-safety`.
- Post-M6 AppSmoke runner input path safety hardening was completed on `codex/runner-app-smoke-input-path-safety`.
- Post-M6 Release runner input path safety hardening was completed on `codex/runner-release-input-path-safety`.
- Post-M6 Privacy runner input path safety hardening was completed on `codex/runner-privacy-input-path-safety`.
- Post-M6 ProdSafeSmoke runner input path safety hardening was completed on `codex/runner-prod-safe-smoke-input-path-safety`.
- Post-M6 ProdCanary runner input path safety hardening was completed on `codex/runner-prod-canary-input-path-safety`.
- Post-M6 RunnerSafety input path coverage hardening was completed on `codex/runner-safety-input-path-coverage`.
- Post-M6 Scripts Readme Scope Safety TestabilityGaps duplicate cleanup was completed on `codex/scripts-readme-testabilitygaps-duplicate-cleanup`.
- Post-M6 QualityGatesDocsScopeSafety input path summary sync was completed on `codex/quality-gates-docs-input-path-summary-sync`.
- Post-M6 RunnerSafety implementation-status input path sync was completed on `codex/implementation-status-runner-input-path-sync`.
- Post-M6 Active current-state installed artifact wording sync was completed on `codex/current-state-installed-artifact-active-wording`.
- Post-M6 ActiveRunSafety installed artifact source wording guard was completed on `codex/active-run-installed-artifact-source-safety`.
- Post-M6 Implementation-status M1 installed artifact history wording sync was completed on `codex/implementation-status-m1-installed-artifact-history`.
- Post-M6 ActiveRunSafety implementation-status installed artifact source wording guard was completed on `codex/active-run-implementation-status-artifact-source-safety`.
- Post-M6 QA docs installed artifact manual-boundary wording sync was completed on `codex/qa-docs-installed-artifact-manual-boundary`.
- Post-M6 QaDocsSafety installed artifact manual-boundary wording guard was completed on `codex/qa-docs-installed-artifact-boundary-safety`.
- New independent autonomous tasks require a separate Codex thread. Continuing M3 implementation in the previous thread is recorded as `PROCESS_ERROR_THREAD_REUSE`.
- Each dedicated task thread is active only for its own task and becomes inactive/history-only after handoff, completion or takeover. Old source, coordinator and delegated task threads are preserved for history, are not deleted, are not archived automatically unless the user explicitly asks, and must not be used to implement new independent tasks. Previous source thread `019e793c-4e53-7be0-90c7-10ff5a02c8b1` became inactive/history-only after handoff to `019e7aab-dbaf-70d0-b143-ed7e6eb0bde0`.
- Extended autonomous time, push permission and merge permission do not waive thread-per-task.
- Each newly selected follow-up quality gate, hardening item, feature slice, backlog item or milestone is a new independent task unless it only repairs verification for the current task.
- Current autonomous verification source: committed local fixtures only. Installed artifact reads from `C:\Program Files\MTC Fog Play` require a separate explicit approved plan.
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
- QaDocsCommandLocalPathSafety statically checks command-looking `run-*.ps1` examples in active QA docs so documented runner invocations stay local fixture-oriented and do not include installed-client paths, user runtime paths, endpoints, localhost or WebView debug/CDP references.
- QaDocsPowerShellInvocationSafety statically checks command-looking `run-*.ps1` examples in active QA docs so documented runner invocations use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...` while preserving dry-run guard flags.
- QaDocsRunnerExampleCoverageSafety statically checks active QA runner/doc contracts so each local FrameworkInventorySafety runner has a command-looking dry-run example in its mapped QA doc.
- QualityGatesDocsScopeSafety statically checks the preferred `docs/context/engineering/quality-gates.md` command block so supported `quality-gate.ps1 -Scope` commands stay exact, unique and known.
- BinaryFixturePlaceholderSafety statically checks binary-like files under `testdata/` so executable/library/package fixtures stay tiny placeholders, real PE files are rejected and dump/database/debug extensions cannot be added silently.
- ScriptEncodingSafety statically checks `scripts/*.ps1` byte encoding so local runners stay BOM-free and ASCII-only for Windows PowerShell parser safety.
- PowerShellStructuredSyntaxSafety statically checks local PowerShell parser syntax across `scripts/*.ps1`, `src/TestFramework/**/*.ps1` and `src/TestFramework/**/*.psm1` without importing modules or executing scripts.
- ProdSafetyFrameworkSafety statically checks the ProdSafety README, module exports and regression assertion text around classification, kill switch, synthetic user, resource budget and cleanup guard contracts.
- RepositoryRootInventorySafety statically checks the repository-root file and directory inventory.
- RootPromptSafety statically checks top-level Codex prompt/TZ safety wording around repository source-of-truth, autonomy boundaries, production-impact stops and game-session/credential prerequisites.
- Script runner inventory is documented in `scripts/README.md` and checked by the `Context` quality gate.
- Release and privacy runners require `-DryRun` before reading artifact roots.
- ProdCanary, ProdSafeSmoke, Privacy, Release, GameSessionCanary, NonProdFoundation, TestabilityGaps, UpdateManifest, BackendSmoke, WebViewBridge and AppSmoke runners reject AppData/log/cookie/DB/dump-like input path overrides before reading or probing them.
- ProdSafety, App/WebView, WebView bridge and BackendSmoke runners/validators fail closed on missing `-DryRun`; App/WebView and WebView bridge runners also reject client launch and WebView debug/CDP flags, and BackendSmoke rejects `-AllowNetwork` and `-AllowAuth`.
- UpdateManifest, BackendSmoke, GameSessionCanary, NonProdFoundation and TestabilityGaps quality gates assert rejection of dangerous allow flags.
- RunnerSafety statically checks runner dry-run requirements, dangerous allow-switch guards, path-like input guards and forbidden runtime/network primitives.
- TestDataSafety statically checks risky test fixtures against an explicit unsafe/negative allowlist.
- TestDataInventorySafety statically checks the `testdata/` fixture file inventory.
- Context gate checks that `docs/context/engineering/quality-gates.md` lists every supported `quality-gate.ps1 -Scope` value.
- ActiveRunSafety statically checks active handoff/current-state safety boundaries, stop triggers, stale literal latest-commit markers and stale literal historical thread ids declared as the active task thread.
- ActiveRunSafety also checks that active-run's current milestone marker stays synced with the latest verification-memory codex branch entry and that last-verification notes include active-run coverage.
- ActiveRunSafety derives current static safety scope coverage from `quality-gate.ps1` so newly added `*Safety` scopes cannot drift out of active/current context checks.
- ActiveRunSafety uses `git status --short --branch` as the authoritative current branch/worktree source instead of a live literal active-run branch value.
- ActiveRunSafety rejects active current-state wording that makes installed artifacts the current autonomous verification source.
- ActiveRunSafety rejects implementation-status wording that regresses installed artifact observations into the current autonomous verification source.
- SessionLogSafety statically checks guarded session-log branch entries for mode, branch, scope and core no-runtime/no-production safety notes, validates the latest codex branch entry for thread lifecycle wording, and keeps the latest session-log codex branch synced with verification-memory.
- VerificationMemorySafety statically checks verification-memory branch entries for pending markers, missing evidence fields, no-impact static/local-static `Not run:` rationale and latest-entry core safety notes.
- ActiveVerificationCommandSafety statically checks active/current verification command evidence in active-run Last verification and the newest verification-memory Commands block so command evidence stays local/static and rejects installed-client paths, user runtime paths, URLs, localhost/debug/CDP references, direct runners, auth/network/session/update/dependency and CI commands.
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
- SyntheticUsersSafety, ResourceBudgetSafety, AllowedGamesSafety, ProdMetadataSafety, UnsafeFixtureCoverageSafety and GameSessionCanary statically check production guard fixture drift around aliases, canary duration budgets, run-frequency budgets, cleanup/conditional budget flags, game allowlists, production metadata, canary suite metadata, readiness signal allowlists, synthetic alias allowlist links, direct canary plan alias metadata, allowlisting, production environment permission and matched synthetic-user duration, metadata-scoped alias duration, policy wording, canary target allowlist consistency and unsafe canary finding-id coverage.
- ContextDocsInventorySafety statically checks the `docs/context/*.md` handoff/governance/engineering inventory.
- IncidentStopSafety statically checks the incident stop trigger vocabulary against active handoff and testability gap fixtures.
- QaDocsSafety statically checks the required `docs/qa/*.md` policy inventory and core safety phrases.
- ArtifactPolicySafety statically checks release/privacy policy fixtures for required file, forbidden extension, finding id, privacy pattern and scan-limit drift.
- ContractFixtureSafety statically checks backend, update manifest and WebView bridge fixtures for dry-run, local-only and safety-vocabulary drift.
- StaticSurfaceSafety statically checks App/WebView smoke and non-prod foundation fixtures for static layout, WebView bundle inventory and schema-only non-runtime drift.
- WebViewBundleLocalReferenceSafety statically checks fixture WebView bundle entrypoints and manifests for remote URLs, localhost/debug/CDP references, user runtime paths, production endpoints and non-local manifest paths.
- FixtureInventorySafety statically checks release, privacy and App/WebView smoke fixture directory trees for required positive, negative and clean local fixture files.
- ScriptsInventorySafety statically checks the `scripts/` runner/support file inventory.
- UnsafeFixtureCoverageSafety statically checks `testdata/*unsafe*.example.json` fixtures so every unsafe fixture keeps a negative coverage block with the fixture path and expected `Assert-FindingId` finding-id assertions.
- The installed artifact is not release-clean by current policy: unsigned `rds-client.exe`/`Uninstall.exe`/`crashpad_handler.exe`, sourcemaps, source map references and a local path in `installer_info.txt` were reported.
