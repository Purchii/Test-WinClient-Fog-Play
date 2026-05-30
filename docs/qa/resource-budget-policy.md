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
