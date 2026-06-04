# Codex Autonomous Workflow

This repository uses the following operating rules for Codex work.

## Active Autonomous Window

- Autonomous work is allowed from 2026-06-04 08:14:39 +03:00 until 2026-06-05 00:14:39 +03:00 Europe/Moscow.
- During this window, Codex may continue without additional approval when a task is safe, bounded, and verifiable.
- During this window, Codex may push verified work to `master` without asking for separate approval.

## Task Isolation

- Every new task must run in its own Codex thread.
- The thread name must match the task name.
- Creating a new task thread does not delete the previous thread; the previous thread simply becomes inactive.
- Every new task must use a separate git branch created from the current, up-to-date `master`.
- Use the `codex/` branch prefix unless the user explicitly requests another branch name.

## Multi-Agent Requirement

- After creating a new task thread, work must proceed in strict multi-agent mode.
- Use explicit role separation for each bounded task:
  - planner or explorer for scope and source-of-truth review;
  - worker or builder for implementation;
  - QA or reviewer for independent verification.
- If multi-agent tooling is unavailable or blocked, do not continue the task locally; record the blocker in the task handoff and wait until multi-agent work is possible.

## Git Rules

- Fetch and verify the latest `master` before branching for a new task when a remote exists.
- Never force-push.
- Do not merge or push to `master` until the task has passed relevant verification.
- Keep unrelated user changes intact.

## Reporting

- User-facing updates and final reports should be in Russian unless the user asks otherwise.
- Final reports should include the branch, commit or push status, verification performed, and any blockers.
