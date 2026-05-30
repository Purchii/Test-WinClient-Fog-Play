/goal Implement production-safe QA automation guard foundation for MTC Fog Play Windows client.

Context:
We are starting QA automation for a Windows C++ cloud-gaming client with an embedded WebView/CEF/WebView-like layer.
The current operational reality is that automation may run against production.
All automation must be production-safe by default.
No classification = no prod run.
No synthetic user guard = no prod auth test.
No resource budget = no prod game session test.
No cleanup verification = no prod state mutation test.

Critical source-of-truth rule:
Old chat context is advisory only. Repository docs and code are the source of truth.
If an important decision exists only in chat, record it in repository docs before relying on it.

Git rules:
- Do not work directly on main for this backlog task.
- Start from a clean, up-to-date main.
- Create or propose a dedicated task branch, for example codex/prod-safety-foundation.
- Do not merge to main unless the user explicitly approves it.
- Builder/subagents must not commit/push; orchestrator commits only after verification.


Communication:
- Answer the user in Russian by default.
- Keep code identifiers, commands, paths and config keys in English/as-is.
- Do not reveal private chain-of-thought; provide concise Russian reasoning summaries with assumptions, rationale, risks and verification.

Execution mode:
- Discovery and initial plan: NON_AUTONOMOUS. Do not change files before the plan is accepted.
- Implementation after user accepts the plan: BOUNDED_AUTONOMOUS within M0 scope only.
- Stop and ask before any production-impacting action, game-session test, credential/secret use, CI/CD enablement, dependency upgrade, ProdGuard/KillSwitch weakening, commit/push if not explicitly allowed, or merge to main.


Planning requirement:
In `NON_AUTONOMOUS` mode, produce:
1. repository map;
2. confirmed assumptions and blockers;
3. high-level roadmap for M0-M6;
4. detailed technical implementation plan for the current milestone M0 only;
5. exact allowed file changes for M0;
6. forbidden actions for M0;
7. acceptance criteria for M0;
8. verification commands for M0;
9. stop-and-ask triggers.

Do not produce a detailed implementation plan for all future milestones unless explicitly requested.
Future milestones should remain high-level until their own `NON_AUTONOMOUS` planning step.
After the user approves the M0 plan, continue in `BOUNDED_AUTONOMOUS` mode within M0 scope only.

Read first:
- AGENTS.md
- docs/context/handoff/active-run.md
- docs/context/current-state.md
- docs/context/handoff/context-protocol.md
- docs/context/handoff/executor-policy.md
- docs/context/handoff/executor-checklist.md
- docs/context/engineering/git-workflow.md
- docs/qa/test-strategy.md
- docs/qa/prod-testing-policy.md
- docs/qa/synthetic-users-policy.md
- docs/qa/resource-budget-policy.md
- docs/qa/artifacts-policy.md
- docs/qa/flakiness-policy.md
- docs/codex/goal-mode-rules.md
- docs/codex/autonomy-modes.md
- docs/codex/milestone-planning-policy.md
- docs/codex/communication-policy.md
- docs/codex/agent-roles.md
- docs/codex/prod-safe-codex-rules.md

First do discovery, do not change code yet:
- inspect repository structure;
- locate Windows client source;
- locate WebView/CEF/WebView2 frontend code;
- locate native bridge handlers;
- locate updater/packaging/release scripts;
- locate existing tests/CI;
- locate logging/telemetry/Sentry/crash handling;
- identify whether this is CEF, WebView2, or another embedded web layer;
- confirm whether app launch, login, catalog, game session, update and release artifacts are observable/testable;
- summarize repo map, risks, proposed task branch, high-level roadmap M0-M6, detailed M0 plan and M0 verification commands.

Objective:
Implement the first milestone only: production-safety foundation plus Git/handoff/verification governance for QA automation.

Allowed scope:
- AGENTS.md updates, if missing or incomplete;
- docs/context/current-state.md;
- docs/context/handoff/active-run.md;
- docs/context/handoff/context-protocol.md;
- docs/context/handoff/executor-policy.md;
- docs/context/handoff/executor-checklist.md;
- docs/context/governance/decisions-log.md;
- docs/context/governance/session-log.md;
- docs/context/governance/context-integrity-checklist.md;
- docs/context/engineering/git-workflow.md;
- docs/context/engineering/implementation-status.md;
- docs/context/engineering/verification-memory.md;
- docs/context/engineering/quality-gates.md;
- docs/qa/prod-testing-policy.md;
- docs/qa/synthetic-users-policy.md;
- docs/qa/prod-safe-test-matrix.md;
- docs/qa/resource-budget-policy.md;
- docs/qa/artifacts-policy.md;
- docs/qa/flakiness-policy.md;
- docs/codex/*;
- src/TestFramework/ProdSafety/ or equivalent existing framework path;
- scripts/quality-gate.ps1;
- scripts/run-prod-safe-smoke.ps1;
- scripts/run-prod-canary.ps1;
- scripts/run-release-gate.ps1;
- testdata/*.example.*;
- unit tests/dry-run tests for ProdGuard.

Not allowed in this first milestone:
- adding real game-session tests;
- starting production game sessions;
- adding load/stress/chaos/destructive tests;
- update rollback tests on production;
- hardcoding real credentials;
- using real user accounts;
- weakening any kill switch or guard;
- enabling WebView debug port in production without explicit diagnostic/canary constraints;
- hiding flakiness with blind retries;
- committing logs, crash dumps or release binaries unless explicitly approved as fixtures;
- merging to main without explicit user approval.

Required implementation:
- TestClassification with at least: PROD_SAFE, PROD_CONDITIONAL, PROD_FORBIDDEN, NON_PROD_ONLY;
- TestMetadata or equivalent annotation/config;
- ProdGuard rejecting unclassified tests on production;
- ProdGuard rejecting PROD_FORBIDDEN tests on production;
- ProdGuard rejecting PROD_CONDITIONAL tests unless explicit flag is present;
- SyntheticUserGuard skeleton/config validation;
- ResourceBudget skeleton/config validation;
- KillSwitch based on environment/config, e.g. PROD_AUTOMATION_ENABLED and QA_PROD_CANARY_ENABLED;
- CleanupVerifier skeleton;
- scripts that make it impossible to accidentally run conditional/forbidden tests from prod-safe smoke;
- docs explaining what is safe, conditional, forbidden;
- Git/handoff/verification-memory docs for Codex sessions.

Acceptance criteria:
- repository map is produced before implementation;
- dedicated task branch is used or a blocker is documented;
- production-safety rules are documented;
- every test category has a classification rule;
- unclassified tests cannot run on production;
- PROD_FORBIDDEN cannot run on production;
- PROD_CONDITIONAL requires explicit flag and budget checks;
- synthetic user allowlist example exists;
- resource budget example exists;
- kill switch exists;
- cleanup verifier skeleton exists;
- Git branch-per-task workflow is documented;
- autonomy modes are documented and active-run.md records the selected mode;
- active-run.md, decisions-log.md, session-log.md and verification-memory.md exist;
- dry-run or unit tests demonstrate guard behavior;
- no secrets or real credentials are introduced;
- no production game sessions are started;
- final report lists autonomy mode, changed files, commands run, verification result, risks, blockers and next backlog.

Verification:
Run the strongest available verification in this repo. Prefer:
- unit tests for ProdGuard;
- dry-run of prod-safe smoke command;
- dry-run showing unclassified/prod-forbidden rejection;
- dry-run showing PROD_CONDITIONAL requires explicit flag;
- scripts/quality-gate.ps1 -Scope ProdSafety, if implemented;
- scripts/quality-gate.ps1 -Scope Context, if implemented;
- lint/typecheck/build if available;
- git status --short and git diff --check.

Before final report:
- update docs/context/engineering/verification-memory.md;
- update docs/context/governance/session-log.md;
- update docs/context/handoff/active-run.md;
- update docs/context/engineering/implementation-status.md, if implementation changed;
- show git status;
- do not merge to main unless explicitly instructed.

Stop when:
- the guard foundation is implemented or a concrete blocker is documented;
- verification has been run or clearly explained as unavailable;
- final report includes changed files, risks, blockers and next steps.

Pause and ask only if:
- required repository/build artifact is missing;
- the app cannot be launched and no local/mock path is possible;
- credentials are required and cannot be safely configured;
- requested behavior conflicts with production safety rules.
