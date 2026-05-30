# Active run

Status: M3 WebView/native bridge contract implementation in progress.

Execution mode: `BOUNDED_AUTONOMOUS` for accepted M3 local contract/fake-host dry-run scope.

Current milestone: M3 WebView/native bridge contract + fake native host.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = implement local WebView/native bridge contract checks and fake native host dry-run scaffold.
Future milestones = high-level until their own NON_AUTONOMOUS planning step in a separate thread.
```

Current branch:

```text
codex/m3-webview-bridge-contract
```

Current goal:

```text
Implement M3 local WebView/native bridge contract and fake native host dry-run checks without launching the installed client or using WebView debug/CDP.
```

Thread creation status:

```text
Incomplete M3 thread attempt: 019e7902-70cb-7f31-8487-907e53f1fc45, inactive/orphan because AppServerManager was unavailable and the thread could not receive messages or title updates.
Successful M3 thread retry: 019e7907-e739-7213-a690-125ea2fbafeb.
Worktree fallback is reserved for a second normal create_thread failure or a task that needs isolated branch/workspace state immediately.
```

Allowed now:

- `docs/qa/webview-bridge-contract.md`;
- `src/TestFramework/WebViewBridge/**`;
- `scripts/run-webview-bridge-contract.ps1`;
- `scripts/quality-gate.ps1`;
- `testdata/webview-bridge-contract*.json`;
- M3 context/handoff/verification docs.

Forbidden now:

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

- any need to start `rds-client.exe`;
- any need for credentials or synthetic login;
- any need for WebView debug port;
- any need to read user runtime files;
- any production-impacting action;
- scope expansion beyond local M3 contract/fake-host dry-run.

Verification plan:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope BridgeContract`;
- `git diff --check`;
- `git status --short --branch`.
