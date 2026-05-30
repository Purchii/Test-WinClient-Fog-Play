# Quality gates

Preferred script:

```powershell
.\scripts\quality-gate.ps1 -Scope Context
.\scripts\quality-gate.ps1 -Scope ProdSafety
.\scripts\quality-gate.ps1 -Scope Release
.\scripts\quality-gate.ps1 -Scope UpdateManifest
.\scripts\quality-gate.ps1 -Scope Privacy
.\scripts\quality-gate.ps1 -Scope AppSmoke
.\scripts\quality-gate.ps1 -Scope BridgeContract
.\scripts\quality-gate.ps1 -Scope BackendSmoke
.\scripts\quality-gate.ps1 -Scope GameSessionCanary
.\scripts\quality-gate.ps1 -Scope NonProdFoundation
.\scripts\quality-gate.ps1 -Scope Full
```

Initial scopes may be skeleton/dry-run, but the names and expected behavior should be stable.
