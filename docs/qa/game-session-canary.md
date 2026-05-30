# Game-session canary readiness

M5 implements a local, dry-run readiness gate for a future minimal game-session canary.

This milestone does not execute a game session. It validates that the canary plan is safe enough to be reviewed before any separately approved real execution milestone.

Default plan:

```text
testdata/game-session-canary.example.json
```

Implemented checks:

- exactly one canary test is defined;
- canary test is classified as `PROD_CONDITIONAL`;
- canary requires an allowlisted synthetic user;
- canary declares `startsGameSession=true`, `mutatesState=true` and `requiresCleanupVerification=true`;
- target region and game are allowlisted by `prod-resource-budget.example.yaml`;
- target game is allowlisted by `allowed-games.example.json`;
- max duration is within the resource budget;
- retries are disabled;
- expected readiness signals include `stream-ready` and `first-frame`;
- policy is dry-run only;
- direct validator invocation requires the dry-run flag;
- real execution, client launch, network calls and authentication are disabled;
- policy does not request user runtime paths, logs, cookies, DBs or dumps;
- policy test metadata passes ProdGuard only with explicit `-AllowProdConditional` and `-CleanupVerified`.

The allowed-games fixture is intentionally alias-only. It must not contain real game titles, production endpoints, credentials or user runtime paths.

Safety defaults:

- no installed client process is launched;
- no WebView debug/CDP port is used;
- no authentication is attempted;
- no production backend or streaming service call is attempted;
- no game session is started;
- no real cleanup is attempted;
- no user AppData, cookies, local DB, logs or crash dumps are read.

Runner:

```text
scripts/run-game-session-canary.ps1 -DryRun -AllowProdConditional -CleanupVerified
```

Known limitation:

- M5 proves local readiness metadata and guard behavior only. It does not prove real login, catalog state, stream startup, first-frame rendering, session stop or cleanup until a separately approved production-conditional execution plan exists.
