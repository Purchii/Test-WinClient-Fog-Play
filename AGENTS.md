# AGENTS.md

# Codex operating rules for MTC Fog Play QA Automation

This repository is production-sensitive. The target application is a Windows cloud-gaming client with an embedded WebView/CEF/WebView-like layer.

## Non-negotiable production rules

```text
No classification = no prod run.
No synthetic user guard = no prod auth test.
No resource budget = no prod game session test.
No cleanup verification = no prod state mutation test.
No explicit canary flag = no PROD_CONDITIONAL run.
```

All tests must be classified as one of:

```text
PROD_SAFE
PROD_CONDITIONAL
PROD_FORBIDDEN
NON_PROD_ONLY
```

`PROD_FORBIDDEN` and `NON_PROD_ONLY` tests must not run against production.

Do not add load, stress, chaos, destructive, payment, anti-fraud, real-user-data or update-rollback tests on production.

Cloud gaming session tests must:

- use synthetic accounts only;
- use allowlisted games only;
- enforce max duration;
- use resource budget;
- stop the session in cleanup;
- verify cleanup;
- collect sanitized artifacts;
- avoid parallel execution unless explicitly approved;
- require explicit `-AllowProdConditional` or equivalent flag.

## Git rules

- Do not work directly on `main` for backlog tasks.
- Every bounded goal must use a dedicated task branch.
- Start from clean, up-to-date `main`.
- Keep changes scoped to the active task.
- Do not mix unrelated documentation, framework and scenario changes unless the goal explicitly allows it.
- Push task branches only after verification.
- Do not merge to `main` unless the user explicitly allows it.
- Never force-push to `main`.

## Source of truth rules

- Old chat context is advisory only.
- Repository docs and code are the source of truth.
- For every new independent task, re-read:
  1. `AGENTS.md`
  2. `docs/context/handoff/active-run.md`
  3. `docs/context/current-state.md`
  4. `docs/context/handoff/context-protocol.md`
  5. `docs/codex/codex-workflow.md`
  6. `docs/context/handoff/executor-policy.md`
  7. task-specific docs and code.

If a durable decision exists only in chat, record it in `docs/context/governance/decisions-log.md` before relying on it.


## Communication and reasoning rules

- User-facing answers, plans, status updates, blockers and final reports must be written in Russian by default.
- Keep technical identifiers unchanged: file paths, commands, class names, enum values, environment variables, branch names and test names.
- Do not expose private chain-of-thought or raw scratchpad reasoning.
- Instead, provide concise Russian reasoning summaries: assumptions, chosen approach, alternatives if relevant, production-safety implications, risks, verification and blockers.
- For non-trivial tasks, the final report must include: mode, what changed, short rationale, changed files, verification, production-safety result, risks/blockers and next step.
- Full policy: `docs/codex/communication-policy.md`.

## Autonomy mode rules

Codex must explicitly declare one of two modes for every goal:

```text
NON_AUTONOMOUS / supervised mode
BOUNDED_AUTONOMOUS mode
```

If the mode is not declared, default to `NON_AUTONOMOUS`.

Use `NON_AUTONOMOUS` for:

- first discovery and planning in a new repo/task;
- unclear scope;
- production-impacting actions;
- `PROD_CONDITIONAL` tests;
- any action that can start a game session;
- CI/CD changes that can automatically run production tests;
- credentials/secrets/auth configuration;
- dependency upgrades;
- changes to ProdGuard, KillSwitch, ResourceBudget or CleanupVerifier;
- commit/push if not explicitly allowed;
- any merge to `main`.

Use `BOUNDED_AUTONOMOUS` only after the user accepts a bounded plan with scope, forbidden actions, acceptance criteria and verification commands.

In bounded autonomous mode, Codex may implement and verify only inside the approved scope. It must stop and ask before production impact, scope expansion, credential use, CI/CD enablement, commit/push if not explicitly allowed, or merge to `main`.

Read the full policy in `docs/codex/autonomy-modes.md`.



## Milestone planning rules

Codex must not treat `NON_AUTONOMOUS` planning as a request to design the whole project in full detail.

Planning boundary:

```text
Whole project = high-level roadmap only.
Current milestone = detailed technical implementation plan.
Implementation = only after the current milestone plan is accepted.
```

In the first `NON_AUTONOMOUS` response for a milestone, Codex must provide:

- repo map;
- confirmed facts, assumptions and blockers;
- high-level roadmap for M0-M6;
- detailed technical plan for the current milestone only;
- allowed files/paths;
- forbidden actions;
- acceptance criteria;
- verification commands;
- stop-and-ask triggers;
- request for user approval.

Codex must not produce or execute a detailed implementation plan for future milestones unless the user explicitly asks for it.
After the current milestone plan is accepted, Codex may switch to `BOUNDED_AUTONOMOUS` only within that approved milestone scope.

Full policy: `docs/codex/milestone-planning-policy.md`.

## Handoff and verification rules

- Keep `active-run.md` short and current.
- Put history into `session-log.md`.
- Put verification commands/results into `verification-memory.md`.
- Put durable decisions into `decisions-log.md`.
- If verification cannot run, document the concrete blocker.
- If a test/check fails, fix it in the same task unless it is a true external blocker.

## Multi-agent commit rules

- Planner does not change code.
- Builder may change files inside scope but does not commit/push.
- Prod Safety Agent reviews any production-impacting behavior.
- QA Reviewer independently reviews the diff and gates.
- Orchestrator performs final verification, commit and push.
- Orchestrator does not merge to main without explicit user approval.

## First milestone rule

The first milestone must be ProdSafety + Git/Handoff/Verification governance foundation.

Do not add real game-session tests until the following exist:

- ProdGuard;
- SyntheticUserGuard;
- ResourceBudget;
- KillSwitch;
- CleanupVerifier;
- artifact collection;
- log sanitization;
- synthetic user allowlist;
- explicit `PROD_CONDITIONAL` run flag.
