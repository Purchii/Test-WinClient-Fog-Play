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
- The installed artifact is not release-clean by current policy: unsigned `rds-client.exe`/`Uninstall.exe`/`crashpad_handler.exe`, sourcemaps, source map references and a local path in `installer_info.txt` were reported.
