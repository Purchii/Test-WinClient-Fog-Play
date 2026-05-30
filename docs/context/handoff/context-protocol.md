# Context protocol

For every new Codex task, read in this order:

1. `AGENTS.md`
2. `docs/context/handoff/active-run.md`
3. `docs/context/current-state.md`
4. `docs/context/handoff/context-protocol.md`
5. `docs/context/handoff/executor-policy.md`
6. `docs/context/handoff/executor-checklist.md`
7. `docs/context/engineering/git-workflow.md`
8. `docs/context/engineering/implementation-status.md`
9. `docs/context/engineering/verification-memory.md`
10. `docs/context/governance/decisions-log.md`
11. `docs/context/governance/session-log.md`
12. `docs/codex/autonomy-modes.md`
13. `docs/codex/milestone-planning-policy.md`
14. `docs/codex/communication-policy.md`
15. `docs/qa/prod-testing-policy.md`
16. `docs/qa/prod-safe-test-matrix.md`
17. task-specific docs/code.

Old chat context is advisory only.
Repository docs and code are source of truth.

Thread lifecycle:

- A new independent task or milestone in autonomous work requires a separate Codex thread.
- The previous task thread is not archived automatically. It remains available as history, but is inactive after handoff.
- If a new task is continued in the previous thread, treat it as `PROCESS_ERROR_THREAD_REUSE`: record the error, do not implement further task changes, and create or hand off to the correct task thread.
- A current thread may make a narrowly scoped governance correction documenting this error before handoff.

If execution mode is not declared, use `NON_AUTONOMOUS` until the user approves a bounded milestone plan.

For milestone planning:

```text
Whole project = high-level roadmap.
Current milestone = detailed technical implementation plan.
Future milestones = high-level until their own planning step.
```

If the current milestone plan is not recorded or not accepted, Codex must stop and ask before changing files.
