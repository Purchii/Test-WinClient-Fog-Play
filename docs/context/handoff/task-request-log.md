# Task request log

Authoritative task execution history lives in:

- `docs/context/governance/session-log.md`
- `docs/context/engineering/verification-memory.md`
- `docs/context/handoff/active-run.md`

New task requests must preserve context, objective, thread lifecycle, scope, forbidden actions, production classification, acceptance criteria, verification commands and stop conditions.

Thread lifecycle requirements must keep the separate Codex thread rule explicit and state that previous task threads become inactive/history-only after handoff, completion or takeover while remaining preserved for history.

Thread title requirements must keep Codex thread titles aligned with git task branch names, including the `codex/` prefix unless the user explicitly requests another branch name.

BOUNDED_AUTONOMOUS continuation requests must state that the continuation thread may begin with source-of-truth discovery, select one safe bounded follow-up task, and complete that selected task in the same thread.

BOUNDED_AUTONOMOUS continuation requests must preserve the full condition: after the selected task in the current continuation thread is verified, committed/pushed/integrated as allowed, and the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, the current task thread creates the next separate Codex continuation thread via `create_thread` and hands off the next discovery cycle instead of stopping after the first completed task.

Stop conditions must include no safe bounded task, expired autonomous window, production/scope/credential/runtime blocker, unavailable multi-agent tooling, user pause/stop, and `create_thread` plus worktree fallback failure.
