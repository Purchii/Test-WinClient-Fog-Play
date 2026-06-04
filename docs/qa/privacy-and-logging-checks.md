# Privacy and logging checks

Check that logs/artifacts do not contain:

- access tokens;
- refresh tokens;
- passwords;
- full session tokens;
- real user identifiers;
- production secrets;
- sensitive backend URLs if classified as secret;
- unmasked SDP/TURN/ICE credentials if present in diagnostics.

## M1 implementation

`scripts/run-privacy-gate.ps1` scans text-like files in an artifact directory without launching the client.

Default artifact path:

```text
C:\Program Files\MTC Fog Play
```

This default is for a separate manual/explicit-plan artifact read only. Current autonomous verification must use committed local fixtures; reading the installed artifact requires a separate approved plan.

Default pattern config:

```text
testdata/privacy-patterns.example.json
```

Implemented checks:

- access token patterns;
- refresh token patterns;
- password/passwd assignments with non-empty secret-like values;
- authorization bearer tokens;
- generic `token=` assignments;
- API key patterns;
- private key blocks;
- local developer paths;
- TURN/ICE/STUN credential-like diagnostics.

Findings are sanitized: the script reports pattern id, severity, relative path and line number only.

Default behavior is fail-closed: the runner requires `-DryRun`, and fail-severity findings make the script fail unless `-ExpectFindings` is used for a negative fixture or `-ReportOnly` is used for explicit artifact discovery.

M1.1 hardening added:

- negative and clean fixtures;
- access token, refresh token, bearer token, generic token, API key, private key, TURN credential and unquoted password coverage;
- large text-like artifact fail findings instead of silent pass;
- unreadable text-like artifact fail findings;
- `quality-gate.ps1` assertions for concrete expected finding ids.

Post-M6 dry-run hardening added:

- `scripts/run-privacy-gate.ps1` now rejects calls without `-DryRun` before reading the artifact root;
- `quality-gate.ps1 -Scope Privacy` asserts that missing `-DryRun` is rejected.

Post-M6 runner input path hardening added:

- `scripts/run-privacy-gate.ps1` rejects AppData/log/cookie/DB/dump-like `ArtifactRoot` and `PatternsPath` overrides before reading or probing them;
- `quality-gate.ps1 -Scope Privacy` asserts that unsafe runtime artifact roots and pattern config paths are rejected without touching those paths.

Post-M6 report-only coverage hardening added:

- `quality-gate.ps1 -Scope Privacy` asserts that local installed-like, negative and large fixtures keep `-ReportOnly` explicit artifact discovery behavior and concrete finding ids without reading installed artifacts.

Known finding from the installed artifact observed on 2026-05-30:

- `bin/installer_info.txt` contained a local user path.

The scanner intentionally avoids treating every occurrence of the word `password` as a secret because UI bundles can contain field names and labels.
