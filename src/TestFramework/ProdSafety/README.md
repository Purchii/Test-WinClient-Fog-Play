# ProdSafety framework

M0 provides a local, production-safe guard foundation for future QA automation.

The framework is intentionally dry-run capable and does not launch the Windows client, authenticate, start game sessions, or mutate production state.

## Classifications

Every test must declare exactly one classification:

- `PROD_SAFE`
- `PROD_CONDITIONAL`
- `PROD_FORBIDDEN`
- `NON_PROD_ONLY`

Production rules:

- no classification = no prod run;
- `PROD_FORBIDDEN` = no prod run;
- `NON_PROD_ONLY` = no prod run;
- `PROD_CONDITIONAL` requires an explicit flag, synthetic user, resource budget and cleanup verification;
- non-dry-run production automation requires `PROD_AUTOMATION_ENABLED`;
- non-dry-run production canary automation also requires `QA_PROD_CANARY_ENABLED`.

## Verification

Run from repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ProdSafety
```
