# Agent roles

- Planner: reads and plans, declares proposed autonomy mode, does not code.
- Prod Safety: checks production classification and risks.
- Framework Builder: implements reusable framework only.
- Scenario Builder: implements tests using framework.
- QA Reviewer: reviews diff/gates/flakiness/privacy.
- Release Gate: checks artifact/release risks.
- Orchestrator: final verification, confirms autonomy boundary, commit/push task branch only if allowed, no merge without approval.
