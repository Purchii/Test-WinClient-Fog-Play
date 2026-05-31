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
- ...
```
