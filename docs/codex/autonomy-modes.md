# Codex autonomy modes

This project supports two execution modes for Codex work: **non-autonomous / supervised mode** and **bounded autonomous mode**.

Because this repository is production-sensitive, autonomy is never implicit. Every goal must declare the intended mode in the prompt and in `docs/context/handoff/active-run.md`.

If the mode is not declared, use **non-autonomous / supervised mode**.

---

## 1. Non-autonomous / supervised mode

Use this mode when Codex must stop at decision checkpoints and wait for user approval before continuing.

This is the default mode for:

- first discovery in a new project or repository;
- unclear scope;
- production-impacting tasks;
- `PROD_CONDITIONAL` tests;
- any change that can start a cloud-gaming session;
- update/rollback logic;
- CI/CD changes that can run tests automatically;
- dependency upgrades;
- WebView debug-port/test-mode changes;
- credentials, secrets, auth, synthetic-user configuration;
- changes to `ProdGuard`, `KillSwitch`, `ResourceBudget`, `CleanupVerifier`, or production runner behavior;
- merge to `main`;
- any case where safety cannot be proven from repository docs and code.

### Required supervised checkpoints

Codex must pause and ask for approval before:

1. changing code after initial repository discovery;
2. widening scope;
3. adding or enabling a production test;
4. adding a `PROD_CONDITIONAL` scenario;
5. changing CI/CD or scheduled runs;
6. changing kill switches, guards, resource budgets, cleanup rules, or classification logic;
7. committing or pushing if the prompt did not explicitly allow it;
8. merging to `main`;
9. using credentials or production secrets;
10. running anything that can affect production state.

---

## 2. Bounded autonomous mode

Bounded autonomous mode allows Codex to execute implementation steps without asking after every small change, but only inside a pre-approved goal.

Bounded autonomous mode is allowed only when all conditions are true:

- the user accepted the plan or explicitly requested autonomous execution;
- the goal has clear acceptance criteria;
- allowed files/paths are specified or can be safely inferred from the accepted plan;
- forbidden actions are specified;
- verification commands are specified or can be safely discovered;
- a dedicated task branch is used;
- a separate Codex thread is used for the current independent task or milestone;
- the previous task thread is left unarchived but inactive after handoff;
- the task is not changing production behavior directly;
- no real credentials, tokens, or personal data are needed;
- no production game session is started;
- no destructive, load, stress, chaos, or update rollback test is added;
- no merge to `main` happens without explicit approval.

### Allowed in bounded autonomous mode

Codex may:

- inspect repository files;
- update docs inside the accepted scope;
- implement local framework skeletons;
- implement dry-run or unit tests for guards;
- run local verification commands;
- fix verification failures inside the accepted scope;
- update `active-run.md`, `verification-memory.md`, `session-log.md`, and `implementation-status.md`;
- prepare a commit message;
- commit/push the task branch only if the prompt or project policy explicitly allows it.

### Not allowed in bounded autonomous mode

Codex must not:

- merge to `main`;
- force-push;
- continue implementation for a new independent task in the previous task thread;
- start production game sessions;
- run `PROD_CONDITIONAL` tests without explicit flag and user approval;
- bypass or weaken ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier;
- introduce real credentials;
- expand scope into unrelated features;
- silently quarantine or skip failing checks without documenting the reason.

---

## 3. Recommended default for this project

For MTC Fog Play QA Automation, use this default:

```text
New independent task or milestone: separate Codex thread.
Initial discovery and plan: NON_AUTONOMOUS.
After user accepts the plan: BOUNDED_AUTONOMOUS only for the approved milestone.
Production-impacting actions: NON_AUTONOMOUS.
Merge to main: NON_AUTONOMOUS and requires explicit user approval.
```

The previous thread remains unarchived as historical context, but becomes inactive after handoff. If a new independent task continues in the previous thread, record `PROCESS_ERROR_THREAD_REUSE` and stop implementation until the task is moved to a correct thread.

For the first milestone, the recommended mode is:

```text
M0 discovery: NON_AUTONOMOUS.
M0 implementation after accepted plan: BOUNDED_AUTONOMOUS.
Game-session canary: NON_AUTONOMOUS until explicitly approved.
```



---

## 3.5. Milestone planning boundary

`NON_AUTONOMOUS` planning does not mean Codex should create a complete detailed plan for the entire project.

Required boundary:

```text
Whole project = high-level roadmap.
Current milestone = detailed technical implementation plan.
Future milestones = high-level until their own NON_AUTONOMOUS planning step.
```

For the first project run, Codex should produce:

- repository map;
- confirmed facts and blockers;
- high-level roadmap `M0-M6`;
- detailed technical plan for `M0` only;
- allowed scope for `M0`;
- forbidden actions for `M0`;
- acceptance criteria for `M0`;
- verification commands for `M0`;
- request for user approval.

After the user accepts the current milestone plan, Codex may work in `BOUNDED_AUTONOMOUS` mode only inside that accepted scope.

Codex must not generate or execute detailed plans for future milestones unless explicitly requested by the user.
See also: `docs/codex/milestone-planning-policy.md`.

---

## 4. Required mode declaration

Every goal prompt should include:

```md
Thread:
- New independent task/milestone uses a separate Codex thread.
- Previous task thread remains unarchived but inactive after handoff.

Execution mode:
- Discovery and plan: NON_AUTONOMOUS.
- Implementation after accepted plan: BOUNDED_AUTONOMOUS within the approved scope.
- Stop and ask before any production-impacting action, scope expansion, credential use, CI/CD enablement, commit/push if not explicitly allowed, or merge to main.
```

`active-run.md` must also include:

```text
Execution mode: NON_AUTONOMOUS / BOUNDED_AUTONOMOUS
Autonomy boundary: [what Codex may do without asking]
Stop-and-ask triggers: [specific triggers]
```

---

## 5. Final report requirements

The final report must state:

- which autonomy mode was used;
- whether the correct task thread was used;
- whether any `PROCESS_ERROR_THREAD_REUSE` occurred;
- whether the scope stayed inside the accepted boundary;
- whether any stop-and-ask trigger occurred;
- whether any production-impacting command was avoided;
- whether a task branch was used;
- whether anything was committed/pushed;
- whether merge to `main` was avoided unless explicitly approved.
