# Codex prompt: new thread in BOUNDED_AUTONOMOUS mode

Use this prompt only after the user has already approved the plan for the current milestone.
For first discovery of an unknown repository, use NON_AUTONOMOUS mode first.

```text
/goal Continue M0 in BOUNDED_AUTONOMOUS mode: implement production-safe QA automation guard foundation for MTC Fog Play Windows client.

Communication:
- Answer the user in Russian by default.
- Keep technical identifiers unchanged: file paths, commands, class names, enum values, environment variables, branch names and test names.
- Do not reveal private chain-of-thought or raw scratchpad reasoning.
- Provide concise Russian reasoning summaries: assumptions, rationale, production-safety implications, risks, verification and blockers.

Execution mode:
BOUNDED_AUTONOMOUS within the approved M0 scope only.

This means:
- you may continue implementation without asking after each small step;
- you must stay inside the approved scope, acceptance criteria and forbidden actions;
- you must stop and ask before any production-impacting action, credential/secret use, game-session test, CI/CD enablement, dependency upgrade, ProdGuard/KillSwitch weakening, commit/push if not explicitly allowed, or merge to main;
- old chat context is advisory only; repository docs and code are the source of truth.

Context:
We are building QA automation for a Windows C++ cloud-gaming client with an embedded WebView/CEF/WebView-like layer.
The current operational reality is that automation may run against production.
All automation must be production-safe by default.

Hard rules:
- No classification = no prod run.
- No synthetic user guard = no prod auth test.
- No resource budget = no prod game session test.
- No cleanup verification = no prod state mutation test.
- No direct work in main.
- No merge to main without explicit user approval.
- No real credentials, real user accounts, production secrets, unsanitized logs, crash dumps or release binaries in git.

Read first in this fresh thread:
1. AGENTS.md
2. docs/context/handoff/active-run.md
3. docs/context/current-state.md
4. docs/context/handoff/context-protocol.md
5. docs/context/handoff/executor-policy.md
6. docs/context/handoff/executor-checklist.md
7. docs/context/engineering/git-workflow.md
8. docs/context/engineering/implementation-status.md
9. docs/context/engineering/verification-memory.md
10. docs/context/governance/decisions-log.md
11. docs/context/governance/session-log.md
12. docs/qa/test-strategy.md
13. docs/qa/prod-testing-policy.md
14. docs/qa/prod-safe-test-matrix.md
15. docs/qa/synthetic-users-policy.md
16. docs/qa/resource-budget-policy.md
17. docs/qa/artifacts-policy.md
18. docs/qa/flakiness-policy.md
19. docs/codex/autonomy-modes.md
20. docs/codex/milestone-planning-policy.md
21. docs/codex/communication-policy.md
22. docs/codex/prod-safe-codex-rules.md
23. docs/codex/git-handoff-rules.md
24. task-specific files and current git diff.

Before continuing in this autonomous thread:
- confirm that a detailed M0 plan was already accepted by the user and is reflected in active-run.md or previous handoff;
- if no accepted detailed M0 plan exists, stop and ask for NON_AUTONOMOUS planning approval;
- do not create a detailed implementation plan for future milestones; future milestones remain high-level until their own planning step.

Before changing files:
- run or inspect `git status --short`;
- confirm you are not working directly on main;
- confirm or create the dedicated task branch, unless the branch already exists;
- read active-run.md and identify the current M0 status;
- summarize in 5-10 lines what has already been done and what remains;
- then continue implementation inside the approved M0 scope.

Approved M0 objective:
Implement production-safety foundation plus Git/handoff/verification governance for QA automation.

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

Forbidden in this autonomous thread:
- adding real game-session tests;
- starting production game sessions;
- running production-impacting tests;
- adding load/stress/chaos/destructive tests;
- update rollback tests on production;
- hardcoding real credentials;
- using real user accounts;
- weakening ProdGuard, KillSwitch, SyntheticUserGuard, ResourceBudget or CleanupVerifier;
- enabling WebView debug port in production without explicit diagnostic/canary constraints;
- hiding flakiness with blind retries;
- committing logs, crash dumps or release binaries unless explicitly approved as fixtures;
- committing/pushing unless the user explicitly allowed it for this thread;
- merging to main.

Required implementation:
- TestClassification with at least: PROD_SAFE, PROD_CONDITIONAL, PROD_FORBIDDEN, NON_PROD_ONLY;
- TestMetadata or equivalent annotation/config;
- ProdGuard rejecting unclassified tests on production;
- ProdGuard rejecting PROD_FORBIDDEN tests on production;
- ProdGuard rejecting PROD_CONDITIONAL tests unless explicit flag is present;
- SyntheticUserGuard skeleton/config validation;
- ResourceBudget skeleton/config validation;
- KillSwitch based on environment/config, for example PROD_AUTOMATION_ENABLED and QA_PROD_CANARY_ENABLED;
- CleanupVerifier skeleton;
- scripts that make it impossible to accidentally run conditional/forbidden tests from prod-safe smoke;
- docs explaining what is safe, conditional, forbidden;
- Git/handoff/verification-memory docs for Codex sessions;
- autonomy mode rules recorded in active-run.md.

Acceptance criteria:
- repository source-of-truth files are re-read in this fresh thread;
- task branch is used or a concrete blocker is documented;
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
- autonomy modes are documented and active-run.md records BOUNDED_AUTONOMOUS mode;
- active-run.md, decisions-log.md, session-log.md and verification-memory.md are updated;
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
- git status --short;
- git diff --check.

Before final report:
- update docs/context/engineering/verification-memory.md;
- update docs/context/governance/session-log.md;
- update docs/context/handoff/active-run.md;
- update docs/context/engineering/implementation-status.md, if implementation changed;
- show git status;
- do not merge to main unless explicitly instructed.

Stop when:
- the approved M0 scope is implemented, or a concrete blocker is documented;
- verification has been run or clearly explained as unavailable;
- final report includes autonomy mode, changed files, commands, verification result, risks, blockers and next steps.

Pause and ask only if:
- required repository/build artifact is missing;
- the app cannot be launched and no local/mock path is possible;
- credentials are required and cannot be safely configured;
- requested behavior conflicts with production safety rules;
- you need to go outside approved M0 scope;
- you need to run anything production-impacting;
- you need to commit/push and explicit permission was not granted.
```
