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

Status: implementation verified locally; historical installed artifact observations from 2026-05-30 have release/privacy findings and are not release-clean by current policy.

Implemented outputs:

- `scripts/run-release-gate.ps1`
- `scripts/run-privacy-gate.ps1`
- `scripts/quality-gate.ps1` Release/Privacy scopes
- `testdata/release-gate-policy.example.json`
- `testdata/privacy-patterns.example.json`
- `testdata/release-fixture/**`
- `docs/qa/release-gates.md`
- `docs/qa/privacy-and-logging-checks.md`

Historical artifact observation:

- installed signed client directory observed on 2026-05-30: `C:\Program Files\MTC Fog Play`
- current autonomous verification uses committed local fixtures only; installed artifact reads require a separate explicit approved plan.

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
- `Release` and `Privacy` quality gates assert local `-ReportOnly` explicit artifact discovery behavior against finding-producing fixtures.
- Historical release dry-run against installed artifact completed on 2026-05-30 and reported fail findings.
- Historical privacy dry-run against installed artifact completed on 2026-05-30 and reported fail findings.
- `git diff --check` passed.

M1.1 hardening:

- Release/privacy scripts fail closed by default on fail-severity findings.
- `-ExpectFindings` is reserved for negative fixtures; `-ReportOnly` is reserved for explicit artifact discovery.
- Release fixture now exercises signature and version metadata code paths.
- Clean fixtures were added for release and privacy gates.
- Privacy patterns cover access tokens, refresh tokens, bearer tokens, generic token assignments, API keys, private keys, TURN credentials and unquoted passwords.
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
- direct finding-id coverage for missing package registries and invalid package ids;
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
- direct finding-id coverage for missing gap registries, missing next safe steps and runtime gaps without stop triggers;
- safe next steps are required and must not request runtime, credential, production backend, game-session or user data actions.

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
- direct finding-id coverage for missing required files, missing WebView bundles, missing entrypoints, missing manifest keys and invalid asset manifests;
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
- Previous task thread lifecycle further clarified: after a new task thread is created, the previous thread is inactive/history-only, preserved for history, not deleted and not archived automatically unless the user explicitly asks.
- `PROCESS_ERROR_THREAD_REUSE` defined for continuing a new independent task in the previous thread.
- Extended autonomous time, push permission and merge permission now explicitly do not waive thread-per-task.
- Follow-up gates, hardening items, feature slices, backlog items and milestones are explicitly new independent tasks unless they only repair current-task verification.

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
- direct finding-id coverage for invalid/duplicate command names, invalid command direction, missing command production-safety metadata, invalid/duplicate event names, missing event production-safety metadata and missing command/event contract fields;
- direction validation for `web -> native` commands and `native -> web` events;
- payload schema presence;
- expected effects and malformed-payload behavior;
- sanitized logging policy and `PROD_SAFE` local contract classification;
- fake native host case type, target, expected-result and malformed-case rejection validation;
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
- direct finding-id coverage for invalid endpoint names, non-`PROD_SAFE` endpoint classification and missing endpoint registries;
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
- direct finding-id coverage for invalid canary counts, missing game-session intent, missing state-mutation intent, unsafe session-concurrency budgets and non-allowlisted target regions;
- direct plan validation requires `prod-canary` and `game-session-canary-readiness` suite metadata;
- direct plan validation requires an allowlisted `qa-canary-*` synthetic user alias with `prod_conditional_stream_canary` purpose, production environment permission, game-session permission and a matching duration ceiling;
- allowlisted synthetic user via ProdGuard;
- allowlisted region and game via resource budget and allowed-games config;
- max session duration within budget;
- max run frequency within the resource budget policy range;
- cleanup verification and explicit conditional flag budget requirements;
- cleanup verification requirement;
- retry rejection;
- exact readiness signal requirements for `stream-ready` and `first-frame`.

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
- direct finding-id coverage for invalid component names, invalid component types and missing components;
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

## Post-M6 - Repository root inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`
- `docs/context/engineering/verification-memory.md`

Implemented checks:

- new `RepositoryRootInventorySafety` quality gate scope;
- repository root must keep the expected prompt, policy and workspace directory inventory;
- adding, removing or renaming top-level files/directories now requires updating the gate inventory;
- `RepositoryRootInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Root prompt safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `RootPromptSafety` quality gate scope;
- top-level Codex prompt/TZ documents must preserve source-of-truth wording;
- autonomy-mode boundaries must keep NON_AUTONOMOUS/BOUNDED_AUTONOMOUS requirements visible;
- production-impact stop rules and game-session/credential prerequisites must remain explicit;
- `RootPromptSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - ProdSafety framework safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ProdSafetyFrameworkSafety` quality gate scope;
- ProdSafety README must preserve dry-run/no-client/no-auth/no-session/no-mutation safety wording;
- ProdSafety README must preserve classification, explicit conditional flag, synthetic user, resource budget, cleanup and kill-switch requirements;
- ProdSafety module must keep the expected guard functions and exported contract;
- ProdSafety regression tests must keep assertions for unclassified, forbidden, non-prod-only, conditional and kill-switch behavior;
- `ProdSafetyFrameworkSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Script encoding safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ScriptEncodingSafety` quality gate scope;
- every `scripts/*.ps1` file must stay UTF-8-BOM-free;
- every `scripts/*.ps1` file must stay ASCII-only to avoid Windows PowerShell parser and mojibake drift;
- `ScriptEncodingSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - PowerShell structured syntax safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `PowerShellStructuredSyntaxSafety` quality gate scope;
- parser-only syntax validation for `scripts/*.ps1`;
- parser-only syntax validation for `src/TestFramework/**/*.ps1` and `src/TestFramework/**/*.psm1`;
- validation uses `[System.Management.Automation.Language.Parser]::ParseFile(...)` without importing modules or executing scripts;
- `PowerShellStructuredSyntaxSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any module import or script execution;
- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Binary fixture placeholder safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `BinaryFixturePlaceholderSafety` quality gate scope;
- binary-like files under `testdata/` must match the approved placeholder inventory;
- `.exe`, `.dll` and `.pak` fixtures must stay tiny placeholders no larger than 1KB;
- real PE `MZ` headers are rejected in fixture binaries;
- dump, database and debug-symbol extensions are rejected.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - QA docs command safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QaDocsCommandSafety` quality gate scope;
- command-looking `run-*.ps1` examples in active `docs/qa/*.md` files must include `-DryRun`;
- active QA docs must not show forbidden runtime allow flags such as client launch, WebView debug, network, auth, execution, rollback, credential, TestabilityGaps production-action or runtime-user-data allowances;
- `QaDocsCommandSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Active verification command safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ActiveVerificationCommandSafety` quality gate scope;
- `docs/context/handoff/active-run.md` Last verification command bullets are scanned as active command evidence;
- only the most recent dated `docs/context/engineering/verification-memory.md` entry's `Commands:` block is scanned, leaving historical entries untouched;
- active command evidence is limited to local/static `quality-gate.ps1` scope commands and safe git checks;
- installed-client paths, user runtime paths, URLs, localhost/debug/CDP references, direct runners, auth/network/session/update/dependency, TestabilityGaps production-action/runtime-user-data allow flags and CI commands are rejected;
- `ActiveVerificationCommandSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - QA docs command local path safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QaDocsCommandLocalPathSafety` quality gate scope;
- command-looking `run-*.ps1` examples in active `docs/qa/*.md` files are scanned without checking prose-only lines;
- documented runner commands must not include installed-client paths, user runtime paths, URLs, localhost/debug endpoints, WebView debug/CDP tokens or path arguments outside local `testdata` fixtures;
- `QaDocsCommandLocalPathSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - QA docs PowerShell invocation safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/qa/backend-smoke.md`
- `docs/qa/game-session-canary.md`
- `docs/qa/nonprod-foundation.md`
- `docs/qa/testability-gaps.md`
- `docs/qa/update-manifest-gate.md`
- `docs/qa/webview-bridge-contract.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QaDocsPowerShellInvocationSafety` quality gate scope;
- command-looking `run-*.ps1` examples in active `docs/qa/*.md` files must use `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\...`;
- active QA docs keep the existing `-DryRun` contract from `QaDocsCommandSafety` while documenting the safer PowerShell invocation shape;
- `QaDocsPowerShellInvocationSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - QA docs runner example coverage safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/qa/app-webview-smoke.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QaDocsRunnerExampleCoverageSafety` quality gate scope;
- each active QA runner/doc contract from `FrameworkInventorySafety` must include a command-looking example for its mapped local runner;
- mapped runner examples must use the safe PowerShell invocation shape and include `-DryRun`;
- `app-webview-smoke.md` now documents a fixture-based dry-run command instead of relying on the installed client default path;
- `QaDocsRunnerExampleCoverageSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Quality gates docs scope safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QualityGatesDocsScopeSafety` quality gate scope;
- the preferred command block in `docs/context/engineering/quality-gates.md` must list every `quality-gate.ps1` `ValidateSet` scope exactly once;
- duplicate scopes, unknown scopes and malformed preferred command lines fail closed;
- `QualityGatesDocsScopeSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Active safety scope inventory gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ActiveSafetyScopeInventorySafety` quality gate scope;
- all `*Safety` scopes from `quality-gate.ps1` `ValidateSet` must be visible in `active-run.md`;
- all `*Safety` scopes from `quality-gate.ps1` `ValidateSet` must be visible in `current-state.md`;
- the active milestone marker must end in a known `*Safety` scope;
- `ActiveSafetyScopeInventorySafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Scripts README scope safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ScriptsReadmeScopeSafety` quality gate scope;
- every `quality-gate.ps1 -Scope` value except `Full` must be mentioned in `scripts/README.md`;
- runtime scaffold scopes are documented as local, dry-run and non-runtime where applicable;
- `ScriptsReadmeScopeSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Governance history scope safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `GovernanceHistoryScopeSafety` quality gate scope;
- every `*Safety` scope from `quality-gate.ps1` `ValidateSet` must be mentioned in `verification-memory.md`;
- every `*Safety` scope from `quality-gate.ps1` `ValidateSet` must be mentioned in `session-log.md`;
- `GovernanceHistoryScopeSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - TestData structured syntax safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `TestDataStructuredSyntaxSafety` quality gate scope;
- every JSON fixture under `testdata/` must parse successfully;
- `testdata/prod-resource-budget.example.yaml` must keep the top-level `prodResourceBudget` mapping;
- production resource budget YAML must keep the required budget keys;
- `TestDataStructuredSyntaxSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Quality gate structure safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QualityGateStructureSafety` quality gate scope;
- every `quality-gate.ps1 -Scope` value except `Full` must have exactly one matching `Invoke-<Scope>Gate` function;
- every `quality-gate.ps1 -Scope` value except `Full` must have exactly one matching `Full` dispatch block;
- stale unused placeholder helpers such as `Invoke-StubGate` must not remain after all scopes are implemented;
- `QualityGateStructureSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
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

## Post-M6 - BacklogSafety static gate

Status: local quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `docs/qa/value-effort-backlog.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `BacklogSafety` quality gate scope;
- value/effort backlog must contain exactly one row for each M0-M6 milestone;
- value and effort must stay in the 1-5 range;
- priority values must stay in the approved P0/P1/P2 combinations;
- runtime/non-prod milestones must remain P1/P2 until prerequisites are approved;
- `BacklogSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - ProdMatrixSafety static gate

Status: local quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `docs/qa/prod-safe-test-matrix.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ProdMatrixSafety` quality gate scope;
- production-safe test matrix rows must use supported classifications;
- session/stream scenarios must not be marked `PROD_SAFE`;
- rollback, load/stress, network chaos and destructive scenarios must stay `PROD_FORBIDDEN` on production and document `NON_PROD_ONLY`;
- conditional scenarios must document guard requirements;
- `ProdMatrixSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Quality gate scope inventory guard

Status: local context quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- `Context` quality gate extracts supported scopes from `quality-gate.ps1` `ValidateSet`;
- `Context` quality gate fails if `docs/context/engineering/quality-gates.md` does not list any supported scope.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - TestDataSafety static gate

Status: local quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/engineering/quality-gates.md`
- `docs/qa/artifacts-policy.md`

Implemented checks:

- new `TestDataSafety` quality gate scope;
- text fixtures under `testdata/` are scanned up to a bounded size;
- secret-like assignments, bearer tokens, absolute user paths, runtime user-data paths and non-placeholder URLs are rejected outside explicit unsafe/negative fixture allowlists;
- `TestDataSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - TestDataInventorySafety static gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `TestDataInventorySafety` quality gate scope;
- `testdata/` must keep the expected fixture file inventory;
- adding, removing or renaming fixture files now requires updating the gate inventory;
- `TestDataInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - RunnerSafety static gate

Status: local quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `RunnerSafety` quality gate scope;
- every `scripts/run-*.ps1` runner must expose `-DryRun`;
- every `scripts/run-*.ps1` runner must reject missing `-DryRun`;
- dangerous `Allow*` switches must be explicitly rejected unless allowlisted;
- path-like runner inputs must preserve unsafe runtime input path guard vocabulary and explicit per-parameter guard coverage;
- `scripts/*.ps1` and TestFramework files must not introduce forbidden runtime/network primitives such as `Start-Process`, `Invoke-WebRequest` or `Invoke-RestMethod`;
- `RunnerSafety` is included in `Full`.

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
- `BackendSmoke` quality gate asserts `-AllowNetwork`, `-AllowAuth`, unsafe endpoint path and missing mock response rejection;
- `GameSessionCanary` quality gate asserts `-AllowClientLaunch`, `-AllowNetwork` and `-AllowAuth` rejection;
- `NonProdFoundation` quality gate asserts `-AllowExecution`, `-AllowNetwork` and `-AllowAuth` rejection;
- `TestabilityGaps` quality gate asserts unsafe next-safe-step text, `-AllowProductionAction`, `-AllowCredentials` and `-AllowRuntimeUserData` rejection.

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
- `BridgeContract` quality gate asserts `-AllowWebViewDebugPort` rejection;
- `BridgeContract` quality gate asserts unsafe bridge logging policy rejection;
- `BackendSmoke` quality gate asserts `-AllowNetwork`, `-AllowAuth`, unsafe endpoint path and missing mock response rejection.

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

## Post-M6 - Synthetic users fixture safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/qa/synthetic-users-policy.md`
- `testdata/prod-resource-budget.example.yaml`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `SyntheticUsersSafety` quality gate scope;
- `testdata/synthetic-users.example.json` must contain a top-level `syntheticUsers` allowlist;
- synthetic users must stay alias-only and avoid credential-like properties or values;
- aliases must use the non-secret `qa-*` format with numeric suffixes;
- allowed environments and purposes must stay within the documented safe set;
- game-session permission is limited to `qa-canary-*` aliases with `prod_conditional_stream_canary` purpose, a maximum duration of 120 seconds and duration no higher than `prod-resource-budget.example.yaml`;
- `SyntheticUsersSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Resource budget fixture safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/qa/resource-budget-policy.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ResourceBudgetSafety` quality gate scope;
- `testdata/prod-resource-budget.example.yaml` must contain the expected `prodResourceBudget` keys only;
- budget fixture must avoid credential-like fields, URLs and user runtime paths;
- production game-session budget remains one session per run, one parallel session, at most 120 seconds and at most 3 runs per hour;
- cleanup verification and explicit conditional flags remain required;
- allowed regions and games must be declared as aliases;
- budget games must also be allowlisted in `testdata/allowed-games.example.json` for `prod_conditional_stream_canary`;
- `ResourceBudgetSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Allowed games fixture safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/qa/game-session-canary.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `AllowedGamesSafety` quality gate scope;
- `testdata/allowed-games.example.json` must contain a top-level `allowedGames` allowlist;
- allowed game entries must stay alias-only and avoid real titles, endpoints, credentials or runtime user paths;
- game aliases must use the non-production `qa-*` format with numeric suffixes;
- environments and `allowedFor` purposes must remain within the documented safe set;
- duplicate game aliases are rejected;
- `AllowedGamesSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Production metadata fixture safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `testdata/prod-safety-tests.example.json`
- `testdata/synthetic-users.example.json`
- `testdata/prod-resource-budget.example.yaml`
- `testdata/allowed-games.example.json`
- `docs/qa/prod-testing-policy.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ProdMetadataSafety` quality gate scope;
- `testdata/prod-safety-tests.example.json` must contain a top-level `tests` metadata array;
- metadata entries must avoid credential-like properties, URLs and user runtime paths;
- metadata names, classifications, suites and optional fields are constrained to the local contract;
- `prod-safe-smoke` entries must remain `PROD_SAFE` and read-only;
- optional `PROD_SAFE` synthetic aliases must resolve to `prod_safe_login_logout` users without game-session permission;
- `prod-canary` must remain exactly one `PROD_CONDITIONAL` entry with canary alias, target region, target game, session start, state mutation and cleanup verification metadata;
- `prod-canary` synthetic aliases must resolve to `prod_conditional_stream_canary` users with bounded game-session permission within the resource budget duration;
- `prod-canary` target region and target game must be allowlisted by `prod-resource-budget.example.yaml`;
- `prod-canary` target game must also be present as a production `prod_conditional_stream_canary` alias in `allowed-games.example.json`;
- `PROD_FORBIDDEN` and `NON_PROD_ONLY` placeholders must not be assigned to production runner suites;
- `ProdMetadataSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Active run safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ActiveRunSafety` quality gate scope;
- `active-run.md` must keep the forbidden-action boundary and stop-and-ask triggers explicit;
- active handoff and current-state must mention current static safety gates derived from `quality-gate.ps1`;
- new `*Safety` scopes cannot silently drift out of active/current context checks;
- current-state top statuses, current-state branch history and active-run planning-boundary statuses must stay aligned;
- active handoff must keep the current milestone marker synced with the latest verification-memory codex branch entry;
- active handoff last-verification notes must include `ActiveRunSafety`;
- active handoff must not record stale literal latest-pushed commit markers;
- active handoff must use `git status --short --branch` as the authoritative current branch/worktree source instead of storing a live literal branch value;
- active handoff/current-state must not declare a literal historical thread id as the active task thread;
- current-state must preserve the current autonomous verification source as committed local fixtures only;
- implementation-status must keep installed artifact observations historical and must not describe `C:\Program Files\MTC Fog Play` as the current autonomous verification source;
- context protocol must keep `git log --oneline --decorate -1` as the authoritative latest commit source;
- context protocol must keep `git status --short --branch` as the authoritative current branch/worktree source;
- executor policy must preserve the explicit main-merge approval rule;
- `ActiveRunSafety` is included in `Full`.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Context docs inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`
- `docs/context/engineering/verification-memory.md`
- `docs/context/governance/session-log.md`

Implemented checks:

- new `ContextDocsInventorySafety` quality gate scope;
- `docs/context/*.md` must keep the expected handoff, governance and engineering context inventory;
- adding, removing or renaming context docs now requires updating the gate inventory;
- `ContextDocsInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Session log safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `SessionLogSafety` quality gate scope;
- guarded `docs/context/governance/session-log.md` entries with `Branch: codex/*` must include mode, branch, scope and safety sections;
- guarded branch entries must preserve core no-runtime/no-production safety phrases;
- the most recent `docs/context/governance/session-log.md` entry with `Branch: codex/*` must include thread lifecycle wording regardless of older mode wording;
- the latest session-log codex branch entry must match the latest verification-memory codex branch entry;
- `SessionLogSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Verification memory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`
- `docs/context/engineering/verification-memory.md`

Implemented checks:

- new `VerificationMemorySafety` quality gate scope;
- `docs/context/engineering/verification-memory.md` must not retain unresolved `verification pending` or `- pending` markers;
- codex branch entries must include passed status, production impact, commands and results;
- static branch entries must include a `Not run` rationale;
- entries with installed artifact command evidence must preserve 2026-05-30 historical boundary wording and must not read as current autonomous commands;
- the latest codex branch entry must keep `Safety notes:` with no-real-credentials, no-production-game-session and no-unsafe-test notes;
- `VerificationMemorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Checklist safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ChecklistSafety` quality gate scope;
- executor checklist must preserve before-implementation and before-final-report sections;
- executor checklist must preserve thread isolation, branch, autonomy, production impact, verification, secrets, stop-trigger and production-impact items;
- context integrity checklist must preserve active/current/session/verification/implementation state, thread isolation and durable-decision items;
- `ChecklistSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Decisions log safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `DecisionsLogSafety` quality gate scope;
- decision entries D-001 through D-010 must remain present and accepted;
- durable decisions around production safety, game-session gating, autonomy, multi-agent mode, thread isolation and process errors must remain explicit;
- commit/push and main-merge authority decisions must remain explicit;
- `DecisionsLogSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Codex policy safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `CodexPolicySafety` quality gate scope;
- production-safe Codex rules must keep unclassified/forbidden/conditional production test, credential, guard and game-session prohibitions;
- git handoff and executor policies must preserve branch, autonomy, no-main-merge, no-direct-main, secrets and production-impact classification rules;
- autonomy, goal-mode and workflow policies must preserve NON_AUTONOMOUS defaults, BOUNDED_AUTONOMOUS boundaries, thread isolation and stop-and-ask triggers;
- `CodexPolicySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Task request safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/task-request-log.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `TaskRequestSafety` quality gate scope;
- task request template must preserve bounded goal, context, objective, scope, allowed path, forbidden action, production classification, acceptance criteria, verification and stop-condition fields;
- task request log must not keep the stale no-task marker;
- task request log must point to authoritative session, verification and active-run histories;
- `TaskRequestSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Codex template safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `CodexTemplateSafety` quality gate scope;
- review template must preserve scope, autonomy, production classification, secrets, cleanup, artifacts, verification evidence, docs, no-main-merge and stop-trigger review items;
- task template must preserve execution mode, scope, classification, allowed file, forbidden and verification fields;
- communication policy must preserve Russian reporting, safe reasoning summaries, production-safety implications, verification and stop-and-ask language;
- agent roles must preserve multi-agent role separation, no commit/push for Builder/QA Reviewer, no-main-merge and no-skip-verification remote Git rules;
- `CodexTemplateSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Codex goal template safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `CodexGoalTemplateSafety` quality gate scope;
- `docs/codex/goal-template.md` must preserve execution mode fields;
- goal template must preserve read-first, scope, allowed/forbidden, acceptance, verification and stop-condition sections;
- goal template must preserve stop-and-ask boundaries for production impact, scope expansion, credentials, CI/CD, commit/push and main merge;
- `CodexGoalTemplateSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Codex docs inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `CodexDocsInventorySafety` quality gate scope;
- `docs/codex/*.md` must keep the expected Codex policy/template inventory;
- adding, removing or renaming Codex policy/template docs now requires updating the gate inventory;
- `CodexDocsInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - QA strategy safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QaStrategySafety` quality gate scope;
- QA strategy must preserve layered M0-M6 order and the no-broad-E2E starting rule;
- testability contract must preserve proposed test hooks, WebView debug/CDP production default and testability gap registry linkage;
- flakiness policy must preserve strict retry, observable wait, quarantine follow-up and production session budget rules;
- `QaStrategySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Handoff protocol safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `HandoffProtocolSafety` quality gate scope;
- context protocol must preserve source-of-truth read order, docs/code authority and `git log` latest-commit guidance;
- context protocol must preserve thread isolation, `create_thread` retry, worktree fallback, inactive previous-thread and `PROCESS_ERROR_THREAD_REUSE` rules;
- Git workflow must preserve protected main, branch-per-task, local verification, no-force-push and explicit main-merge approval rules;
- `HandoffProtocolSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Incoming reference safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `AGENTS.md`
- `docs/context/handoff/context-protocol.md`
- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `IncomingReferenceSafety` quality gate scope;
- `docs/_incoming_reference` must keep the expected reference-only markdown inventory;
- AGENTS and context protocol must state that old chat context is advisory only;
- AGENTS and context protocol must state that repository docs and code are source of truth;
- AGENTS and context protocol must state that `docs/_incoming_reference/` is historical/reference-only input and not active scope unless restated in repository docs, scripts or code;
- `IncomingReferenceSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Framework inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `FrameworkInventorySafety` quality gate scope;
- every expected `src/TestFramework` module must keep a matching `.psm1` and `.Tests.ps1`;
- implemented framework modules must keep corresponding local runner scripts, QA docs and example/unsafe fixtures;
- production safety/release/privacy support paths must keep their runner, QA doc and fixture anchors;
- `FrameworkInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - TestFramework inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `TestFrameworkInventorySafety` quality gate scope;
- `src/TestFramework` must keep the expected module, test and local support doc file inventory;
- adding, removing or renaming TestFramework files now requires updating the gate inventory;
- `TestFrameworkInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Scripts inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ScriptsInventorySafety` quality gate scope;
- `scripts/` must keep the expected runner/support file inventory;
- adding, removing or renaming script files now requires updating the gate inventory;
- `ScriptsInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Full scope dispatch guard

Status: local static quality gate hardening implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- `Context` now verifies that every `quality-gate.ps1 -Scope` value except `Full` is wired into exactly one `Full` dispatch block;
- new quality gate scopes cannot be documented but accidentally omitted from complete local verification.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Incident stop safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `docs/qa/incident-stop-policy.md`
- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `IncidentStopSafety` quality gate scope;
- incident stop trigger vocabulary is centralized in `docs/qa/incident-stop-policy.md`;
- active handoff must preserve the core stop-and-ask trigger phrases;
- `testdata/testability-gaps.example.json` gap stop triggers must stay within the approved incident-stop vocabulary;
- `IncidentStopSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - QA docs safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `QaDocsSafety` quality gate scope;
- required `docs/qa/*.md` policy inventory is explicit and checked;
- adding a new QA markdown policy requires updating the gate inventory;
- core safety phrases in production, synthetic users, resource budget, incident stop, flakiness, artifacts, canary and testability docs must remain present;
- release, privacy and App/WebView smoke docs must keep installed artifact defaults bounded to manual/explicit-plan reads while autonomous verification remains committed local fixtures only;
- `QaDocsSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Artifact policy safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ArtifactPolicySafety` quality gate scope;
- release policy fixtures must keep required artifact files, forbidden `.pdb`/`.map` extensions and sanitized finding ids;
- default release policy must require configured signatures while the local clean fixture keeps signature checks relaxed;
- privacy pattern fixture must keep token, password, bearer, API key, private key, local path and TURN credential coverage;
- text extension scanning and maximum text file size remain bounded;
- `ArtifactPolicySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Contract fixture safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `ContractFixtureSafety` quality gate scope;
- backend smoke fixture must stay dry-run, network-disabled, header-free and runtime-path-free;
- backend endpoints must stay `GET`, `PROD_SAFE`, auth-free, read-only and backed by response schemas plus mock responses;
- update manifest fixture must keep network/execution/rollback/credential safety flags enabled and use local relative package metadata with SHA-256, size, signature and rollback constraints;
- WebView bridge fixture must stay dry-run without diagnostics/runtime paths and keep commands/events scoped to sanitized local `PROD_SAFE` bridge contracts;
- fake native host cases must target known bridge commands or events;
- `ContractFixtureSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Static surface safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `StaticSurfaceSafety` quality gate scope;
- App/WebView smoke fixture must stay dry-run-only without launch arguments or runtime paths;
- App/WebView static artifact requirements must keep the client, CEF and resource files;
- WebView bundle inventory must keep expected local bundle paths, entrypoint files and manifest keys;
- non-prod foundation fixture must keep all no-runtime safety flags enabled;
- non-prod foundation components must remain schema-only, `NON_PROD_ONLY`, non-executable and non-production placeholders with local object schemas;
- `StaticSurfaceSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Fixture inventory safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `FixtureInventorySafety` quality gate scope;
- release negative fixture must keep required binaries, installer metadata and sourcemap coverage;
- release clean fixture must keep required binaries while excluding sourcemaps, PDBs and installer metadata;
- privacy fixtures must keep negative, large-file and clean layouts;
- App/WebView smoke fixture must keep required binary/resource files and expected WebView bundle entrypoints;
- `FixtureInventorySafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - WebView bundle local reference safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `WebViewBundleLocalReferenceSafety` quality gate scope;
- fixture WebView bundle entrypoints and `asset-manifest.json` files are scanned without WebView runtime;
- remote `http`/`https`/`ws`/`wss` URLs, localhost references, WebView debug/CDP vocabulary, user runtime paths and production-looking endpoints are rejected;
- manifest `files` mappings must stay root-relative local static paths under `/static/css/`, `/static/js/` and `/index.html`;
- `WebViewBundleLocalReferenceSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.

## Post-M6 - Unsafe fixture coverage safety gate

Status: local static quality gate implemented and verified locally.

Implemented outputs:

- `scripts/quality-gate.ps1`
- `scripts/README.md`
- `docs/context/handoff/active-run.md`
- `docs/context/current-state.md`
- `docs/context/engineering/quality-gates.md`

Implemented checks:

- new `UnsafeFixtureCoverageSafety` quality gate scope;
- every `testdata/*unsafe*.example.json` fixture must be present in the static coverage contract;
- each unsafe fixture coverage contract requires the fixture path to appear in the corresponding TestFramework test or `quality-gate.ps1` scope;
- expected negative coverage requires `Assert-FindingId` assertions for the finding ids tied to that unsafe fixture;
- `game-session-canary-unsafe.example.json` coverage includes the conditional flag budget finding id emitted by the canary validator;
- `UnsafeFixtureCoverageSafety` is included in `Full` and visible in active/current state docs.

Not implemented:

- any new runtime runner;
- installed client launch;
- WebView debug/CDP;
- authentication or real synthetic login;
- production backend or streaming network calls;
- real game-session start/stop;
- reading user AppData, logs, cookies, DBs or dumps.
