# Executor checklist

Before implementation:

- [ ] `git status --short` checked.
- [ ] Correct task thread confirmed.
- [ ] New independent task/milestone has its own Codex thread.
- [ ] `create_thread` used or attempted first for a new independent task.
- [ ] Unusable/invisible/unmanageable `create_thread` attempts are recorded inactive/orphan.
- [ ] A second normal `create_thread` attempt was made before worktree fallback, unless worktree isolation was needed immediately.
- [ ] Worktree used only after retry failure or when isolated branch/workspace state is useful for a follow-on task.
- [ ] Previous task thread is left unarchived but inactive.
- [ ] No `PROCESS_ERROR_THREAD_REUSE` remains unresolved.
- [ ] Not working directly on main, unless explicitly allowed.
- [ ] Task branch created/proposed.
- [ ] AGENTS.md read.
- [ ] active-run.md read.
- [ ] Execution mode declared.
- [ ] Autonomy boundary and stop-and-ask triggers understood.
- [ ] Production impact classified.
- [ ] Scope and forbidden actions understood.
- [ ] Verification commands identified.

Before final report:

- [ ] Verification run or blocker documented.
- [ ] verification-memory.md updated.
- [ ] session-log.md updated.
- [ ] active-run.md updated.
- [ ] git status shown.
- [ ] Changed files listed.
- [ ] Risks/blockers listed.
- [ ] No secrets committed.
- [ ] Autonomy mode stated in final report.
- [ ] No stop-and-ask trigger bypassed.
- [ ] No unapproved production-impacting tests added.
