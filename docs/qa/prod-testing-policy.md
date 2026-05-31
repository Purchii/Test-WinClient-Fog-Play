# Production testing policy

Every test must be classified:

- `PROD_SAFE`
- `PROD_CONDITIONAL`
- `PROD_FORBIDDEN`
- `NON_PROD_ONLY`

Rules:

```text
No classification = no prod run.
No synthetic user guard = no prod auth test.
No resource budget = no prod game session test.
No cleanup verification = no prod state mutation test.
```

`PROD_SAFE` can run on production with guard checks.
`PROD_CONDITIONAL` requires explicit flag, synthetic users, resource budget and cleanup verification.
`PROD_FORBIDDEN` cannot run on production.
`NON_PROD_ONLY` must run only in local/staging/fake/replay environments.

## M0 guard implementation

The M0 implementation lives under `src/TestFramework/ProdSafety/`.

Production guard behavior:

- unclassified tests are rejected on production;
- invalid classifications are rejected;
- `PROD_FORBIDDEN` tests are rejected on production;
- `NON_PROD_ONLY` tests are rejected on production;
- `PROD_CONDITIONAL` tests require `-AllowProdConditional`;
- `PROD_CONDITIONAL` or game-session tests require an allowlisted synthetic user;
- game-session tests require a resource budget and cleanup verification;
- non-dry-run production automation requires `PROD_AUTOMATION_ENABLED`;
- non-dry-run production canary automation also requires `QA_PROD_CANARY_ENABLED`.

M0 scripts are dry-run capable and do not launch the client or start game sessions.

Post-M6 guard hardening made `run-prod-safe-smoke.ps1` and `run-prod-canary.ps1` reject calls without `-DryRun` before guard metadata execution.

Post-M6 prod-safe smoke runner input path hardening made `run-prod-safe-smoke.ps1` reject AppData/log/cookie/DB/dump-like `TestMetadataPath` and `SyntheticUsersPath` overrides before reading them.

Post-M6 prod canary runner input path hardening made `run-prod-canary.ps1` reject AppData/log/cookie/DB/dump-like `TestMetadataPath`, `SyntheticUsersPath` and `ResourceBudgetPath` overrides before reading them.

Committed production metadata fixtures must stay local, alias-only and suite-scoped. `prod-safe-smoke` entries must remain `PROD_SAFE`; `PROD_SAFE` metadata aliases must resolve to synthetic users with `prod_safe_login_logout` purpose and no game-session permission. `prod-canary` entries must remain `PROD_CONDITIONAL` and declare synthetic alias, target region, target game, session start, state mutation and cleanup verification metadata. Prod-canary synthetic aliases must resolve to synthetic users with `prod_conditional_stream_canary` purpose and bounded game-session permission within the committed resource budget. Prod-canary target region and target game metadata must stay allowlisted by the committed resource budget and allowed-games fixtures.
