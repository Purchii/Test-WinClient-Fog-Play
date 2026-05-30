# Codex workflow

1. Confirm this is the correct Codex thread for the current independent task.
2. For a new independent task or milestone, create or hand off to a separate Codex thread before implementation.
3. Leave the previous task thread unarchived, but inactive after handoff.
4. Read source-of-truth docs.
5. Declare autonomy mode.
6. Check git status.
7. Create/propose task branch.
8. Produce repo map and plan.
9. Wait for approval if in NON_AUTONOMOUS discovery mode.
10. Confirm production classification.
11. Implement only allowed scope.
12. Run verification.
13. Update verification-memory/session-log/active-run.
14. Final report including autonomy mode and stop-and-ask triggers.
15. Do not merge main without explicit approval.

If implementation for a new independent task continues in the previous task thread, mark `PROCESS_ERROR_THREAD_REUSE`, update context docs, and stop task implementation until a correct task thread exists.


## Communication

All user-facing reports must be in Russian by default. Use `docs/codex/communication-policy.md`. Provide concise reasoning summaries, not private chain-of-thought.

## Milestone planning workflow

For each new milestone:

1. Start a separate Codex thread for the milestone.
2. Keep the previous milestone thread unarchived but inactive.
3. Start in `NON_AUTONOMOUS` mode.
4. Re-read source-of-truth docs and current diff.
5. Produce high-level roadmap for the whole project.
6. Produce detailed technical plan only for the current milestone.
7. Wait for user approval.
8. After approval, continue in `BOUNDED_AUTONOMOUS` mode inside the accepted scope.
9. Update `active-run.md`, `session-log.md`, `verification-memory.md`, and `implementation-status.md`.

Do not execute detailed future-milestone work without a separate planning step.
