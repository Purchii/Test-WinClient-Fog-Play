# Git workflow

## Rules

- `main` is protected trunk.
- Do not work directly on `main` for backlog tasks.
- Every bounded goal uses a dedicated task branch.
- Every new independent autonomous task or milestone uses a separate Codex thread.
- The previous task thread remains unarchived but inactive after handoff.
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

## Commit rules

- Planner does not write code.
- Builder does not commit/push.
- QA Reviewer does not commit/push.
- Orchestrator commits after verification only when explicit user approval or an accepted project policy allows it.
- Orchestrator pushes verified task branches to remote only when allowed.
- Merge to main requires explicit user approval.
