# Testability contract

Potential safe testability hooks:

```text
--test-mode
--test-config=<path>
--log-dir=<path>
--crash-dump-dir=<path>
--clean-user-data
--disable-auto-update
--enable-diagnostics
--webview-debug-port=<localhost-port>
```

Debug/CDP ports must never be enabled for normal production users by default.

Runtime and environment gaps are tracked in `docs/qa/testability-gaps.md` and `testdata/testability-gaps.example.json`.
