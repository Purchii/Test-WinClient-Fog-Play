# Active run

Status: Post-M6 static safety gates implemented and verified locally.

Execution mode: autonomous local-safe hardening after explicit user approval to work autonomously and push to `main`.

Current milestone: Post-M6 local/static safety gate hardening complete through StaticSurfaceSafety.

Planning boundary:

```text
Whole project = high-level roadmap M0-M6.
Current roadmap M0-M6 has local/dry-run foundations implemented through M6.
Post-M6 update manifest hardening is complete.
Post-M6 testability gaps registry is complete.
Post-M6 script inventory guard hardening is complete.
Post-M6 M1 dry-run fail-closed hardening is complete.
Post-M6 runner/validator guard hardening is complete.
Post-M6 dangerous flag negative coverage is complete.
Post-M6 RunnerSafety static gate is complete.
Post-M6 TestDataSafety static gate is complete.
Post-M6 quality gate scope inventory guard is complete.
Post-M6 ProdMatrixSafety static gate is complete.
Post-M6 BacklogSafety static gate is complete.
Post-M6 SyntheticUsersSafety static gate is complete.
Post-M6 ResourceBudgetSafety static gate is complete.
Post-M6 AllowedGamesSafety static gate is complete.
Post-M6 ProdMetadataSafety static gate is complete.
Post-M6 IncidentStopSafety static gate is complete.
Post-M6 QaDocsSafety static gate is complete.
Post-M6 ArtifactPolicySafety static gate is complete.
Post-M6 ContractFixtureSafety static gate is complete.
Post-M6 StaticSurfaceSafety static gate is complete.
Future execution milestones require their own NON_AUTONOMOUS planning step in a separate thread.
```

Current branch:

```text
main
```

Current result:

```text
Local testability gap registry tracks runtime blockers and required evidence without production actions, credentials or runtime user data reads.

Script inventory guard hardening updates `scripts/README.md` and makes the `Context` quality gate fail if any `scripts/*.ps1` runner is undocumented.

M1 dry-run fail-closed hardening makes release and privacy runners reject calls without `-DryRun` before reading artifact roots.

Runner/validator guard hardening makes ProdSafety, AppSmoke, BridgeContract and BackendSmoke fail closed on missing `-DryRun`. AppSmoke and BridgeContract also assert rejection of `-AllowClientLaunch` and `-AllowWebViewDebugPort`.

Dangerous flag negative coverage adds `Full` assertions for UpdateManifest, GameSessionCanary, NonProdFoundation and TestabilityGaps allow-flags.

RunnerSafety static gate adds `Full` coverage for runner dry-run requirements, dangerous allow-switch guards and forbidden runtime/network primitives.

TestDataSafety static gate adds `Full` coverage for risky test fixture content outside explicit unsafe/negative allowlists.

Quality gate scope inventory guard makes `Context` fail if a `quality-gate.ps1 -Scope` value is not documented in `docs/context/engineering/quality-gates.md`.

ProdMatrixSafety static gate adds `Full` coverage for production-safe test matrix classification drift.

BacklogSafety static gate adds `Full` coverage for M0-M6 value/effort backlog drift.

SyntheticUsersSafety, ResourceBudgetSafety, AllowedGamesSafety and ProdMetadataSafety add `Full` coverage for local fixture drift around synthetic aliases, canary game aliases, resource budgets and production test metadata.

IncidentStopSafety adds `Full` coverage for the centralized incident stop trigger vocabulary and testability gap stop-trigger drift.

QaDocsSafety adds `Full` coverage for the required `docs/qa/*.md` policy inventory and core safety phrases.

ArtifactPolicySafety adds `Full` coverage for release/privacy policy fixture drift around required files, forbidden extensions, finding ids, privacy patterns and scan limits.

ContractFixtureSafety adds `Full` coverage for backend, update manifest and WebView bridge fixture drift around dry-run flags, read-only/local-only constraints, package integrity metadata and bridge safety vocabulary.

StaticSurfaceSafety adds `Full` coverage for App/WebView smoke and non-prod foundation fixture drift around static layout, WebView bundle inventory and schema-only non-runtime placeholders.
```

Forbidden without a new approved plan:

- installed client launch;
- WebView debug/CDP port;
- authentication;
- real game session execution;
- production backend or streaming network interaction;
- fake/replay server runtime execution;
- network shaping;
- hardware inspection;
- credentials, secrets, bearer tokens, cookies or session headers;
- reading user AppData, cookies, local DB, logs or crash dumps;
- update/rollback execution;
- CI/CD enablement;
- dependency upgrades;
- weakening ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier.

Stop-and-ask triggers:

- any need to start `rds-client.exe`;
- any need for credentials or synthetic login;
- any need for WebView debug port;
- any need for real backend URL, streaming URL or network calls;
- any need for auth headers, cookies, tokens or secrets;
- any need to read user runtime files;
- any need to execute a fake/replay server, network shaper or hardware probe;
- any need to execute or stop a real game session;
- any production-impacting action;
- scope expansion beyond local dry-run/schema validation.

Last verification:

- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope StaticSurfaceSafety`;
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ActiveRunSafety`;
- `git diff --check`.
