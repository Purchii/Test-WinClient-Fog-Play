# Resource budget policy

Any production test that starts a game session must have a resource budget.

Default budget:

```yaml
prodResourceBudget:
  maxSessionsPerRun: 1
  maxParallelSessions: 1
  maxSessionDurationSeconds: 120
  maxRunsPerHour: 3
  allowedRegions:
    - eu-west
  allowedGames:
    - qa-allowlisted-game-1
  requireCleanupVerification: true
  requireExplicitConditionalFlag: true
```

No uncontrolled retries that create new sessions.

Committed budget fixtures must stay local and alias-only. They must not contain production URLs, credentials, tokens, cookies, auth headers or user runtime paths, and production canary game aliases must also appear in the allowed-games fixture.
