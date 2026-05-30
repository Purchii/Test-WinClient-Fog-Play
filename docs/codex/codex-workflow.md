# Codex workflow

1. Read source-of-truth docs.
2. Declare autonomy mode.
3. Check git status.
4. Create/propose task branch.
5. Produce repo map and plan.
6. Wait for approval if in NON_AUTONOMOUS discovery mode.
7. Confirm production classification.
8. Implement only allowed scope.
9. Run verification.
10. Update verification-memory/session-log/active-run.
11. Final report including autonomy mode and stop-and-ask triggers.
12. Do not merge main without explicit approval.


## Communication

All user-facing reports must be in Russian by default. Use `docs/codex/communication-policy.md`. Provide concise reasoning summaries, not private chain-of-thought.

## Milestone planning workflow

For each new milestone:

1. Start in `NON_AUTONOMOUS` mode.
2. Re-read source-of-truth docs and current diff.
3. Produce high-level roadmap for the whole project.
4. Produce detailed technical plan only for the current milestone.
5. Wait for user approval.
6. After approval, continue in `BOUNDED_AUTONOMOUS` mode inside the accepted scope.
7. Update `active-run.md`, `session-log.md`, `verification-memory.md`, and `implementation-status.md`.

Do not execute detailed future-milestone work without a separate planning step.
