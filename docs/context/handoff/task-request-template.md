# Task request template

```md
/goal [bounded goal]

Context:
[project context]

Objective:
[what to implement]

Thread lifecycle:
- Every new independent task or milestone must use a separate Codex thread.
- The Codex thread title should match the git task branch name, including the `codex/` prefix unless the user explicitly requests another branch name.
- After handoff, completion or takeover, the previous task thread becomes inactive/history-only, is preserved for history, is not deleted, and is not archived automatically unless explicitly requested.
- In BOUNDED_AUTONOMOUS continuation, the task thread may begin with source-of-truth discovery; Planner may select one safe bounded follow-up task and Builder/QA may complete that selected task in the same thread.
- In BOUNDED_AUTONOMOUS mode, after the selected task in the current continuation thread is verified, committed/pushed/integrated as allowed, and the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, the current task thread must create the next separate Codex continuation thread via `create_thread` and hand off the next discovery cycle instead of stopping after the first completed task.

Scope:
Allowed paths:
- ...

Forbidden:
- ...

Production classification:
- PROD_SAFE / PROD_CONDITIONAL / PROD_FORBIDDEN / NON_PROD_ONLY

Acceptance criteria:
- ...

Verification:
- ...

Stop when:
- No safe bounded task is available; the autonomous time window expired; a production, scope, credential or runtime blocker appears; multi-agent tooling is unavailable; the user pauses or stops work; or `create_thread` plus worktree fallback fails.
```
