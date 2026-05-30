# Active run

Status: M6 future non-prod/fake/replay/network/hardware foundation in progress.

Execution mode: `BOUNDED_AUTONOMOUS` for accepted M6 local-only dry-run foundation scope.

Current milestone: M6 Future non-prod foundation.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = implement local schema/config dry-run validators only.
Future execution of fake/replay/network/hardware labs is out of scope until a separate plan.
```

Current branch:

```text
codex/m6-nonprod-foundation
```

Current goal:

```text
Implement a local dry-run validator for future NON_PROD_ONLY fake, replay, network and hardware foundation components without runtime execution, production interaction, client launch, auth or user runtime data reads.
```

Allowed now:

- `docs/qa/nonprod-foundation.md`;
- `src/TestFramework/NonProdFoundation/**`;
- `scripts/run-nonprod-foundation.ps1`;
- `scripts/quality-gate.ps1`;
- `testdata/nonprod-foundation*.json`;
- M6 context/handoff/verification docs.

Forbidden now:

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

Verification plan:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\NonProdFoundation\NonProdFoundation.Tests.ps1`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope NonProdFoundation`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `git diff --check`;
- `git status --short --branch`.
