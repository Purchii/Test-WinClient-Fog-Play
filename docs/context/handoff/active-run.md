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
Document that every new independent autonomous task or milestone requires a separate Codex thread, and record the current M3 continuation attempt as `PROCESS_ERROR_THREAD_REUSE`.
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
