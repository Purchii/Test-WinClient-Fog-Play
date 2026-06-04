# Task request log

Authoritative task execution history lives in:

- `docs/context/governance/session-log.md`
- `docs/context/engineering/verification-memory.md`
- `docs/context/handoff/active-run.md`

New task requests must preserve context, objective, thread lifecycle, scope, forbidden actions, production classification, acceptance criteria, verification commands and stop conditions.

Thread lifecycle requirements must keep the separate Codex thread rule explicit and state that previous task threads become inactive/history-only after handoff, completion or takeover while remaining preserved for history.

BOUNDED_AUTONOMOUS continuation requests must state that a verified and integrated task creates the next separate Codex task thread via `create_thread` and hands off instead of stopping when the autonomous window remains open and no stop condition applies.

BOUNDED_AUTONOMOUS continuation requests must preserve the full condition: after the current task is verified, committed/pushed/integrated as allowed, and the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, the current task thread creates the next separate Codex task thread via `create_thread` and hands off continuation instead of stopping after the first task.

Stop conditions must include no safe bounded task, expired autonomous window, production/scope/credential/runtime blocker, unavailable multi-agent tooling, user pause/stop, and `create_thread` plus worktree fallback failure.
