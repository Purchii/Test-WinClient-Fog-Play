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
