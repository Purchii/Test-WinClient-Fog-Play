# Decisions log

## D-001: ProdSafety foundation before broad E2E

Status: accepted.

Decision: first milestone is production-safety foundation, not game-session E2E.

## D-002: Branch-per-task Git workflow

Status: accepted.

Decision: Codex does not work directly on main for backlog tasks.

## D-003: No game-session tests before guards

Status: accepted.

Decision: no production game-session automation before ProdGuard, SyntheticUserGuard, ResourceBudget, KillSwitch and CleanupVerifier exist.

## D-004: Release/privacy gates are P0

Status: accepted.

Decision: release artifact and privacy gates are independent from E2E and should be implemented early.

## D-005: Dangerous scenarios are NON_PROD_ONLY until safe infra exists

Status: accepted.

Decision: update rollback, network degradation, load/stress/chaos and destructive tests are not production tests.


## D-006: Explicit autonomy modes

Status: accepted.

Decision: Codex work uses two explicit modes: NON_AUTONOMOUS for discovery/risky/production-impacting work and BOUNDED_AUTONOMOUS only after the user accepts a bounded plan.

## D-007: Empty repository bootstrap

Status: accepted.

Decision: because the GitHub repository and local project root were empty, the starter governance package was imported as the initial local `main` baseline before creating `codex/prod-safety-foundation`.

Safety note: no push or merge to remote `main` has been performed during M0 implementation.

## D-008: Multi-agent and remote Git by default

Status: accepted.

Decision: Codex work uses multi-agent mode by default for non-trivial milestones. If multiple real agents are unavailable, one Codex instance must preserve explicit role separation across Planner, Builder, Prod Safety, QA Reviewer and Orchestrator.

Decision: Codex should work with remote Git directly when that does not reduce quality or safety. Verified task branches may be pushed after approval or accepted project policy. Merge to `main` still requires explicit user approval.

## D-009: Commit and push authority

Status: accepted.

Decision: commit and push are separate actions. Codex may commit or push a task branch only after explicit user approval or after the current accepted milestone policy clearly allows that action. Builder and QA Reviewer never commit or push; Orchestrator may do so only after verification.

Decision: user approval to "push" the current task branch includes permission to create the required local commit for that push, but does not include permission to merge to `main`.

## D-010: Thread per autonomous task

Status: accepted.

Decision: every new independent task or milestone in autonomous work uses a separate Codex thread. The previous task thread remains unarchived, but becomes inactive after handoff.

Decision: continuing implementation for a new independent task in the previous task thread is a process error named `PROCESS_ERROR_THREAD_REUSE`. Codex must record the error in context docs and stop implementation until the task is handed off to a correct thread.
