# Quality gates

Preferred script:

```powershell
.\scripts\quality-gate.ps1 -Scope Context
.\scripts\quality-gate.ps1 -Scope RunnerSafety
.\scripts\quality-gate.ps1 -Scope TestDataSafety
.\scripts\quality-gate.ps1 -Scope SyntheticUsersSafety
.\scripts\quality-gate.ps1 -Scope AllowedGamesSafety
.\scripts\quality-gate.ps1 -Scope ResourceBudgetSafety
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

The `RunnerSafety` scope statically checks `scripts/*.ps1` and `src/TestFramework` for production-safety drift: every `run-*.ps1` runner must expose and require `-DryRun`, dangerous `Allow*` switches must be explicitly rejected unless allowlisted, and forbidden runtime/network primitives must not appear.

The `TestDataSafety` scope statically checks `testdata/` text fixtures so risky content such as credentials, bearer tokens, user runtime paths and non-placeholder URLs only appears in explicit unsafe/negative fixture allowlists.

The `SyntheticUsersSafety` scope statically checks `testdata/synthetic-users.example.json` and the synthetic users policy so allowlisted users remain alias-only, contain no credential-like fields or values, and reserve game-session permission for bounded canary aliases.

The `AllowedGamesSafety` scope statically checks `testdata/allowed-games.example.json` and the game-session canary policy so production canary games remain alias-only QA entries with bounded `allowedFor` purposes.

The `ResourceBudgetSafety` scope statically checks `testdata/prod-resource-budget.example.yaml`, `testdata/allowed-games.example.json` and the resource budget policy so production canary budgets stay single-session, short-duration, cleanup-gated and tied to allowlisted QA game aliases.

The `ProdMatrixSafety` scope statically checks `docs/qa/prod-safe-test-matrix.md` so scenario classifications stay within allowed production-safety values, session/stream scenarios are not marked `PROD_SAFE`, and forbidden production scenarios document `NON_PROD_ONLY` handling.

The `BacklogSafety` scope statically checks `docs/qa/value-effort-backlog.md` so roadmap rows stay bounded to M0-M6, value/effort stay in the 1-5 range, and runtime/non-prod milestones remain lower priority until prerequisites are approved.
