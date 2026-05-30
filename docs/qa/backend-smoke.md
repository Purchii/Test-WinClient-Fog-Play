# Backend smoke

M4 implements a local, dry-run backend smoke scaffold.

The goal is to validate safe backend endpoint contracts before any real production backend interaction is approved.

Default policy:

```text
testdata/backend-smoke.example.json
```

Implemented checks:

- endpoint registry exists;
- endpoint method is read-only `GET`;
- endpoint classification is `PROD_SAFE`;
- endpoint does not require auth;
- endpoint does not mutate state;
- endpoint path does not include user ids, tokens, secrets or session values;
- response schema exists;
- mock response exists for offline validation;
- policy is dry-run only;
- real network calls are disabled;
- policy does not define auth, cookie, token, secret or session headers;
- policy does not request user runtime paths, logs, cookies, DBs or dumps;
- policy test metadata passes ProdGuard as `PROD_SAFE`.

Safety defaults:

- no real backend network call is attempted;
- no authentication is attempted;
- no game session is started;
- no mutating request is attempted;
- no user AppData, cookies, local DB, logs or crash dumps are read.

Runner:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-backend-smoke.ps1 -DryRun
```

Known limitation:

- M4 proves offline backend contract shape only. It does not prove real backend availability, auth, catalog freshness or release metadata correctness until a separately approved safe backend environment/config exists.

Post-M6 guard hardening added direct validator coverage for missing `-DryRun`; `Test-BackendSmokePolicy` now returns a `dry-run-flag-required` fail finding without the dry-run flag.
