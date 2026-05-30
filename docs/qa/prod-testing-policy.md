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
