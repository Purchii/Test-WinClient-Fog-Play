# Active run

Status: Post-M6 update manifest gate hardening implemented, verified and merged to `main`.

Execution mode: `BOUNDED_AUTONOMOUS` closeout after explicit user approval to work autonomously and push to `main`.

Current milestone: Post-M6 release/update manifest hardening complete.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current roadmap M0-M6 has local/dry-run foundations implemented through M6.
Post-M6 update manifest hardening is complete.
Future execution milestones require their own NON_AUTONOMOUS planning step in a separate thread.
```

Current branch:

```text
main
```

Current result:

```text
Local update manifest gate validates fixture policy shape without downloads, updater execution, rollback or credentials. Merged to origin/main at 7c14bf6.
```

Forbidden without a new approved plan:

- installed client launch;
- WebView debug/CDP port;
- authentication;
- real game session execution;
- production backend or streaming network interaction;
- fake/replay server runtime execution;
- network shaping;
- hardware inspection;
- credentials, secrets, bearer tokens, cookies or session headers;
- reading user AppData, cookies, local DB, logs or crash dumps;
- update/rollback execution;
- CI/CD enablement;
- dependency upgrades;
- weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier.

Stop-and-ask triggers:

- any need to start `rds-client.exe`;
- any need for credentials or synthetic login;
- any need for WebView debug port;
- any need for real backend URL, streaming URL or network calls;
- any need for auth headers, cookies, tokens or secrets;
- any need to read user runtime files;
- any need to execute a fake/replay server, network shaper or hardware probe;
- any need to execute or stop a real game session;
- any production-impacting action;
- scope expansion beyond local dry-run/schema validation.

Last verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope UpdateManifest`;
- `git diff --check`.
