# Codex workflow

1. Confirm this is the correct Codex thread for the current independent task.
2. For a new independent task or milestone, use `create_thread` first.
3. If the new thread is unusable, invisible or unmanageable, record it as inactive/orphan and retry `create_thread` once.
4. Use a Codex worktree after the second normal `create_thread` failure, or earlier when the follow-on task benefits from isolated branch/workspace state.
5. Hand off before implementation if this is the previous task thread.
6. Leave the previous task thread unarchived, but inactive after handoff.
7. Read source-of-truth docs.
8. Declare autonomy mode.
9. Check git status.
10. Create/propose task branch.
11. Produce repo map and plan.
12. Wait for approval if in NON_AUTONOMOUS discovery mode.
13. Confirm production classification.
14. Implement only allowed scope.
15. Run verification.
16. Update verification-memory/session-log/active-run.
17. Final report including autonomy mode and stop-and-ask triggers.
18. Do not merge main without explicit approval.

If implementation for a new independent task continues in the previous task thread, mark `PROCESS_ERROR_THREAD_REUSE`, update context docs, and stop task implementation until a correct task thread exists.


## Communication

All user-facing reports must be in Russian by default. Use `docs/codex/communication-policy.md`. Provide concise reasoning summaries, not private chain-of-thought.

## Milestone planning workflow

For each new milestone:

1. Start a separate Codex thread with `create_thread`.
2. If the thread is unusable, invisible or unmanageable, record it as inactive/orphan and retry `create_thread` once.
3. Use a Codex worktree after the second normal `create_thread` failure, or when the milestone follows from prior work and needs isolated branch/workspace state.
4. Keep the previous milestone thread unarchived but inactive.
5. Start in `NON_AUTONOMOUS` mode.
6. Re-read source-of-truth docs and current diff.
7. Produce high-level roadmap for the whole project.
8. Produce detailed technical plan only for the current milestone.
9. Wait for user approval.
10. After approval, continue in `BOUNDED_AUTONOMOUS` mode inside the accepted scope.
11. Update `active-run.md`, `session-log.md`, `verification-memory.md`, and `implementation-status.md`.

Do not execute detailed future-milestone work without a separate planning step.
