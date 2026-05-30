# Active run

Status: M2 App/WebView smoke scaffold in progress.

Execution mode: `BOUNDED_AUTONOMOUS` for the accepted safe M2 direction, limited to static/dry-run artifact checks.

Current milestone: `M2`.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = App launch + WebView/CEF smoke scaffold, static/dry-run only.
Future milestones = high-level until their own NON_AUTONOMOUS planning step.
```

Current branch:

```text
codex/app-webview-smoke
```

Current goal:

```text
Add a dry-run App/WebView smoke gate that validates installed artifact layout and safety policy without launching the client.
```

Allowed in M2:

- `src/TestFramework/WindowsSmoke/**`;
- `scripts/run-app-webview-smoke.ps1`;
- `scripts/quality-gate.ps1`;
- `testdata/app-webview-smoke*.json`;
- `testdata/app-webview-smoke-fixture/**`;
- `docs/qa/app-webview-smoke.md`;
- M2 status updates in `docs/context/**`;
- `scripts/README.md`;
- `docs/context/engineering/quality-gates.md`.

Forbidden in M2:

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
- scope expansion beyond static/dry-run M2.

Verification plan:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope AppSmoke`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-app-webview-smoke.ps1 -ArtifactRoot "C:\Program Files\MTC Fog Play" -DryRun -ReportOnly`;
- `git diff --check`;
- `git status --short --branch`.
