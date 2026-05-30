# Git workflow

## Rules

- `main` is protected trunk.
- Do not work directly on `main` for backlog tasks.
- Every bounded goal uses a dedicated task branch.
- Branch must be atomic but useful: one rollback-sized backlog slice.
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
- Orchestrator commits after verification.
- Merge to main requires explicit user approval.
