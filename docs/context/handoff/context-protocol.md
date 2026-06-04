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
`docs/_incoming_reference/` is historical/reference-only input and is not active scope unless restated in repository docs, scripts or code.
Use `git log --oneline --decorate -1` as the authoritative latest commit source. Do not record a literal latest pushed commit in `active-run.md`; context-sync commits would immediately make that line stale.
Use `git status --short --branch` as the authoritative current branch/worktree source. Do not record a live literal current branch in `active-run.md`; task branch history belongs in verification-memory and session-log entries.

Thread lifecycle:

- A new independent task or milestone in autonomous work requires a separate Codex thread.
- The Codex thread title should match the git task branch name, including the `codex/` prefix unless the user explicitly requests another branch name.
- Long-running autonomous permission extends time, not task/thread scope.
- Push or merge permission does not waive the separate-thread requirement.
- A bounded autonomous continuation thread may start with source-of-truth discovery. Planner may select one safe, bounded follow-up gate, hardening item or backlog item and Builder/QA may implement and verify that selected task in the same thread; selecting that task does not require creating another thread.
- `create_thread` is the priority mechanism for starting a new independent task.
- If `create_thread` creates an unusable, invisible or unmanageable thread, record that attempt as inactive/orphan and retry `create_thread` once.
- After the second normal `create_thread` failure, create the task thread with a Codex worktree.
- Use a Codex worktree earlier when the new task flows from a previous task and needs isolated branch/workspace state.
- In `BOUNDED_AUTONOMOUS` mode, after the selected task in the current continuation thread is verified, committed/pushed/integrated as allowed, and the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, the current task thread must create the next separate Codex continuation thread via `create_thread` and hand off the next discovery cycle instead of stopping after the first completed task.
- Autonomous continuation stops instead of creating a follow-up task only when no safe bounded task is available, the autonomous time window expired, a production/scope/credential/runtime blocker appears, multi-agent tooling is unavailable, the user pauses or stops work, or `create_thread` plus worktree fallback fails.
- After a new task thread is created, the previous task thread becomes inactive/history-only after handoff.
- The previous task thread is preserved for history: it must not be deleted and is not archived automatically unless the user explicitly asks.
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
