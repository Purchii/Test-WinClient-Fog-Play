# Task request log

Authoritative task execution history lives in:

- `docs/context/governance/session-log.md`
- `docs/context/engineering/verification-memory.md`
- `docs/context/handoff/active-run.md`

New task requests must preserve context, objective, thread lifecycle, scope, forbidden actions, production classification, acceptance criteria, verification commands and stop conditions.

Thread lifecycle requirements must keep the separate Codex thread rule explicit and state that previous task threads become inactive/history-only after handoff, completion or takeover while remaining preserved for history.
