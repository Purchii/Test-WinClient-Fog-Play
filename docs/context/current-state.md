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
Post-M6: Script inventory guard - implemented and verified locally.
Post-M6: M1 dry-run fail-closed hardening - implemented and verified locally.
Post-M6: Runner/validator guard hardening - implemented and verified locally.
Post-M6: Dangerous flag negative coverage - implemented and verified locally.
Post-M6: RunnerSafety static gate - implemented and verified locally.
Post-M6: TestDataSafety static gate - implemented and verified locally.
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
- Post-M6 script inventory guard hardening was completed on `codex/scripts-inventory-guard`.
- Post-M6 M1 dry-run fail-closed hardening was completed on `codex/m1-dryrun-fail-closed`.
- Post-M6 runner/validator guard hardening was completed on `codex/app-bridge-runner-guard`.
- Post-M6 dangerous flag negative coverage was completed on `codex/danger-flag-negative-coverage`.
- Post-M6 RunnerSafety static gate was completed on `codex/runner-safety-static-gate`.
- Post-M6 TestDataSafety static gate was completed on `codex/testdata-safety-gate`.
- New independent autonomous tasks require a separate Codex thread. Continuing M3 implementation in the previous thread is recorded as `PROCESS_ERROR_THREAD_REUSE`.
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
- Script runner inventory is documented in `scripts/README.md` and checked by the `Context` quality gate.
- Release and privacy runners require `-DryRun` before reading artifact roots.
- ProdSafety, App/WebView, WebView bridge and BackendSmoke runners/validators fail closed on missing `-DryRun`; App/WebView and WebView bridge runners also reject client launch and WebView debug/CDP flags.
- UpdateManifest, GameSessionCanary, NonProdFoundation and TestabilityGaps quality gates assert rejection of dangerous allow flags.
- RunnerSafety statically checks runner dry-run requirements, dangerous allow-switch guards and forbidden runtime/network primitives.
- TestDataSafety statically checks risky test fixtures against an explicit unsafe/negative allowlist.
- The installed artifact is not release-clean by current policy: unsigned `rds-client.exe`/`Uninstall.exe`/`crashpad_handler.exe`, sourcemaps, source map references and a local path in `installer_info.txt` were reported.
