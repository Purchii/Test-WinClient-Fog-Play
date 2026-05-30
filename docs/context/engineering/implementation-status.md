# Implementation status

## M0 - ProdSafety + Git/Handoff/Verification governance

Status: implemented and verified locally; guard hardened in M1.1 after multi-agent audit.

Implemented outputs:

- AGENTS.md
- prod-safety docs
- Git/handoff docs
- ProdSafety skeleton
- dry-run scripts
- testdata examples

Concrete M0 implementation:

- `src/TestFramework/ProdSafety/ProdSafety.psm1`
- `src/TestFramework/ProdSafety/ProdSafety.Tests.ps1`
- `src/TestFramework/ProdSafety/README.md`
- `scripts/quality-gate.ps1`
- `scripts/run-prod-safe-smoke.ps1`
- `scripts/run-prod-canary.ps1`
- `scripts/run-release-gate.ps1`
- `testdata/prod-safety-tests.example.json`

Not implemented in M0:

- real Windows client launch;
- real authentication;
- real game-session tests;
- release artifact scanning;
- CI/CD automation.

Verification status:

- `Context` quality gate passed.
- `ProdSafety` quality gate passed.
- Prod-safe smoke dry-run passed.
- Prod canary dry-run rejects missing explicit flag.
- Prod canary dry-run passes only with explicit flag, budget and cleanup verification.
- `git diff --check` passed.

M1.1 hardening:

- Resource budget now fails closed for `maxSessionsPerRun`, `maxRunsPerHour`, `allowedRegions` and game allowlists.
- `PROD_CONDITIONAL` resource budget validation now checks explicit `targetRegion` and `targetGame` values against allowlists.
- State-mutating or cleanup-required production tests require an allowlisted synthetic user.
- Smoke/canary runners use explicit suite membership instead of selecting all tests by classification.
- Unit coverage includes `NON_PROD_ONLY`, oversized budgets, mutating safe tests without alias and non-dry-run kill switch behavior.

## M1 - Release artifact + privacy/logging gates

Status: implementation verified locally; installed artifact currently has release/privacy findings and is not release-clean by current policy.

Implemented outputs:

- `scripts/run-release-gate.ps1`
- `scripts/run-privacy-gate.ps1`
- `scripts/quality-gate.ps1` Release/Privacy scopes
- `testdata/release-gate-policy.example.json`
- `testdata/privacy-patterns.example.json`
- `testdata/release-fixture/**`
- `docs/qa/release-gates.md`
- `docs/qa/privacy-and-logging-checks.md`

Current artifact source:

- installed signed client directory: `C:\Program Files\MTC Fog Play`

Not implemented in M1:

- client launch;
- WebView smoke;
- authentication;
- game-session tests;
- CI/CD automation;
- policy exceptions for current artifact findings;
- update manifest integrity validation.

Verification status:

- `Context` quality gate passed.
- `ProdSafety` regression gate passed.
- `Release` quality gate passed against negative and clean fixtures.
- `Privacy` quality gate passed against installed-like, negative, large-file and clean fixtures.
- Release dry-run against installed artifact completed and reported fail findings.
- Privacy dry-run against installed artifact completed and reported fail findings.
- `git diff --check` passed.

M1.1 hardening:

- Release/privacy scripts fail closed by default on fail-severity findings.
- `-ExpectFindings` is reserved for negative fixtures; `-ReportOnly` is reserved for explicit artifact discovery.
- Release fixture now exercises signature and version metadata code paths.
- Clean fixtures were added for release and privacy gates.
- Privacy patterns cover bearer tokens, generic token assignments and unquoted passwords.
- Large or unreadable text-like artifacts produce fail findings instead of silent pass.
- Crashpad executable signing is covered by the default release policy.

Known deferred gap:

- Update manifest integrity validation is documented but not implemented until updater/package metadata format is available.
