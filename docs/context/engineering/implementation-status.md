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

Post-M6 update manifest hardening:

- `src/TestFramework/UpdateManifest/UpdateManifest.psm1`
- `src/TestFramework/UpdateManifest/UpdateManifest.Tests.ps1`
- `scripts/run-update-manifest-gate.ps1`
- `testdata/update-manifest.example.json`
- `testdata/update-manifest-unsafe.example.json`
- `docs/qa/update-manifest-gate.md`

Implemented checks:

- dry-run-only policy;
- network, updater execution, rollback and credentials disabled;
- endpoint and executable command rejection;
- stable package ids and semantic-like versions;
- local relative artifact paths only;
- SHA-256 digest shape;
- positive package size;
- signature-required enforcement;
- rollback and post-install command rejection.

Post-M6 testability gaps registry:

- `src/TestFramework/TestabilityGaps/TestabilityGaps.psm1`
- `src/TestFramework/TestabilityGaps/TestabilityGaps.Tests.ps1`
- `scripts/run-testability-gaps.ps1`
- `testdata/testability-gaps.example.json`
- `testdata/testability-gaps-unsafe.example.json`
- `docs/qa/testability-gaps.md`

Implemented checks:

- dry-run-only policy;
- production execution, runtime data reads and credentials disabled;
- stable `GAP-###` ids;
- approved areas and statuses;
- open runtime gaps are not marked production-safe;
- gaps do not require credentials or user runtime data;
- approved closure evidence is required;
- stop-and-ask triggers are required;
- safe next steps are required.

## M2 - App launch + WebView smoke

Status: static/dry-run scaffold implemented and merged to `main`; no real client launch.

Implemented outputs:

- `src/TestFramework/WindowsSmoke/WindowsSmoke.psm1`
- `src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1`
- `scripts/run-app-webview-smoke.ps1`
- `scripts/quality-gate.ps1` AppSmoke scope
- `testdata/app-webview-smoke.example.json`
- `testdata/app-webview-smoke-unsafe-policy.example.json`
- `testdata/app-webview-smoke-fixture/**`
- `docs/qa/app-webview-smoke.md`

Implemented checks:

- required client and CEF files;
- WebView bundle entrypoints and asset manifests;
- manifest keys for `main.css`, `main.js` and `index.html`;
- dry-run-only policy;
- unsafe launch argument and runtime path rejection;
- ProdGuard validation of policy test metadata.

Not implemented in M2:

- real Windows client launch;
- native UI/window detection;
- WebView runtime rendering verification;
- WebView debug/CDP connection;
- authentication;
- game-session tests.

## Governance - Thread lifecycle

Status: documentation correction implemented and merged to `main`.

Implemented outputs:

- Thread-per-task rule added to source-of-truth docs.
- `create_thread` priority added for new independent tasks.
- Codex worktree use documented for follow-on tasks that need isolated branch/workspace state.
- Retry behavior documented: unusable, invisible or unmanageable thread attempts are marked inactive/orphan, normal `create_thread` is retried once, then worktree fallback is used after a second normal failure.
- Previous task thread lifecycle clarified: unarchived but inactive after handoff.
- `PROCESS_ERROR_THREAD_REUSE` defined for continuing a new independent task in the previous thread.

Current process error:

- M3 implementation started to continue in the previous long-running thread context.
- M3 implementation must stop in this thread and resume in a dedicated M3 task thread.
- M3 thread attempt `019e7902-70cb-7f31-8487-907e53f1fc45` is inactive/orphan; retry `019e7907-e739-7213-a690-125ea2fbafeb` accepted a follow-up message.

## M3 - WebView/native bridge contract + fake native host

Status: local/dry-run scaffold implemented and merged to `main`.

Implemented outputs:

- `src/TestFramework/WebViewBridge/WebViewBridge.psm1`
- `src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1`
- `scripts/run-webview-bridge-contract.ps1`
- `testdata/webview-bridge-contract.example.json`
- `testdata/webview-bridge-contract-unsafe.example.json`
- `docs/qa/webview-bridge-contract.md`

Implemented checks:

- command and event registry validation;
- direction validation for `web -> native` commands and `native -> web` events;
- payload schema presence;
- expected effects and malformed-payload behavior;
- sanitized logging policy and `PROD_SAFE` local contract classification;
- fake native host case target validation;
- malformed case rejection/error/ignore expectations;
- dry-run-only policy;
- WebView debug/CDP and runtime user path rejection.

Not implemented:

- real C++ native bridge handler verification;
- runtime WebView rendering;
- client launch;
- WebView debug/CDP connection;
- authentication;
- game-session tests.

## M4 - Safe backend smoke

Status: local/dry-run scaffold implemented and merged to `main`.

Implemented outputs:

- `src/TestFramework/BackendSmoke/BackendSmoke.psm1`
- `src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1`
- `scripts/run-backend-smoke.ps1`
- `testdata/backend-smoke.example.json`
- `testdata/backend-smoke-unsafe.example.json`
- `docs/qa/backend-smoke.md`

Implemented checks:

- endpoint registry validation;
- read-only `GET` method enforcement;
- `PROD_SAFE` classification enforcement;
- no-auth and no-state-mutation enforcement;
- endpoint path checks for user ids, tokens, secrets and session values;
- response schema and mock response presence;
- dry-run-only policy;
- real network call disablement;
- auth, cookie, token, secret and session header rejection;
- runtime user path rejection.

Not implemented:

- real backend network calls;
- authentication or synthetic-user backend flows;
- production endpoint availability checks;
- catalog freshness checks against production;
- state-mutating backend tests;
- game-session tests.

## M5 - Minimal game-session canary readiness gate

Status: dry-run readiness gate implemented and merged to `main`.

Implemented outputs:

- `src/TestFramework/GameSessionCanary/GameSessionCanary.psm1`
- `src/TestFramework/GameSessionCanary/GameSessionCanary.Tests.ps1`
- `scripts/run-game-session-canary.ps1`
- `testdata/game-session-canary.example.json`
- `testdata/game-session-canary-unsafe.example.json`
- `docs/qa/game-session-canary.md`

Implemented checks:

- dry-run-only policy;
- direct validator invocation requires the dry-run flag;
- real execution, client launch, network and auth disablement;
- runtime user path rejection;
- exactly one `PROD_CONDITIONAL` canary test;
- allowlisted synthetic user via ProdGuard;
- allowlisted region and game via resource budget and allowed-games config;
- max session duration within budget;
- cleanup verification requirement;
- retry rejection;
- readiness signal requirements for `stream-ready` and `first-frame`.

Not implemented:

- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- runtime stream readiness or first-frame detection;
- reading user AppData, logs, cookies, DBs or dumps.

## M6 - Future non-prod/fake/replay/network/hardware foundation

Status: local/dry-run schema validator implemented and merged to `main`.

Implemented outputs:

- `src/TestFramework/NonProdFoundation/NonProdFoundation.psm1`
- `src/TestFramework/NonProdFoundation/NonProdFoundation.Tests.ps1`
- `scripts/run-nonprod-foundation.ps1`
- `testdata/nonprod-foundation.example.json`
- `testdata/nonprod-foundation-unsafe.example.json`
- `docs/qa/nonprod-foundation.md`

Implemented checks:

- dry-run-only policy;
- direct validator and runner require the dry-run flag;
- execution, client launch, WebView debug/CDP, network calls, auth, runtime data reads and CI/CD enablement are disabled;
- runtime user paths and production endpoints are rejected;
- future components must be `NON_PROD_ONLY`;
- future components must be schema/config placeholders only;
- fake/replay/network/hardware/update-rollback lab execution is disabled;
- production use, credentials, state mutation and game-session start are rejected;
- local contract schemas are required.

Not implemented:

- fake backend/signaling runtime;
- replay server runtime;
- network shaping;
- hardware or decoder probing;
- update rollback execution;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Script inventory guard

Status: local documentation/quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/README.md`
- `scripts/quality-gate.ps1`

Implemented checks:

- `scripts/README.md` lists every `scripts/*.ps1` runner;
- `Context` quality gate fails closed if a runner is added without being documented;
- script inventory safety text covers client launch, WebView debug/CDP, auth, game sessions, production backend/streaming, production mutation, user runtime data, CI/CD and dependency changes.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Dangerous flag negative coverage

Status: local quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`

Implemented checks:

- `UpdateManifest` quality gate asserts `-AllowNetwork`, `-AllowExecution`, `-AllowRollback` and `-AllowCredentials` rejection;
- `GameSessionCanary` quality gate asserts `-AllowClientLaunch`, `-AllowNetwork` and `-AllowAuth` rejection;
- `NonProdFoundation` quality gate asserts `-AllowExecution`, `-AllowNetwork` and `-AllowAuth` rejection;
- `TestabilityGaps` quality gate asserts `-AllowProductionAction`, `-AllowCredentials` and `-AllowRuntimeUserData` rejection.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Runner/validator guard hardening

Status: local runner/quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/run-app-webview-smoke.ps1`
- `scripts/run-prod-safe-smoke.ps1`
- `scripts/run-prod-canary.ps1`
- `src/TestFramework/WindowsSmoke/WindowsSmoke.psm1`
- `src/TestFramework/WindowsSmoke/WindowsSmoke.Tests.ps1`
- `src/TestFramework/WebViewBridge/WebViewBridge.psm1`
- `src/TestFramework/WebViewBridge/WebViewBridge.Tests.ps1`
- `src/TestFramework/BackendSmoke/BackendSmoke.psm1`
- `src/TestFramework/BackendSmoke/BackendSmoke.Tests.ps1`
- `scripts/quality-gate.ps1`
- `docs/qa/app-webview-smoke.md`
- `docs/qa/webview-bridge-contract.md`

Implemented checks:

- App/WebView smoke runner now has the same explicit `if (-not $DryRun)` fail-closed guard as other dry-run runners;
- prod-safe smoke and prod canary runners reject calls without `-DryRun` before guard metadata execution;
- App/WebView smoke, WebView bridge and BackendSmoke direct validators add `dry-run-flag-required` fail findings without `-DryRun`;
- `AppSmoke` quality gate asserts missing `-DryRun` rejection;
- `AppSmoke` quality gate asserts `-AllowClientLaunch` rejection;
- `AppSmoke` quality gate asserts `-AllowWebViewDebugPort` rejection;
- `BridgeContract` quality gate asserts missing `-DryRun` rejection;
- `BridgeContract` quality gate asserts `-AllowClientLaunch` rejection;
- `BridgeContract` quality gate asserts `-AllowWebViewDebugPort` rejection.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - M1 dry-run fail-closed hardening

Status: local runner/quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/run-release-gate.ps1`
- `scripts/run-privacy-gate.ps1`
- `scripts/quality-gate.ps1`
- `docs/qa/release-gates.md`
- `docs/qa/privacy-and-logging-checks.md`

Implemented checks:

- release runner rejects calls without `-DryRun` before reading artifact roots;
- privacy runner rejects calls without `-DryRun` before reading artifact roots;
- `Release` quality gate asserts missing `-DryRun` rejection;
- `Privacy` quality gate asserts missing `-DryRun` rejection.

Not implemented:

- any new runtime runner;
- installed client launch;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.
