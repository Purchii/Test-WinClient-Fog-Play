# Quality gates

Preferred script:

```powershell
.\scripts\quality-gate.ps1 -Scope Context
.\scripts\quality-gate.ps1 -Scope ActiveRunSafety
.\scripts\quality-gate.ps1 -Scope ContextDocsInventorySafety
.\scripts\quality-gate.ps1 -Scope SessionLogSafety
.\scripts\quality-gate.ps1 -Scope VerificationMemorySafety
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
.\scripts\quality-gate.ps1 -Scope IncidentStopSafety
.\scripts\quality-gate.ps1 -Scope QaDocsSafety
.\scripts\quality-gate.ps1 -Scope ArtifactPolicySafety
.\scripts\quality-gate.ps1 -Scope ContractFixtureSafety
.\scripts\quality-gate.ps1 -Scope StaticSurfaceSafety
.\scripts\quality-gate.ps1 -Scope FixtureInventorySafety
.\scripts\quality-gate.ps1 -Scope RunnerSafety
.\scripts\quality-gate.ps1 -Scope TestDataSafety
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

The `ActiveRunSafety` scope statically checks `docs/context/handoff/active-run.md`, `docs/context/current-state.md` and handoff policy docs so stop-and-ask triggers stay explicit, stale literal latest-commit markers are not recorded, current static safety gates remain visible in handoff context, and the active milestone marker stays synced with the latest static gate.

The `ContextDocsInventorySafety` scope statically checks `docs/context/*.md` inventory so handoff, governance and engineering context docs cannot be added, removed or renamed silently.

The `SessionLogSafety` scope statically checks guarded `docs/context/governance/session-log.md` branch entries so post-M6 work records mode, branch, scope and the core no-runtime/no-production safety phrases.

The `VerificationMemorySafety` scope statically checks `docs/context/engineering/verification-memory.md` so codex branch entries cannot retain pending markers or lose status, production-impact, command and result evidence.

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

The `IncidentStopSafety` scope statically checks `docs/qa/incident-stop-policy.md`, `docs/context/handoff/active-run.md` and `testdata/testability-gaps.example.json` so stop triggers stay centralized and gap-specific triggers remain in the approved incident-stop vocabulary.

The `QaDocsSafety` scope statically checks the `docs/qa/*.md` policy inventory and core safety phrases so QA policy docs cannot be added, removed or weakened silently.

The `ArtifactPolicySafety` scope statically checks release and privacy policy fixtures so required files, forbidden extensions, sanitized finding ids, privacy patterns and bounded scan limits cannot drift silently.

The `ContractFixtureSafety` scope statically checks backend, update manifest and WebView bridge fixtures so dry-run flags, local paths, read-only endpoint contracts, package integrity metadata and bridge safety vocabulary cannot drift silently.

The `StaticSurfaceSafety` scope statically checks App/WebView smoke and non-prod foundation fixtures so static artifact layout, WebView bundle inventory and future non-prod component placeholders remain local, dry-run and non-runtime.

The `FixtureInventorySafety` scope statically checks local fixture directory trees so release, privacy and App/WebView smoke fixtures keep their required positive, negative and clean file layouts.

The `RunnerSafety` scope statically checks `scripts/*.ps1` and `src/TestFramework` for production-safety drift: every `run-*.ps1` runner must expose and require `-DryRun`, dangerous `Allow*` switches must be explicitly rejected unless allowlisted, and forbidden runtime/network primitives must not appear.

The `TestDataSafety` scope statically checks `testdata/` text fixtures so risky content such as credentials, bearer tokens, user runtime paths and non-placeholder URLs only appears in explicit unsafe/negative fixture allowlists.

The `SyntheticUsersSafety` scope statically checks `testdata/synthetic-users.example.json` and the synthetic users policy so allowlisted users remain alias-only, contain no credential-like fields or values, and reserve game-session permission for bounded canary aliases.

The `AllowedGamesSafety` scope statically checks `testdata/allowed-games.example.json` and the game-session canary policy so production canary games remain alias-only QA entries with bounded `allowedFor` purposes.

The `ResourceBudgetSafety` scope statically checks `testdata/prod-resource-budget.example.yaml`, `testdata/allowed-games.example.json` and the resource budget policy so production canary budgets stay single-session, short-duration, cleanup-gated and tied to allowlisted QA game aliases.

The `ProdMetadataSafety` scope statically checks `testdata/prod-safety-tests.example.json` and the production testing policy so runner suites keep the expected classifications, aliases, target metadata and session/cleanup flags.

The `ProdMatrixSafety` scope statically checks `docs/qa/prod-safe-test-matrix.md` so scenario classifications stay within allowed production-safety values, session/stream scenarios are not marked `PROD_SAFE`, and forbidden production scenarios document `NON_PROD_ONLY` handling.

The `BacklogSafety` scope statically checks `docs/qa/value-effort-backlog.md` so roadmap rows stay bounded to M0-M6, value/effort stay in the 1-5 range, and runtime/non-prod milestones remain lower priority until prerequisites are approved.
