# Codex workflow

1. Confirm this is the correct Codex thread for the current independent task.
2. For a new independent task or milestone, use `create_thread` first.
3. Use a Codex worktree when the follow-on task benefits from isolated branch/workspace state.
4. Hand off before implementation if this is the previous task thread.
5. Leave the previous task thread unarchived, but inactive after handoff.
6. Read source-of-truth docs.
7. Declare autonomy mode.
8. Check git status.
9. Create/propose task branch.
10. Produce repo map and plan.
11. Wait for approval if in NON_AUTONOMOUS discovery mode.
12. Confirm production classification.
13. Implement only allowed scope.
14. Run verification.
15. Update verification-memory/session-log/active-run.
16. Final report including autonomy mode and stop-and-ask triggers.
17. Do not merge main without explicit approval.

If implementation for a new independent task continues in the previous task thread, mark `PROCESS_ERROR_THREAD_REUSE`, update context docs, and stop task implementation until a correct task thread exists.


## Communication

All user-facing reports must be in Russian by default. Use `docs/codex/communication-policy.md`. Provide concise reasoning summaries, not private chain-of-thought.

## Milestone planning workflow

For each new milestone:

1. Start a separate Codex thread with `create_thread`.
2. Use a Codex worktree when the milestone follows from prior work and needs isolated branch/workspace state.
3. Keep the previous milestone thread unarchived but inactive.
4. Start in `NON_AUTONOMOUS` mode.
5. Re-read source-of-truth docs and current diff.
6. Produce high-level roadmap for the whole project.
7. Produce detailed technical plan only for the current milestone.
8. Wait for user approval.
9. After approval, continue in `BOUNDED_AUTONOMOUS` mode inside the accepted scope.
10. Update `active-run.md`, `session-log.md`, `verification-memory.md`, and `implementation-status.md`.

Do not execute detailed future-milestone work without a separate planning step.
