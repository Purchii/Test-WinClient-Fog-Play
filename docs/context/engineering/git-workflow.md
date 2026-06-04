# Git workflow

## Rules

- `main` is protected trunk.
- Do not work directly on `main` for backlog tasks.
- Every bounded goal uses a dedicated task branch.
- Every new independent autonomous task or milestone uses a separate Codex thread.
- Name the Codex thread after the git task branch, including the `codex/` prefix unless the user explicitly requests another branch name.
- Extended autonomous time, push permission or merge permission does not waive thread-per-task.
- A bounded autonomous continuation thread may start with source-of-truth discovery, select one follow-up gate, hardening item, feature slice or backlog item, and complete that selected task in the same thread.
- Use `create_thread` first for new independent tasks.
- If normal thread creation is unusable, mark it inactive/orphan, retry `create_thread` once, then use Codex worktree fallback after the second failure.
- Use Codex worktrees earlier when follow-on tasks need isolated branch/workspace state.
- In `BOUNDED_AUTONOMOUS`, after the selected task in the current continuation thread is verified, committed/pushed/integrated, if the active autonomous window remains open with no blocker, no user stop and no exhausted safe task queue, create the next separate Codex continuation thread via `create_thread` and hand off the next discovery cycle instead of stopping after the first completed task.
- Stop autonomous continuation instead of creating a follow-up task only when no safe bounded task is available, the autonomous time window expired, a production/scope/credential/runtime blocker appears, multi-agent tooling is unavailable, the user pauses or stops work, or `create_thread` plus worktree fallback fails.
- After a new task thread is created, the previous task thread becomes inactive/history-only after handoff.
- The previous task thread is preserved for history: it must not be deleted and is not archived automatically unless the user explicitly asks.
- If a new independent task continues in the previous task thread, mark `PROCESS_ERROR_THREAD_REUSE` before doing more implementation.
- Branch must be atomic but useful: one rollback-sized backlog slice.
- Work with remote Git by default when it does not reduce quality or safety.
- Fetch/pull before starting a task branch.
- Push verified task branches when allowed by explicit user instruction or accepted project policy.
- Do not let remote workflow replace local verification.
- Do not mix unrelated changes.
- Do not force-push to main.
- Do not merge to main without explicit user approval.
- Commit/push task branch only when the prompt or accepted project policy allows it.
- Merge to main always requires NON_AUTONOMOUS explicit user approval.

## Start task

```powershell
git status --short
git checkout main
git pull --ff-only
git checkout -b codex/<task-name>
```

## Finish task

```powershell
git status --short
git diff --check
# run relevant project gates
```

Then update:

- `docs/context/engineering/verification-memory.md`
- `docs/context/governance/session-log.md`
- `docs/context/handoff/active-run.md`
- `docs/context/engineering/implementation-status.md`

In `BOUNDED_AUTONOMOUS`, if the active autonomous window remains open and no stop condition applies after the selected task is verified, committed/pushed/integrated, create the next separate Codex continuation thread via `create_thread` and hand off the next discovery cycle before final stop.

## Commit rules

- Planner does not write code.
- Builder does not commit/push.
- QA Reviewer does not commit/push.
- Orchestrator commits after verification only when explicit user approval or an accepted project policy allows it.
- Orchestrator pushes verified task branches to remote only when allowed.
- Merge to main requires explicit user approval.
