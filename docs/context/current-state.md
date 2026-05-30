# Current state

Project: MTC Fog Play Windows client QA automation.

Known context:

- Windows desktop client.
- Native layer: C++.
- Embedded WebView/CEF/WebView-like layer.
- Product: cloud gaming.
- Current automation may run against production.
- Production safety is the first priority.

Current recommended first milestone:

```text
M0: ProdSafety + Git/Handoff/Verification governance foundation.
```

Do not start real game-session automation before guard layer exists.

Repository bootstrap state:

- This is a new project repository.
- The remote repository was empty during M0 bootstrap.
- Starter governance docs were imported as the initial `main` baseline.
- M0 implementation is on `codex/prod-safety-foundation`.
- Windows client source, WebView/CEF/WebView2 frontend, native bridge handlers, updater/package scripts, existing tests/CI and telemetry/crash code are not present yet.
