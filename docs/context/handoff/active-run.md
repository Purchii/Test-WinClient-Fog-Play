# Active run

Status: M5 minimal game-session canary readiness gate in progress.

Execution mode: `BOUNDED_AUTONOMOUS` for accepted M5 dry-run readiness validator scope.

Current milestone: M5 Minimal game-session canary readiness gate.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = implement local game-session canary readiness plan validation only.
Future milestones = high-level until their own NON_AUTONOMOUS planning step in a separate thread.
```

Current branch:

```text
codex/m5-game-session-canary
```

Current goal:

```text
Implement a local dry-run validator for future game-session canary readiness without launching the client, authenticating, calling production backend or starting a game session.
```

Thread creation status:

```text
M5 is running in a dedicated new task thread after the prior create_thread worktree retry issue.
Previous M4 thread is handoff/planning history only and must not continue M5 implementation.
```

Allowed now:

- `docs/qa/game-session-canary.md`;
- `src/TestFramework/GameSessionCanary/**`;
- `scripts/run-game-session-canary.ps1`;
- `scripts/quality-gate.ps1`;
- `testdata/game-session-canary*.json`;
- M5 context/handoff/verification docs.

Forbidden now:

- installed client launch;
- WebView debug/CDP port;
- authentication;
- real game session execution;
- production backend or streaming network interaction;
- credentials, secrets, bearer tokens, cookies or session headers;
- reading user AppData, cookies, local DB, logs or crash dumps;
- update/rollback flows;
- CI/CD enablement;
- dependency upgrades;
- weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier;
- merge to `main` without explicit approval.

Stop-and-ask triggers:

- any need to start `rds-client.exe`;
- any need for credentials or synthetic login;
- any need for WebView debug port;
- any need for real backend URL, streaming URL or network calls;
- any need for auth headers, cookies, tokens or secrets;
- any need to read user runtime files;
- any need to execute or stop a real game session;
- any production-impacting action;
- scope expansion beyond local M5 dry-run readiness validation.

Verification plan:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\GameSessionCanary\GameSessionCanary.Tests.ps1`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope GameSessionCanary`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`;
- `git status --short --branch`.
