# Autonomy modes integration note

This package now explicitly includes the Android-project governance idea of two Codex working modes:

```text
NON_AUTONOMOUS / supervised mode
BOUNDED_AUTONOMOUS mode
```

The original package already had related guardrails: no merge to `main` without approval, planner/builder/reviewer split, goal-mode boundaries, production classification, and explicit approval for `PROD_CONDITIONAL` tests.

What was missing was a single explicit policy saying when Codex may continue autonomously and when it must stop and ask. That gap is now closed by:

- `docs/codex/autonomy-modes.md`;
- updated `AGENTS.md`;
- updated `CODEX_FIRST_GOAL_PROMPT.md`;
- updated `CODEX_START_INSTRUCTION.md`;
- updated `CODEX_FINAL_TZ_WINCLIENT_QA_AUTOMATION.md`;
- updated handoff/executor/checklist/templates.

Recommended first-run mode:

```text
Discovery and plan: NON_AUTONOMOUS.
After user accepts the plan: BOUNDED_AUTONOMOUS only inside M0 scope.
Any production-impacting action: NON_AUTONOMOUS.
Merge to main: NON_AUTONOMOUS and explicit user approval required.
```
