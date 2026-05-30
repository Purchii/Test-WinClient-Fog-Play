# Scripts

Implemented in M0:

```text
quality-gate.ps1
run-prod-safe-smoke.ps1
run-prod-canary.ps1
run-release-gate.ps1
run-privacy-gate.ps1
run-app-webview-smoke.ps1
```

Planned for later milestones:

```text
collect-artifacts.ps1
reset-test-env.ps1
```

M0/M1/M2 scripts are guard/dry-run first. They do not launch the Windows client, authenticate, start a game session, mutate production state or read user AppData logs/cookies/DB files by default.

Use `powershell -NoProfile -ExecutionPolicy Bypass -File ...` on machines where local script execution is restricted by PowerShell policy.
