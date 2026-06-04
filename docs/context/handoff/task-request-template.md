# Task request template

```md
/goal [bounded goal]

Context:
[project context]

Objective:
[what to implement]

Thread lifecycle:
- Every new independent task or milestone must use a separate Codex thread.
- After handoff, completion or takeover, the previous task thread becomes inactive/history-only, is preserved for history, is not deleted, and is not archived automatically unless explicitly requested.
- In BOUNDED_AUTONOMOUS continuation, a verified and integrated task must create the next separate Codex task thread via `create_thread` and hand off instead of stopping when the autonomous window remains open and no stop condition applies.
- In BOUNDED_AUTONOMOUS mode, after the current task is verified, committed/pushed/integrated as allowed, and the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, the current task thread must create the next separate Codex task thread via `create_thread` and hand off continuation instead of stopping after the first task.

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
