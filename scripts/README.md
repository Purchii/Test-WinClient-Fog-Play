# Scripts

Implemented local runners:

```text
quality-gate.ps1
run-app-webview-smoke.ps1
run-backend-smoke.ps1
run-game-session-canary.ps1
run-nonprod-foundation.ps1
run-privacy-gate.ps1
run-prod-canary.ps1
run-prod-safe-smoke.ps1
run-release-gate.ps1
run-testability-gaps.ps1
run-update-manifest-gate.ps1
run-webview-bridge-contract.ps1
```

These runners are guard/dry-run first. They must not launch the Windows client, enable WebView debug/CDP, authenticate, start a game session, call production backend or streaming services, mutate production state, read user AppData/logs/cookies/DB/dumps, enable CI/CD, or change dependencies by default.

Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...` on machines where local script execution is restricted by PowerShell policy.

The `Context` quality gate fails if this inventory stops listing any `scripts/*.ps1` runner.

The `Context` quality gate also fails if any `quality-gate.ps1 -Scope` value is documented but not wired into the `Full` dispatch.

The `ActiveRunSafety` quality gate fails if the active handoff/current-state docs lose required stop-and-ask triggers, record stale literal latest-commit markers, or omit current static safety gates.

The `IncidentStopSafety` quality gate fails if stop triggers drift out of `docs/qa/incident-stop-policy.md`, active handoff, or testability gap fixtures.

The `QaDocsSafety` quality gate fails if the required `docs/qa/*.md` policy inventory changes without updating the gate, or if core safety phrases are removed.

The `RunnerSafety` quality gate fails if a `run-*.ps1` runner loses `-DryRun`, stops rejecting missing `-DryRun`, exposes an unguarded dangerous `Allow*` switch, or introduces forbidden runtime/network primitives.

The `TestDataSafety` quality gate fails if risky fixture content is added outside the explicit unsafe/negative fixture allowlist.

The `SyntheticUsersSafety` quality gate fails if the synthetic users fixture stops being alias-only, gains credential-like data, or grants game-session permission outside bounded canary aliases.

The `AllowedGamesSafety` quality gate fails if the allowed-games fixture stops being alias-only, gains real game metadata, or allows purposes outside the production canary plan.

The `ResourceBudgetSafety` quality gate fails if the production resource budget stops being single-session, short-duration, cleanup-gated, explicitly conditional, or tied to production canary game aliases.

The `ProdMetadataSafety` quality gate fails if production test metadata suites drift away from their required classifications, aliases, targets or session/cleanup flags.

The `ProdMatrixSafety` quality gate fails if the production-safe test matrix drifts into unsafe classifications.

The `BacklogSafety` quality gate fails if the value/effort backlog drifts out of the approved M0-M6 roadmap shape.
