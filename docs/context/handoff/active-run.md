# Active run

Status: M1.1 quality hardening in progress after multi-agent audit of M0/M1.

Execution mode: `BOUNDED_AUTONOMOUS` for corrective hardening requested by the user.

Current milestone: `M1.1`.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current work = harden already implemented M0/M1 quality gates and handoff docs.
Future milestones = high-level until their own NON_AUTONOMOUS planning step.
```

Accepted trigger: user requested multi-agent audit and then said `чини`.

Autonomy boundary: fix findings from the M0/M1 multi-agent audit; no client launch, no production-impacting action, no credentials, no game sessions, no CI/CD enablement, no dependency upgrades, no merge to `main`.

Agent mode: multi-agent by default. Current run uses real sub-agents for ProdSafety, Release/Privacy and Governance review, with Orchestrator integrating fixes.

Remote Git mode: remote-first when safe. Commit/push task branch only after verification and allowed user/project policy; do not merge `main` without explicit approval.

Current branch:

```text
codex/release-privacy-gates
```

Current goal:

```text
Harden M0/M1 gates so failing gates fail closed, fixtures cover real code paths, ProdSafety blocks known bypasses and handoff docs match actual Git state.
```

Allowed in M1.1:

- `AGENTS.md`;
- `docs/context/**`;
- `docs/qa/release-gates.md`;
- `docs/qa/privacy-and-logging-checks.md`;
- `scripts/quality-gate.ps1`;
- `scripts/run-release-gate.ps1`;
- `scripts/run-privacy-gate.ps1`;
- `scripts/run-prod-safe-smoke.ps1`;
- `scripts/run-prod-canary.ps1`;
- `src/TestFramework/ProdSafety/**`;
- `testdata/**` fixtures and example policies.

Forbidden in M1.1:

- client launch;
- real production game-session tests;
- authentication;
- reading user cookies, local DB, logs or crash dumps;
- load/stress/chaos/destructive tests;
- update rollback on production;
- hardcoded credentials;
- copying real release binaries into repo;
- CI/CD enablement;
- dependency upgrades;
- merge to `main` without explicit approval.

Stop-and-ask triggers:

- production impact;
- credentials/secrets;
- game session;
- client launch;
- need to read user AppData/logs/cookies/DB;
- scope expansion beyond M0/M1 hardening;
- dependency upgrade;
- merge to `main`.

Verification plan:

- Context, ProdSafety, Release, Privacy and Full quality gates;
- release gate negative fixture with expected findings;
- release gate clean fixture with `passed=true`;
- privacy installed-like, negative, large-file and clean fixtures;
- release/privacy dry-run against installed artifact in report-only mode;
- `git diff --check`;
- `git status --short --branch`.
