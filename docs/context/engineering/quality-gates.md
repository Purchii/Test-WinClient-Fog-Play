# Quality gates

Preferred script:

```powershell
.\scripts\quality-gate.ps1 -Scope Context
.\scripts\quality-gate.ps1 -Scope RunnerSafety
.\scripts\quality-gate.ps1 -Scope TestDataSafety
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
