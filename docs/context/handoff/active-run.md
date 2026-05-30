# Active run

Status: M0 implemented and verified locally; final report pending.

Execution mode: `BOUNDED_AUTONOMOUS` for accepted M0 scope.

Current milestone: `M0`.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current milestone = detailed technical implementation plan for M0 only.
Future milestones = high-level until their own NON_AUTONOMOUS planning step.
```

Accepted plan status: accepted by user continuation after M0 discovery plan.

Autonomy boundary: implement only M0 ProdSafety + Git/Handoff/Verification governance foundation; no production-impacting action, no credentials, no game sessions, no CI/CD enablement, no dependency upgrades, no merge to `main`.

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

Bootstrap note:

```text
The project repository was empty. Starter governance docs were committed as the local main baseline before creating the task branch.
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

Latest verification:

```text
2026-05-30: Context gate passed.
2026-05-30: ProdSafety gate passed.
2026-05-30: prod-safe smoke dry-run passed.
2026-05-30: prod canary dry-run rejected without explicit flag as expected.
2026-05-30: prod canary dry-run passed with explicit flag, resource budget and cleanup verification.
2026-05-30: git diff --check passed.
```
