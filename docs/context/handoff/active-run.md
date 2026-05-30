# Active run

Status: starter package created.

Execution mode: not started yet; default `NON_AUTONOMOUS` until the first current-milestone plan is accepted.

Current milestone: `M0`.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current milestone = detailed technical implementation plan for M0 only.
Future milestones = high-level until their own NON_AUTONOMOUS planning step.
```

Accepted plan status: not accepted yet.

Autonomy boundary: none yet. `BOUNDED_AUTONOMOUS` becomes allowed only after the user accepts the detailed M0 plan.

Stop-and-ask triggers:

- production impact;
- credentials/secrets;
- game session;
- CI/CD enablement;
- scope expansion;
- dependency upgrade;
- ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier weakening;
- commit/push if not explicitly allowed;
- merge to main.

Current recommended goal:

```text
Implement production-safe QA automation guard foundation.
```

Branch:

```text
codex/prod-safety-foundation
```

Allowed in M0:

- AGENTS.md;
- docs/context/**;
- docs/qa/prod-safety policies;
- docs/codex/**;
- ProdSafety skeleton;
- dry-run scripts;
- testdata examples.

Forbidden in M0:

- real production game-session tests;
- load/stress/chaos/destructive tests;
- update rollback on production;
- hardcoded credentials;
- real user accounts;
- weakening guard/kill switch;
- merge to main without explicit approval.

Verification plan:

- ProdGuard unit/dry-run tests;
- prod-safe command dry-run;
- conditional command rejection without explicit flag;
- context docs updated;
- git status and diff check.
