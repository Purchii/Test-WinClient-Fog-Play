# Non-prod foundation

M6 implements a local, dry-run validator for future non-production fake, replay, network and hardware regression foundations.

This milestone does not create runnable fake services, replay servers, network shapers, hardware probes or update rollback execution. It validates that future component definitions are safe placeholders only.

Implemented safety checks:

- the runner is dry-run only;
- runner plan path overrides reject AppData/log/cookie/DB/dump-like runtime paths before reading;
- client launch, WebView debug/CDP, network calls, authentication and runtime data reads are disabled;
- CI/CD enablement and dependency changes are outside scope;
- components are `NON_PROD_ONLY`;
- components are schema/config placeholders only;
- components must not use production, credentials, state mutation or game-session starts;
- runtime user paths, production URLs, auth headers, cookies, tokens, secrets, logs, DBs and dumps are rejected;
- each future component has a local contract schema.

Current supported component types:

- `fake-backend`;
- `fake-signaling`;
- `replay-server`;
- `network-shaper`;
- `hardware-matrix`;
- `update-rollback-lab`.

Production safety:

- M6 has no production impact.
- No installed client is launched.
- No WebView debug/CDP is enabled.
- No authentication or credentials are used.
- No production backend or streaming calls are made.
- No game session is started or stopped.
- No AppData, logs, cookies, local DBs or dumps are read.

Verification:

```powershell
.\src\TestFramework\NonProdFoundation\NonProdFoundation.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-nonprod-foundation.ps1 -DryRun
.\scripts\quality-gate.ps1 -Scope NonProdFoundation
```

Post-M6 guard hardening added `NonProdFoundation` quality gate assertions that unsafe runtime input paths, `-AllowExecution`, `-AllowNetwork` and `-AllowAuth` are rejected before any fake/replay execution, network call, authentication or runtime data read can occur.
