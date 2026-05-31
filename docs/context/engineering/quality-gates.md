# Quality gates

Preferred script:

```powershell
.\scripts\quality-gate.ps1 -Scope Context
.\scripts\quality-gate.ps1 -Scope RepositoryRootInventorySafety
.\scripts\quality-gate.ps1 -Scope RootPromptSafety
.\scripts\quality-gate.ps1 -Scope ProdSafetyFrameworkSafety
.\scripts\quality-gate.ps1 -Scope ScriptEncodingSafety
.\scripts\quality-gate.ps1 -Scope PowerShellStructuredSyntaxSafety
.\scripts\quality-gate.ps1 -Scope BinaryFixturePlaceholderSafety
.\scripts\quality-gate.ps1 -Scope QaDocsCommandSafety
.\scripts\quality-gate.ps1 -Scope QaDocsCommandLocalPathSafety
.\scripts\quality-gate.ps1 -Scope QaDocsPowerShellInvocationSafety
.\scripts\quality-gate.ps1 -Scope QaDocsRunnerExampleCoverageSafety
.\scripts\quality-gate.ps1 -Scope QualityGatesDocsScopeSafety
.\scripts\quality-gate.ps1 -Scope ActiveSafetyScopeInventorySafety
.\scripts\quality-gate.ps1 -Scope ScriptsReadmeScopeSafety
.\scripts\quality-gate.ps1 -Scope GovernanceHistoryScopeSafety
.\scripts\quality-gate.ps1 -Scope TestDataStructuredSyntaxSafety
.\scripts\quality-gate.ps1 -Scope QualityGateStructureSafety
.\scripts\quality-gate.ps1 -Scope ActiveRunSafety
.\scripts\quality-gate.ps1 -Scope ContextDocsInventorySafety
.\scripts\quality-gate.ps1 -Scope SessionLogSafety
.\scripts\quality-gate.ps1 -Scope VerificationMemorySafety
.\scripts\quality-gate.ps1 -Scope ActiveVerificationCommandSafety
.\scripts\quality-gate.ps1 -Scope ChecklistSafety
.\scripts\quality-gate.ps1 -Scope DecisionsLogSafety
.\scripts\quality-gate.ps1 -Scope CodexPolicySafety
.\scripts\quality-gate.ps1 -Scope TaskRequestSafety
.\scripts\quality-gate.ps1 -Scope CodexTemplateSafety
.\scripts\quality-gate.ps1 -Scope CodexGoalTemplateSafety
.\scripts\quality-gate.ps1 -Scope CodexDocsInventorySafety
.\scripts\quality-gate.ps1 -Scope QaStrategySafety
.\scripts\quality-gate.ps1 -Scope HandoffProtocolSafety
.\scripts\quality-gate.ps1 -Scope IncomingReferenceSafety
.\scripts\quality-gate.ps1 -Scope FrameworkInventorySafety
.\scripts\quality-gate.ps1 -Scope TestFrameworkInventorySafety
.\scripts\quality-gate.ps1 -Scope IncidentStopSafety
.\scripts\quality-gate.ps1 -Scope QaDocsSafety
.\scripts\quality-gate.ps1 -Scope ArtifactPolicySafety
.\scripts\quality-gate.ps1 -Scope ContractFixtureSafety
.\scripts\quality-gate.ps1 -Scope StaticSurfaceSafety
.\scripts\quality-gate.ps1 -Scope WebViewBundleLocalReferenceSafety
.\scripts\quality-gate.ps1 -Scope FixtureInventorySafety
.\scripts\quality-gate.ps1 -Scope ScriptsInventorySafety
.\scripts\quality-gate.ps1 -Scope RunnerSafety
.\scripts\quality-gate.ps1 -Scope TestDataSafety
.\scripts\quality-gate.ps1 -Scope TestDataInventorySafety
.\scripts\quality-gate.ps1 -Scope UnsafeFixtureCoverageSafety
.\scripts\quality-gate.ps1 -Scope SyntheticUsersSafety
.\scripts\quality-gate.ps1 -Scope AllowedGamesSafety
.\scripts\quality-gate.ps1 -Scope ResourceBudgetSafety
.\scripts\quality-gate.ps1 -Scope ProdMetadataSafety
.\scripts\quality-gate.ps1 -Scope ProdMatrixSafety
.\scripts\quality-gate.ps1 -Scope BacklogSafety
.\scripts\quality-gate.ps1 -Scope ProdSafety
.\scripts\quality-gate.ps1 -Scope Release
.\scripts\quality-gate.ps1 -Scope UpdateManifest
.\scripts\quality-gate.ps1 -Scope Privacy
.\scripts\quality-gate.ps1 -Scope AppSmoke
.\scripts\quality-gate.ps1 -Scope BridgeContract
.\scripts\quality-gate.ps1 -Scope BackendSmoke
.\scripts\quality-gate.ps1 -Scope GameSessionCanary
.\scripts\quality-gate.ps1 -Scope NonProdFoundation
.\scripts\quality-gate.ps1 -Scope TestabilityGaps
.\scripts\quality-gate.ps1 -Scope Full
```

Initial scopes may be skeleton/dry-run, but the names and expected behavior should be stable.

The `Context` scope also verifies that every `scripts/*.ps1` runner is listed in `scripts/README.md`, so newly added runners cannot silently drift out of the documented local-safe command inventory.

The `Context` scope also verifies that every `quality-gate.ps1 -Scope` value is listed in this document, so new gate scopes cannot silently drift out of the documented command inventory.

The `Context` scope also verifies that every documented scope except `Full` is included exactly once in a `Full` dispatch block, so new gates cannot silently stay out of the complete local verification command.

The `RepositoryRootInventorySafety` scope statically checks repository-root file and directory inventory so top-level prompts, policies and workspace directories cannot be added, removed or renamed silently.

The `RootPromptSafety` scope statically checks top-level Codex prompt/TZ documents so source-of-truth wording, autonomy-mode boundaries, production-impact stop rules and game-session/credential guard prerequisites cannot be removed silently.

The `ProdSafetyFrameworkSafety` scope statically checks the ProdSafety README, module exports and regression assertion text so the core classification, kill switch, synthetic user, resource budget and cleanup guard contract cannot be weakened silently.

The `ScriptEncodingSafety` scope statically checks `scripts/*.ps1` byte encoding so local runners stay BOM-free and ASCII-only for Windows PowerShell parser safety.

The `PowerShellStructuredSyntaxSafety` scope statically checks PowerShell syntax for `scripts/*.ps1`, `src/TestFramework/**/*.ps1` and `src/TestFramework/**/*.psm1` using `[System.Management.Automation.Language.Parser]::ParseFile(...)` without importing modules or executing scripts.

The `BinaryFixturePlaceholderSafety` scope statically checks binary-like files under `testdata/` so executable/library/package fixtures stay tiny placeholders, real PE files are rejected and dump/database/debug extensions cannot be added silently.

The `QaDocsCommandSafety` scope statically checks command-looking `run-*.ps1` examples in active QA docs so documented runner invocations keep `-DryRun` and do not include forbidden runtime allow flags.

The `QaDocsCommandLocalPathSafety` scope statically checks command-looking `run-*.ps1` examples in active QA docs so documented runner invocations stay fixture-local and do not include installed-client paths, user runtime paths, endpoints, localhost or WebView debug/CDP references.

The `QaDocsPowerShellInvocationSafety` scope statically checks command-looking `run-*.ps1` examples in active QA docs so documented runner invocations use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...` while preserving dry-run guard flags.

The `QaDocsRunnerExampleCoverageSafety` scope statically checks active QA runner/doc contracts so each local runner owned by `FrameworkInventorySafety` has at least one command-looking dry-run example in its mapped QA doc.

The `QualityGatesDocsScopeSafety` scope statically checks the `docs/context/engineering/quality-gates.md` preferred command block so every `quality-gate.ps1` `ValidateSet` scope is listed exactly once, unknown scopes are rejected and command syntax stays stable.

The `ActiveSafetyScopeInventorySafety` scope statically checks `quality-gate.ps1` `*Safety` scopes against active/current state docs so new safety gates cannot disappear from handoff visibility.

The `ScriptsReadmeScopeSafety` scope statically checks `scripts/README.md` against all `quality-gate.ps1 -Scope` values so the local script command inventory cannot silently omit supported gate scopes.

The `GovernanceHistoryScopeSafety` scope statically checks all `quality-gate.ps1` `*Safety` scopes against verification memory and session log history so new safety gates cannot lose evidence or audit trail entries.

The `TestDataStructuredSyntaxSafety` scope statically checks that JSON fixtures under `testdata/` parse successfully and that the production resource budget YAML keeps its required top-level shape.

The `QualityGateStructureSafety` scope statically checks `quality-gate.ps1` itself so every `ValidateSet` scope except `Full` has exactly one `Invoke-<Scope>Gate` function and exactly one `Full` dispatch to that function.

The `ActiveRunSafety` scope statically checks `docs/context/handoff/active-run.md`, `docs/context/current-state.md`, `docs/context/engineering/implementation-status.md`, `docs/context/engineering/verification-memory.md` and handoff policy docs so stop-and-ask triggers stay explicit, stale literal latest-commit or live current-branch markers are not recorded, literal historical thread ids are not declared as the active task thread, installed artifact observations stay historical instead of becoming the current autonomous verification source, current static `*Safety` gates derived from `quality-gate.ps1` remain visible in active/current context, `git status --short --branch` remains the authoritative current branch/worktree source, and the active milestone marker stays synced with the latest verification-memory codex branch entry.

The `ContextDocsInventorySafety` scope statically checks `docs/context/*.md` inventory so handoff, governance and engineering context docs cannot be added, removed or renamed silently.

The `SessionLogSafety` scope statically checks guarded `docs/context/governance/session-log.md` branch entries so post-M6 work records mode, branch, scope and the core no-runtime/no-production safety phrases. It also checks the most recent codex branch entry for thread lifecycle wording and keeps the latest session-log codex branch synced with the latest verification-memory codex branch.

The `VerificationMemorySafety` scope statically checks `docs/context/engineering/verification-memory.md` so codex branch entries cannot retain pending markers; lose status, production-impact, command or result evidence; omit `Not run:` for no-impact static/local-static entries; or lose latest-entry core safety notes.

The `ActiveVerificationCommandSafety` scope statically checks only active/current command evidence in `docs/context/handoff/active-run.md` Last verification and the most recent `docs/context/engineering/verification-memory.md` Commands block so verification commands stay local/static quality-gate or git checks and do not include installed-client paths, user runtime paths, URLs, localhost/debug/CDP references, direct runners, auth/network/session/update/dependency or CI commands.

The `ChecklistSafety` scope statically checks `docs/context/handoff/executor-checklist.md` and `docs/context/governance/context-integrity-checklist.md` so thread isolation, verification records, stop triggers, secrets and production-impact checklist items remain explicit.

The `DecisionsLogSafety` scope statically checks `docs/context/governance/decisions-log.md` so accepted decisions around production safety, autonomy, thread isolation, push/merge authority and process errors remain explicit.

The `CodexPolicySafety` scope statically checks Codex and executor policy docs so autonomy, thread isolation, production-impact, credential, CI/CD, main-merge and game-session boundaries remain explicit.

The `TaskRequestSafety` scope statically checks task request template/log docs so new requests keep context, objective, scope, forbidden actions, production classification, acceptance criteria, verification commands and stop conditions.

The `CodexTemplateSafety` scope statically checks Codex review/task/communication/agent-role docs so Russian reporting, role separation, verification evidence, production classification, stop triggers, secrets and no-main-merge rules remain explicit.

The `CodexGoalTemplateSafety` scope statically checks the Codex goal template so future goals preserve execution mode, scope, forbidden actions, acceptance criteria, verification and stop conditions.

The `CodexDocsInventorySafety` scope statically checks `docs/codex/*.md` so Codex policy/template docs cannot be added, removed or renamed silently.

The `QaStrategySafety` scope statically checks QA strategy, testability contract and flakiness policy docs so layered test order, no-broad-E2E guidance, WebView debug defaults, runtime gap tracking and retry/session-budget rules remain explicit.

The `HandoffProtocolSafety` scope statically checks context protocol and Git workflow docs so source-of-truth ordering, latest-commit handling, thread isolation, worktree fallback, local verification and main-merge approval rules remain explicit.

The `IncomingReferenceSafety` scope statically checks `docs/_incoming_reference` inventory and source-of-truth wording so historical incoming references cannot silently become active scope.

The `FrameworkInventorySafety` scope statically checks `src/TestFramework`, runners, QA docs and fixture paths so implemented modules keep matching tests, local runners, documentation and example/unsafe fixtures.

The `TestFrameworkInventorySafety` scope statically checks `src/TestFramework` file inventory so framework modules, tests and local support docs cannot be added, removed or renamed silently.

The `IncidentStopSafety` scope statically checks `docs/qa/incident-stop-policy.md`, `docs/context/handoff/active-run.md` and `testdata/testability-gaps.example.json` so stop triggers stay centralized and gap-specific triggers remain in the approved incident-stop vocabulary.

The `QaDocsSafety` scope statically checks the `docs/qa/*.md` policy inventory and core safety phrases so QA policy docs cannot be added, removed or weakened silently. It also keeps installed artifact defaults in active QA docs bounded to manual/explicit-plan reads while autonomous verification remains committed local fixtures only.

The `ArtifactPolicySafety` scope statically checks release and privacy policy fixtures so required files, forbidden extensions, sanitized finding ids, privacy patterns and bounded scan limits cannot drift silently.

The `ContractFixtureSafety` scope statically checks backend, update manifest and WebView bridge fixtures so dry-run flags, local paths, read-only endpoint contracts, package integrity metadata and bridge safety vocabulary cannot drift silently.

The `StaticSurfaceSafety` scope statically checks App/WebView smoke and non-prod foundation fixtures so static artifact layout, WebView bundle inventory and future non-prod component placeholders remain local, dry-run and non-runtime.

The `WebViewBundleLocalReferenceSafety` scope statically checks fixture WebView bundle entrypoints and manifests so remote URLs, localhost/debug/CDP references, user runtime paths, production endpoints and non-local manifest paths cannot drift into the local smoke bundle.

The `FixtureInventorySafety` scope statically checks local fixture directory trees so release, privacy and App/WebView smoke fixtures keep their required positive, negative and clean file layouts.

The `ScriptsInventorySafety` scope statically checks `scripts/` file inventory so local runners and support docs cannot be added, removed or renamed silently.

The `RunnerSafety` scope statically checks `scripts/*.ps1` and `src/TestFramework` for production-safety drift: every `run-*.ps1` runner must expose and require `-DryRun`, dangerous `Allow*` switches must be explicitly rejected unless allowlisted, path-like runner inputs must keep unsafe runtime input path guards, and forbidden runtime/network primitives must not appear.

The `TestDataSafety` scope statically checks `testdata/` text fixtures so risky content such as credentials, bearer tokens, user runtime paths and non-placeholder URLs only appears in explicit unsafe/negative fixture allowlists.

The `TestDataInventorySafety` scope statically checks `testdata/` file inventory so fixture files cannot be added, removed or renamed silently.

The `UnsafeFixtureCoverageSafety` scope statically checks that every `testdata/*unsafe*.example.json` fixture is covered by a negative TestFramework or `quality-gate.ps1` assertion block with the fixture path and expected `Assert-FindingId` finding ids.

The `SyntheticUsersSafety` scope statically checks `testdata/synthetic-users.example.json`, the resource budget fixture and the synthetic users policy so allowlisted users remain alias-only, contain no credential-like fields or values, reserve game-session permission for bounded canary aliases and keep canary user duration within the resource budget.

The `AllowedGamesSafety` scope statically checks `testdata/allowed-games.example.json` and the game-session canary policy so production canary games remain alias-only QA entries with bounded `allowedFor` purposes.

The `ResourceBudgetSafety` scope statically checks `testdata/prod-resource-budget.example.yaml`, `testdata/allowed-games.example.json` and the resource budget policy so production canary budgets stay single-session, short-duration, cleanup-gated and tied to allowlisted QA game aliases.

The `ProdMetadataSafety` scope statically checks `testdata/prod-safety-tests.example.json`, `testdata/synthetic-users.example.json`, production guard allowlist fixtures and the production testing policy so runner suites keep the expected classifications, allowlisted synthetic aliases, canary alias duration budget, target metadata and session/cleanup flags.

The `ProdMatrixSafety` scope statically checks `docs/qa/prod-safe-test-matrix.md` so scenario classifications stay within allowed production-safety values, session/stream scenarios are not marked `PROD_SAFE`, and forbidden production scenarios document `NON_PROD_ONLY` handling.

The `BacklogSafety` scope statically checks `docs/qa/value-effort-backlog.md` so roadmap rows stay bounded to M0-M6, value/effort stay in the 1-5 range, and runtime/non-prod milestones remain lower priority until prerequisites are approved.
The `ProdSafety` scope validates local production-safety guard metadata without launching the client, authenticating or starting sessions, and asserts prod-safe smoke and prod canary runners reject unsafe runtime metadata, synthetic-user and resource-budget input paths before any read.

The `Release` scope validates local release artifact fixtures without launching the installed client, and asserts unsafe runtime `ArtifactRoot` and `PolicyPath` input paths are rejected before any read or probe.

The `Privacy` scope validates local privacy/logging fixtures without launching the installed client, and asserts unsafe runtime `ArtifactRoot` and `PatternsPath` input paths are rejected before any read or probe.

The `AppSmoke` scope validates the local App/WebView smoke scaffold without launching the installed client, and asserts unsafe runtime input paths, `-AllowClientLaunch` and `-AllowWebViewDebugPort` are rejected.

The `BridgeContract` scope validates the local WebView/native bridge contract scaffold without WebView debug/CDP or client launch, and asserts unsafe runtime input paths, `-AllowClientLaunch` and `-AllowWebViewDebugPort` are rejected.

The `BackendSmoke` scope validates the local backend smoke contract scaffold without network calls, auth headers or production backend interaction, and asserts unsafe runtime input paths, `-AllowNetwork` and `-AllowAuth` are rejected.

The `GameSessionCanary` scope validates the local dry-run canary readiness plan without starting or stopping a game session, requires exact non-duplicated canary readiness signals and canary suite metadata, empty runtime path requests, an allowlisted production canary synthetic alias, matching synthetic-user duration ceiling, bounded run-frequency budget and cleanup/conditional budget flags in direct plan validation, and asserts unsafe runtime input paths plus dangerous runtime allow flags are rejected.

The `NonProdFoundation` scope validates future fake/replay/network/hardware placeholder schemas without executing those systems, and asserts unsafe runtime input paths, `-AllowExecution`, `-AllowNetwork` and `-AllowAuth` are rejected.

The `TestabilityGaps` scope validates the local testability gap registry without closing runtime gaps, and asserts unsafe runtime input paths, `-AllowProductionAction`, `-AllowCredentials` and `-AllowRuntimeUserData` are rejected.

The `UpdateManifest` scope validates the local update manifest fixture without network, updater execution, rollback or credentials, and asserts unsafe runtime input paths, `-AllowNetwork`, `-AllowExecution`, `-AllowRollback` and `-AllowCredentials` are rejected.
