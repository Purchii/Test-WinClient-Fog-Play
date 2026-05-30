# Agent roles

This project uses multi-agent mode by default for all non-trivial milestones.

If multiple real agents/subagents are available, use them for role separation. If only one Codex instance is available, it must still run the workflow as separated roles and report the role handoff in Russian:

- Planner: discovery and current-milestone plan only.
- Framework/Scenario Builder: scoped implementation only after plan approval.
- Prod Safety: production classification, credentials, game-session and guard review.
- QA Reviewer: diff review, gates, flakiness and privacy review.
- Orchestrator: final verification, docs sync, commit/push when allowed.

Role separation rule:

- Planner does not change files.
- Builder does not commit/push.
- QA Reviewer does not commit/push.
- Orchestrator commits/pushes only after verification and only when allowed.
- Merge to `main` always requires explicit user approval.

Remote Git rule:

- Prefer working with remote Git directly when it does not reduce quality or safety.
- Pull/fetch before starting a task branch.
- Push verified task branches when allowed by the accepted plan or explicit user instruction.
- Never use remote speed as a reason to skip local verification.
- Never merge or force-push protected trunk without explicit approval.

## Role summary

- Planner: reads and plans, declares proposed autonomy mode, does not code.
- Prod Safety: checks production classification and risks.
- Framework Builder: implements reusable framework only.
- Scenario Builder: implements tests using framework.
- QA Reviewer: reviews diff/gates/flakiness/privacy.
- Release Gate: checks artifact/release risks.
- Orchestrator: final verification, confirms autonomy boundary, commit/push task branch only if allowed, no merge without approval.
