# Testability gaps

The testability gaps registry tracks what still blocks runtime or higher-fidelity QA automation.

Default policy:

```text
testdata/testability-gaps.example.json
```

The registry is intentionally dry-run and local. It does not close gaps by launching the client, enabling WebView debug/CDP, authenticating, starting sessions, reading runtime user data or calling production services.

Implemented checks:

- runner and direct validator invocation require `-DryRun`;
- runner policy path overrides reject AppData/log/cookie/DB/dump-like runtime paths before reading;
- production execution, runtime user data reads and credentials are disabled;
- gaps must use stable `GAP-###` ids;
- gaps must use approved areas and statuses;
- open runtime gaps must not be marked production-safe;
- gaps must not require credentials or user runtime data;
- gaps must list approved evidence needed to close them;
- gaps must list stop-and-ask triggers;
- gaps must list a safe next step.

Runner:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-testability-gaps.ps1 -DryRun
```

Known limitation:

- This registry proves that gaps are tracked and safety-scoped. It does not provide the missing client source, non-production environments, synthetic auth fixtures or runtime harnesses.

Post-M6 guard hardening added `TestabilityGaps` quality gate assertions that unsafe runtime input paths, `-AllowProductionAction`, `-AllowCredentials` and `-AllowRuntimeUserData` are rejected before any production action, credential use or runtime user data read can occur.
