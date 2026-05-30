# Active run

Status: thread lifecycle governance correction in progress.

Execution mode: `BOUNDED_AUTONOMOUS` for the user-requested documentation correction only.

Current milestone: governance correction before M3 implementation.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = document thread-per-task lifecycle and record the current thread reuse process error.
Future milestones = high-level until their own NON_AUTONOMOUS planning step in a separate thread.
```

Current branch:

```text
codex/thread-lifecycle-governance
```

Current goal:

```text
Document that every new independent autonomous task or milestone requires a separate Codex thread, `create_thread` is the priority mechanism, Codex worktrees are used when follow-on tasks need isolated branch/workspace state, and the current M3 continuation attempt is `PROCESS_ERROR_THREAD_REUSE`.
```

Thread creation status:

```text
Incomplete M3 thread attempt: 019e7902-70cb-7f31-8487-907e53f1fc45, inactive/orphan because AppServerManager was unavailable and the thread could not receive messages or title updates.
Successful M3 thread retry: 019e7907-e739-7213-a690-125ea2fbafeb.
Worktree fallback is reserved for a second normal create_thread failure or a task that needs isolated branch/workspace state immediately.
```

Allowed now:

- `AGENTS.md`;
- `docs/context/handoff/**`;
- `docs/context/governance/**`;
- `docs/codex/codex-workflow.md`.

Forbidden now:

- M3 implementation;
- WebView bridge contract implementation;
- fake-host implementation;
- client launch;
- WebView debug/CDP port;
- authentication;
- game session;
- production backend interaction;
- reading user AppData, cookies, local DB, logs or crash dumps;
- update/rollback flows;
- CI/CD enablement;
- dependency upgrades;
- weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier;
- merge to `main` without explicit approval.

Stop-and-ask triggers:

- any request to implement M3 in this thread before handoff to a dedicated M3 thread;
- any need to start `rds-client.exe`;
- any need for credentials or synthetic login;
- any need for WebView debug port;
- any need to read user runtime files;
- any production-impacting action;
- scope expansion beyond static/dry-run M2.

Verification plan:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `git diff --check`;
- `git status --short --branch`.
