# App/WebView smoke

M2 implements a static, dry-run App launch and WebView/CEF smoke scaffold.

The goal is to verify that an installed or fixture artifact has the minimum executable, CEF and local WebView resource layout needed for a future launch smoke, without launching the client.

Default artifact path:

```text
C:\Program Files\MTC Fog Play
```

Default policy:

```text
testdata/app-webview-smoke.example.json
```

Implemented checks:

- required client and CEF files exist;
- expected WebView bundle directories exist;
- each WebView bundle has `index.html` and `asset-manifest.json`;
- asset manifests are parseable;
- asset manifests include `main.css`, `main.js` and `index.html`;
- policy is dry-run only;
- policy does not request unsafe launch arguments such as WebView debug port;
- policy does not request user runtime paths, logs, cookies or dumps;
- policy test metadata passes ProdGuard as `PROD_SAFE`.

Safety defaults:

- no client process is launched;
- no WebView debug port is enabled;
- no authentication is attempted;
- no game session is started;
- no user AppData, cookies, local DB, logs or crash dumps are read.

`scripts/run-app-webview-smoke.ps1` fails unless `-DryRun` is used. `-AllowClientLaunch` and `-AllowWebViewDebugPort` are intentionally blocked in M2 and require a separate approved milestone.

Post-M6 guard hardening added `AppSmoke` quality gate assertions that missing `-DryRun`, `-AllowClientLaunch` and `-AllowWebViewDebugPort` are rejected before any client launch or debug action can occur. The direct validator also returns a `dry-run-flag-required` fail finding without `-DryRun`.

Known limitation:

- M2 proves static artifact readiness only. It does not prove that the main window opens or that WebView content renders at runtime.
