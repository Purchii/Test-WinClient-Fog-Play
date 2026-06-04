# Codex workflow

1. Confirm this is the correct Codex thread for the current independent task.
2. For a new independent task or milestone, use `create_thread` first.
3. Name the Codex thread after the git task branch, including the `codex/` prefix unless the user explicitly requests another branch name.
4. Treat a bounded autonomous continuation thread as the correct place for source-of-truth discovery, Planner selection of one safe bounded follow-up task, and Builder/QA completion of that selected task; selection alone does not require another thread.
5. Treat extended autonomous time, push permission and merge permission as execution permissions only; they do not waive thread-per-task.
6. If the new thread is unusable, invisible or unmanageable, record it as inactive/orphan and retry `create_thread` once.
7. Use a Codex worktree after the second normal `create_thread` failure, or earlier when the follow-on task benefits from isolated branch/workspace state.
8. Hand off before implementation if this is the previous task thread.
9. After a new task thread is created, treat the previous task thread as inactive/history-only after handoff.
10. Preserve the previous task thread for history: do not delete it, and do not archive it automatically unless the user explicitly asks.
11. Read source-of-truth docs.
12. Declare autonomy mode.
13. Check git status.
14. Create/propose task branch.
15. Produce repo map and plan.
16. Wait for approval if in NON_AUTONOMOUS discovery mode.
17. Confirm production classification.
18. Implement only allowed scope.
19. Run verification.
20. Update verification-memory/session-log/active-run.
21. In `BOUNDED_AUTONOMOUS`, after the selected task in the current continuation thread is verified, committed/pushed/integrated as allowed, and the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, create the next separate Codex continuation thread via `create_thread` and hand off the next discovery cycle instead of stopping after the first completed task.
22. Stop autonomous continuation instead of creating a follow-up task only when no safe bounded task is available, the autonomous time window expired, a production/scope/credential/runtime blocker appears, multi-agent tooling is unavailable, the user pauses or stops work, or `create_thread` plus worktree fallback fails.
23. Final report including autonomy mode, continuation handoff status and stop-and-ask triggers.
24. Do not merge main without explicit approval.

If implementation for a new independent task continues in the previous task thread, mark `PROCESS_ERROR_THREAD_REUSE`, update context docs, and stop task implementation until a correct task thread exists.


## Communication

All user-facing reports must be in Russian by default. Use `docs/codex/communication-policy.md`. Provide concise reasoning summaries, not private chain-of-thought.

## Milestone planning workflow

For each new milestone:

1. Start a separate Codex thread with `create_thread`.
2. A continuation thread may perform discovery, select one bounded follow-up gate, hardening item, feature slice or backlog item, and complete that selected task in the same thread.
3. Do not treat extended autonomous time as approval to run multiple independent milestones in the same thread.
4. If the thread is unusable, invisible or unmanageable, record it as inactive/orphan and retry `create_thread` once.
5. Use a Codex worktree after the second normal `create_thread` failure, or when the milestone follows from prior work and needs isolated branch/workspace state.
6. After the new milestone thread is created, keep the previous milestone thread inactive/history-only, preserved, not deleted and not archived automatically unless the user explicitly asks.
7. Start in `NON_AUTONOMOUS` mode.
8. Re-read source-of-truth docs and current diff.
9. Produce high-level roadmap for the whole project.
10. Produce detailed technical plan only for the current milestone.
11. Wait for user approval.
12. After approval, continue in `BOUNDED_AUTONOMOUS` mode inside the accepted scope.
13. Update `active-run.md`, `session-log.md`, `verification-memory.md`, and `implementation-status.md`.

Do not execute detailed future-milestone work without a separate planning step.
