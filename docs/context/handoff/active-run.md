# Active run

Status: M4 safe backend smoke implementation in progress.

Execution mode: `BOUNDED_AUTONOMOUS` for accepted M4 local backend smoke dry-run scope.

Current milestone: M4 Safe backend smoke.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = implement local backend endpoint contract checks and fake response dry-run scaffold.
Future milestones = high-level until their own NON_AUTONOMOUS planning step in a separate thread.
```

Current branch:

```text
codex/m4-backend-smoke
```

Current goal:

```text
Implement M4 local backend smoke checks without real backend network calls, auth, credentials or state mutation.
```

Thread creation status:

```text
Incomplete M3 thread attempt: 019e7902-70cb-7f31-8487-907e53f1fc45, inactive/orphan because AppServerManager was unavailable and the thread could not receive messages or title updates.
Successful M3 thread retry: 019e7907-e739-7213-a690-125ea2fbafeb.
Worktree fallback is reserved for a second normal create_thread failure or a task that needs isolated branch/workspace state immediately.
```

Allowed now:

- `docs/qa/backend-smoke.md`;
- `src/TestFramework/BackendSmoke/**`;
- `scripts/run-backend-smoke.ps1`;
- `scripts/quality-gate.ps1`;
- `testdata/backend-smoke*.json`;
- M4 context/handoff/verification docs.

Forbidden now:

- client launch;
- WebView debug/CDP port;
- authentication;
- game session;
- production backend interaction;
- real backend network calls;
- credentials, secrets, bearer tokens, cookies or session headers;
- state-mutating backend methods;
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
- any need for real backend URL or network calls;
- any need for auth headers, cookies, tokens or secrets;
- any need for state-mutating backend requests;
- any need to read user runtime files;
- any production-impacting action;
- scope expansion beyond local M4 backend smoke dry-run.

Verification plan:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope BackendSmoke`;
- `git diff --check`;
- `git status --short --branch`.
