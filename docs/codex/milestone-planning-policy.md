# Milestone planning policy for Codex

This project uses bounded goal-mode. Codex must not create or execute an open-ended project-wide implementation plan.

The planning boundary is:

```text
Whole project = high-level roadmap.
Current milestone = detailed technical implementation plan.
Implementation = only after the current milestone plan is accepted.
```

---

## 1. NON_AUTONOMOUS planning step

For every new milestone, Codex starts in `NON_AUTONOMOUS / supervised mode`.

In this mode Codex must:

1. re-read source-of-truth repository files;
2. inspect repository structure and current diff;
3. produce a repository map;
4. list confirmed facts, assumptions and blockers;
5. produce a high-level roadmap for the whole project;
6. produce a detailed technical plan only for the current milestone;
7. specify allowed files/paths for the current milestone;
8. specify forbidden actions;
9. define acceptance criteria;
10. define verification commands;
11. list stop-and-ask triggers;
12. wait for user approval before changing files.

---

## 2. What “project plan” means

Codex may produce this kind of whole-project plan:

```text
M0. ProdSafety + Git/Handoff/Verification + Autonomy Modes foundation.
M1. Release artifact + privacy gates.
M2. App launch + WebView smoke.
M3. WebView/native bridge contract + fake native host.
M4. Safe backend smoke.
M5. Minimal PROD_CONDITIONAL game-session canary.
M6. Future non-prod/fake/replay/network/hardware foundation.
```

This is a roadmap, not a detailed implementation plan.

Codex must not produce a detailed implementation plan for all future milestones unless the user explicitly asks for it.
Future milestones remain high-level until their own `NON_AUTONOMOUS` planning step.

---

## 3. What “current milestone detailed plan” means

For the current milestone only, Codex must produce a real engineering plan.

For example, for `M0`, the plan should include:

- files to create;
- files to modify;
- framework structure;
- classes/enums/configs/scripts to add;
- docs to update;
- dry-run or unit checks;
- acceptance criteria;
- verification commands;
- risks and blockers;
- explicit forbidden actions.

After the user accepts this plan, Codex may continue in `BOUNDED_AUTONOMOUS` mode inside that exact scope.

---

## 4. BOUNDED_AUTONOMOUS execution after plan approval

After the current milestone plan is accepted, Codex may:

- implement within the accepted scope;
- run local/dry-run verification;
- fix issues inside the accepted scope;
- update handoff/context/verification docs;
- prepare a final report.

Codex must stop and ask before:

- expanding scope;
- changing future milestones in detail;
- running production-impacting actions;
- starting a game session;
- using credentials/secrets;
- enabling CI/CD automation;
- weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier;
- committing/pushing if not explicitly allowed;
- merging to `main`.

---

## 5. Required first response format

In the first `NON_AUTONOMOUS` response for a milestone, Codex should answer in Russian and include:

```text
1. Режим работы: NON_AUTONOMOUS discovery/planning.
2. Что прочитал.
3. Repo map.
4. Подтверждённые факты.
5. Допущения и blockers.
6. High-level roadmap M0-M6.
7. Детальный технический план текущего milestone.
8. Allowed scope.
9. Forbidden actions.
10. Acceptance criteria.
11. Verification commands.
12. Stop-and-ask triggers.
13. Запрос на подтверждение плана.
```

---

## 6. Required active-run fields

`docs/context/handoff/active-run.md` must record:

```text
Current milestone: [M0/M1/...]
Execution mode: NON_AUTONOMOUS / BOUNDED_AUTONOMOUS
Planning boundary: roadmap for all milestones, detailed plan only for current milestone
Accepted plan status: not accepted / accepted / blocked
Autonomy boundary: what Codex may do without asking
Stop-and-ask triggers: concrete triggers
```
