# Executor policy

- One run = one bounded goal.
- Every run must declare autonomy mode: NON_AUTONOMOUS or BOUNDED_AUTONOMOUS.
- Default to NON_AUTONOMOUS until the user accepts the plan.
- Do not expand scope without user approval.
- Do not work directly on main.
- Do not merge to main without explicit user approval.
- Keep docs synchronized with implementation.
- If verification fails, repair within the same task unless external blocker.
- If verification cannot run, document blocker.
- Do not commit secrets, logs, crash dumps or release binaries unless explicitly approved as fixtures.
- If a task may affect production, classify it before implementation.
- If safety cannot be proven, treat production run as forbidden.
- In BOUNDED_AUTONOMOUS mode, stop and ask before scope expansion, production impact, credential use, CI/CD enablement, commit/push if not explicitly allowed, or merge to main.
