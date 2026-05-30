# Verification memory

## Template

```md
## YYYY-MM-DD — [goal]

Branch: [branch]
Status: passed / failed / blocked
Production impact: none / dry-run / PROD_SAFE / PROD_CONDITIONAL

Commands:
- ...

Results:
- ...

Not run:
- ... because ...

Safety notes:
- No real credentials committed.
- No production game session started.
- No unsafe test enabled.
```

## 2026-05-30 - M0 ProdSafety foundation

Branch: `codex/prod-safety-foundation`
Status: passed
Production impact: dry-run only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ProdSafety`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-prod-safe-smoke.ps1 -Environment production -DryRun`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-prod-canary.ps1 -Environment production -DryRun -ExpectFailure`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-prod-canary.ps1 -Environment production -DryRun -AllowProdConditional -CleanupVerified`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\ProdSafety\ProdSafety.Tests.ps1`
- `git diff --check`
- `git status --short --branch`

Results:
- Context gate passed.
- ProdSafety gate passed.
- Unclassified and `PROD_FORBIDDEN` rejection behavior is covered by `ProdSafety.Tests.ps1`.
- `PROD_CONDITIONAL` without explicit flag was rejected as expected.
- `PROD_CONDITIONAL` dry-run passed only with explicit flag, resource budget, synthetic user and cleanup verification.
- `git diff --check` passed with line-ending warnings only.

Not run:
- Client build/app launch because Windows client source is not present yet.
- Real production smoke/canary because M0 is dry-run only and no production-impacting action is allowed.
- CI because no CI configuration exists yet and enabling CI/CD is outside M0.

Safety notes:
- No real credentials committed.
- No production game session started.
- No unsafe test enabled.
- No push or merge to `main` performed.

## 2026-05-30 - M1 Release artifact and privacy gates

Branch: `codex/release-privacy-gates`
Status: passed for implementation; installed artifact has reported release/privacy findings
Production impact: offline artifact scan only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ProdSafety`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Release`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Privacy`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-release-gate.ps1 -ArtifactRoot "C:\Program Files\MTC Fog Play" -DryRun`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-privacy-gate.ps1 -ArtifactRoot "C:\Program Files\MTC Fog Play" -DryRun`
- `git diff --check`
- `git status --short --branch`

Results:
- Context gate passed.
- ProdSafety regression gate passed.
- Release fixture gate passed by detecting expected findings.
- Privacy fixture gate passed by detecting expected findings.
- Installed artifact release dry-run scanned 193 files and reported fail findings:
  - `bin/rds-client.exe` signature status `NotSigned`;
  - `Uninstall.exe` signature status `NotSigned`;
  - 8 `.map` sourcemap files;
  - source map references in bundled CSS/JS;
  - local user path in `bin/installer_info.txt`.
- Installed artifact privacy dry-run scanned 30 text-like files and reported local user path in `bin/installer_info.txt`.
- Findings are sanitized; matched secret values are not printed.
- `git diff --check` passed with line-ending warnings only.

Not run:
- Client launch because M1 is offline artifact scanning only.
- Auth/login/game-session checks because they are out of M1 scope.
- CI because CI/CD enablement is out of M1 scope.

Safety notes:
- No real credentials used.
- No production game session started.
- No client process launched.
- No real logs, crash dumps, installers or release binaries copied into repo.
- No commit or push performed during M1 without explicit approval.

## 2026-05-30 - M1.1 Quality hardening after multi-agent audit

Branch: `codex/release-privacy-gates`
Status: in progress; local verification passed before final review
Production impact: offline artifact scan only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ProdSafety`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Release`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Privacy`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-release-gate.ps1 -ArtifactRoot .\testdata\release-fixture -PolicyPath .\testdata\release-gate-policy.example.json -DryRun`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-privacy-gate.ps1 -ArtifactRoot .\testdata\privacy-negative-fixture -PatternsPath .\testdata\privacy-patterns.example.json -DryRun`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-release-gate.ps1 -ArtifactRoot "C:\Program Files\MTC Fog Play" -DryRun -ReportOnly`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-privacy-gate.ps1 -ArtifactRoot "C:\Program Files\MTC Fog Play" -DryRun -ReportOnly`

Results:
- Context, ProdSafety, Release, Privacy and Full quality gates passed.
- ProdSafety regression coverage includes disallowed target region/game rejection.
- Release negative fixture failed closed without `-ExpectFindings`.
- Privacy negative fixture failed closed without `-ExpectFindings`.
- Release installed artifact report-only scan reported fail findings: unsigned `rds-client.exe`, `Uninstall.exe`, `crashpad_handler.exe`, sourcemaps, source map references and local user path.
- Privacy installed artifact report-only scan reported local user path only after password-pattern false positives were narrowed.

Not run:
- Client launch because M1.1 is offline hardening only.
- Auth/login/game-session checks because they are out of scope.
- CI because CI/CD enablement is out of scope.

Safety notes:
- No real credentials used.
- No production game session started.
- No client process launched.
- No user AppData logs, cookies or DB files read.

## 2026-05-30 - M2 App/WebView smoke scaffold

Branch: `codex/app-webview-smoke`
Status: in progress; local AppSmoke verification passed
Production impact: dry-run/static artifact scan only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\WindowsSmoke\WindowsSmoke.Tests.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope ProdSafety`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Release`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Privacy`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope AppSmoke`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-app-webview-smoke.ps1 -ArtifactRoot "C:\Program Files\MTC Fog Play" -DryRun -ReportOnly`
- `git diff --check`
- `git status --short --branch`

Results:
- WindowsSmoke unit tests passed.
- Context, ProdSafety, Release, Privacy and Full quality gates passed.
- AppSmoke quality gate passed.
- Installed artifact static App/WebView smoke passed and reported `processStarted=false`, `debugPortUsed=false`, `authAttempted=false`, `gameSessionStarted=false`.
- `git diff --check` passed with line-ending warnings only.

Not run:
- Client launch because M2 is static/dry-run only.
- WebView runtime rendering because debug/CDP and client launch are out of scope.
- Auth/login/game-session checks because they are forbidden in M2.

Safety notes:
- No real credentials used.
- No production game session started.
- No client process launched.
- No user AppData logs, cookies or DB files read.
- No WebView debug port enabled.

## 2026-05-30 - M5 Minimal game-session canary readiness gate

Branch: `codex/m5-game-session-canary`
Status: passed
Production impact: dry-run/local readiness validation only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\GameSessionCanary\GameSessionCanary.Tests.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope GameSessionCanary`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`
- `git diff --check`

Results:
- GameSessionCanary unit tests passed.
- GameSessionCanary quality gate passed.
- Context quality gate passed.
- Full quality gate passed, including ProdSafety, Release, Privacy, AppSmoke, BridgeContract, BackendSmoke and GameSessionCanary.
- GameSessionCanary quality gate verifies `PROD_CONDITIONAL` rejection without explicit `-AllowProdConditional`.
- Unsafe M5 fixture reports fail findings for non-dry-run policy, real execution/client/network/auth enablement, runtime user path, wrong classification, missing cleanup, oversized duration, non-allowlisted game, retries and missing first-frame readiness signal.
- `git diff --check` passed with line-ending warnings only.

Not run:
- Installed client launch because M5 is a dry-run readiness validator only.
- WebView debug/CDP because it is forbidden in M5.
- Authentication or real synthetic login because credentials/auth are forbidden in M5.
- Production backend or streaming network calls because M5 is local/offline only.
- Real game-session start/stop and cleanup because M5 does not execute sessions.

Safety notes:
- No real credentials used.
- No production backend interaction.
- No production game session started.
- No client process launched.
- No user AppData logs, cookies, DB or dumps read.
- No WebView debug port enabled.

## 2026-05-30 - M4 Safe backend smoke

Branch: `codex/m4-backend-smoke`
Status: passed
Production impact: dry-run/local contract only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\BackendSmoke\BackendSmoke.Tests.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope BackendSmoke`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Full`
- `git diff --check`
- `git status --short --branch`

Results:
- BackendSmoke unit tests passed.
- BackendSmoke quality gate passed.
- Context quality gate passed.
- Full quality gate passed, including ProdSafety, Release, Privacy, AppSmoke, BridgeContract and BackendSmoke.
- `git diff --check` passed with line-ending warnings only.

Not run:
- Real backend network calls because M4 is local contract/fake-response dry-run only.
- Auth/login checks because synthetic-user backend auth requires a separate approval.
- Game-session checks because they are forbidden until the M5 canary plan is approved.

Safety notes:
- No real credentials used.
- No production backend interaction.
- No production game session started.
- No client process launched.
- No user AppData logs, cookies or DB files read.

## 2026-05-30 - M3 WebView/native bridge contract

Branch: `codex/m3-webview-bridge-contract`
Status: passed
Production impact: dry-run/local contract only

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\src\TestFramework\WebViewBridge\WebViewBridge.Tests.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope BridgeContract`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `git diff --check`
- `git status --short --branch`

Results:
- WebViewBridge unit tests passed.
- BridgeContract quality gate passed.
- Context quality gate passed.
- Full quality gate passed, including ProdSafety, Release, Privacy, AppSmoke and BridgeContract.
- `git diff --check` passed with line-ending warnings only.

Not run:
- Client launch because M3 is local contract/fake-host dry-run only.
- WebView runtime rendering because debug/CDP and client launch are out of scope.
- Auth/login/game-session checks because they are forbidden in M3.

Safety notes:
- No real credentials used.
- No production game session started.
- No client process launched.
- No user AppData logs, cookies or DB files read.
- No WebView debug port enabled.

## 2026-05-30 - Thread lifecycle governance correction

Branch: `codex/thread-lifecycle-governance`
Status: passed
Production impact: none; documentation-only correction

Commands:
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\quality-gate.ps1 -Scope Context`
- `git diff --check`
- `git status --short --branch`

Results:
- Context gate passed.
- `git diff --check` passed with line-ending warnings only.
- Working branch contains documentation-only governance changes.

Process note:
- `PROCESS_ERROR_THREAD_REUSE` recorded because M3 work began to continue in the previous long-running thread context.
- M3 implementation must resume in a separate M3 task thread.
- New independent tasks must use `create_thread` first.
- Codex worktrees are reserved for follow-on tasks that need isolated branch/workspace state.
- Unusable thread attempts must be marked inactive/orphan, then normal `create_thread` retried once before worktree fallback.
- M3 retry `019e7907-e739-7213-a690-125ea2fbafeb` accepted a follow-up message; incomplete attempt `019e7902-70cb-7f31-8487-907e53f1fc45` is inactive/orphan.

Safety notes:
- No real credentials used.
- No production game session started.
- No client process launched.
- No user AppData logs, cookies or DB files read.
- No WebView debug port enabled.
