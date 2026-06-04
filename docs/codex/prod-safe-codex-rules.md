# Prod-safe Codex rules

Codex must not:

- run unclassified tests on production;
- run PROD_FORBIDDEN on production;
- run PROD_CONDITIONAL without explicit flag;
- use real user accounts;
- hardcode credentials;
- weaken ProdGuard/KillSwitch;
- add blind retries hiding instability;
- start game sessions before resource budget and cleanup verification exist.
