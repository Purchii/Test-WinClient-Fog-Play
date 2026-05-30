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
