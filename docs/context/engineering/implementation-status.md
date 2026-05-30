# Implementation status

## M0 - ProdSafety + Git/Handoff/Verification governance

Status: implemented and verified locally.

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

## M1 - Release artifact + privacy/logging gates

Status: implemented and verified locally.

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
- policy exceptions for current artifact findings.

Verification status:

- `Context` quality gate passed.
- `ProdSafety` regression gate passed.
- `Release` quality gate passed against fixture by detecting expected findings.
- `Privacy` quality gate passed against fixture by detecting expected findings.
- Release dry-run against installed artifact completed and reported fail findings.
- Privacy dry-run against installed artifact completed and reported fail findings.
- `git diff --check` passed.
