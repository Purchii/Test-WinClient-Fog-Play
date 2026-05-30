# Goal mode rules

Use goal mode only for bounded milestones with:

- context;
- objective;
- execution mode;
- allowed scope;
- forbidden actions;
- acceptance criteria;
- verification commands;
- stop condition.

Do not use open-ended goals like “automate the app”.

---

## Planning rule

Every new milestone starts with a `NON_AUTONOMOUS` discovery/planning step.

Codex must produce:

```text
repo map;
confirmed facts;
assumptions/blockers;
high-level roadmap for the whole project;
detailed technical plan only for the current milestone;
allowed scope;
forbidden actions;
acceptance criteria;
verification commands;
stop-and-ask triggers.
```

Then Codex must wait for user approval.

---

## Roadmap vs detailed plan

For the whole project, Codex should provide only a high-level roadmap, for example:

```text
M0. ProdSafety + Git/Handoff/Verification + Autonomy Modes foundation.
M1. Release artifact + privacy gates.
M2. App launch + WebView smoke.
M3. WebView/native bridge contract + fake native host.
M4. Safe backend smoke.
M5. Minimal PROD_CONDITIONAL game-session canary.
M6. Future non-prod/fake/replay/network/hardware foundation.
```

For the current milestone, Codex must provide a detailed engineering plan.

Codex must not create or execute a detailed implementation plan for all future milestones unless the user explicitly requests it.

---

## Autonomy after approval

Every goal must declare one execution mode:

```text
NON_AUTONOMOUS / supervised mode
BOUNDED_AUTONOMOUS mode
```

Default is `NON_AUTONOMOUS` until the user accepts the current milestone plan.

After acceptance, Codex may continue in `BOUNDED_AUTONOMOUS` mode only inside the approved milestone scope.

Codex must stop and ask before production impact, scope expansion, game sessions, credential/secret use, CI/CD enablement, dependency upgrade, guard weakening, commit/push if not explicitly allowed, or merge to `main`.
