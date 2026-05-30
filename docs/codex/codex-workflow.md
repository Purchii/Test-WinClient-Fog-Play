# Codex workflow

1. Confirm this is the correct Codex thread for the current independent task.
2. For a new independent task or milestone, use `create_thread` first.
3. Treat a newly selected follow-up gate, hardening item, feature slice or backlog item as a new independent task unless it only repairs verification for the current task.
4. Treat extended autonomous time, push permission and merge permission as execution permissions only; they do not waive thread-per-task.
5. If the new thread is unusable, invisible or unmanageable, record it as inactive/orphan and retry `create_thread` once.
6. Use a Codex worktree after the second normal `create_thread` failure, or earlier when the follow-on task benefits from isolated branch/workspace state.
7. Hand off before implementation if this is the previous task thread.
8. Leave the previous task thread unarchived, but inactive after handoff.
9. Read source-of-truth docs.
10. Declare autonomy mode.
11. Check git status.
12. Create/propose task branch.
13. Produce repo map and plan.
14. Wait for approval if in NON_AUTONOMOUS discovery mode.
15. Confirm production classification.
16. Implement only allowed scope.
17. Run verification.
18. Update verification-memory/session-log/active-run.
19. Final report including autonomy mode and stop-and-ask triggers.
20. Do not merge main without explicit approval.

If implementation for a new independent task continues in the previous task thread, mark `PROCESS_ERROR_THREAD_REUSE`, update context docs, and stop task implementation until a correct task thread exists.


## Communication

All user-facing reports must be in Russian by default. Use `docs/codex/communication-policy.md`. Provide concise reasoning summaries, not private chain-of-thought.

## Milestone planning workflow

For each new milestone:

1. Start a separate Codex thread with `create_thread`.
2. Start a separate Codex thread for each newly selected follow-up gate, hardening item, feature slice or backlog item.
3. Do not treat extended autonomous time as approval to run multiple independent milestones in the same thread.
4. If the thread is unusable, invisible or unmanageable, record it as inactive/orphan and retry `create_thread` once.
5. Use a Codex worktree after the second normal `create_thread` failure, or when the milestone follows from prior work and needs isolated branch/workspace state.
6. Keep the previous milestone thread unarchived but inactive.
7. Start in `NON_AUTONOMOUS` mode.
8. Re-read source-of-truth docs and current diff.
9. Produce high-level roadmap for the whole project.
10. Produce detailed technical plan only for the current milestone.
11. Wait for user approval.
12. After approval, continue in `BOUNDED_AUTONOMOUS` mode inside the accepted scope.
13. Update `active-run.md`, `session-log.md`, `verification-memory.md`, and `implementation-status.md`.

Do not execute detailed future-milestone work without a separate planning step.
