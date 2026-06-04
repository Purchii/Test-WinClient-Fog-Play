# WebView/native bridge contract

M3 implements a local, dry-run WebView/native bridge contract and fake native host scaffold.

The goal is to prevent silent breakage between WebView UI and the native C++ host before real source-level bridge handlers are available.

Default contract:

```text
testdata/webview-bridge-contract.example.json
```

Implemented checks:

- command registry exists;
- event registry exists;
- command names and event names are stable identifiers;
- command direction is `web -> native`;
- event direction is `native -> web`;
- payload schemas exist;
- expected effects and malformed-payload behavior are documented;
- logging policy requires sanitized output and no secrets;
- production safety is `PROD_SAFE` local contract only;
- fake native host cases target known commands/events;
- malformed fake-host cases expect rejection, error or ignore behavior;
- policy does not request WebView debug/CDP diagnostics;
- runner contract path overrides reject AppData/log/cookie/DB/dump-like runtime paths before reading;
- policy does not request user runtime paths, logs, cookies, DBs or dumps;
- policy test metadata passes ProdGuard as `PROD_SAFE`.

Safety defaults:

- no client process is launched;
- no WebView debug/CDP port is enabled or used;
- no authentication is attempted;
- no game session is started;
- no user AppData, cookies, local DB, logs or crash dumps are read.

Runner:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-webview-bridge-contract.ps1 -DryRun
```

Post-M6 guard hardening added `BridgeContract` quality gate assertions that unsafe runtime input paths, unsafe bridge logging policies, missing `-DryRun`, `-AllowClientLaunch` and `-AllowWebViewDebugPort` are rejected before any client launch, debug action or runtime data read can occur. The direct validator also returns a `dry-run-flag-required` fail finding without `-DryRun`.

Post-M6 finding coverage hardening added direct dry-run contract assertions for invalid command direction, missing command/event production-safety metadata, invalid or duplicate event names, invalid fake native host case types, missing fake host expected results and malformed fake host cases that do not expect rejection, error or ignore behavior.

Known limitation:

- M3 proves local contract shape and fake-host dry-run expectations only. It does not verify real C++ bridge handlers or runtime WebView behavior because client source and approved debug/runtime access are not available.
