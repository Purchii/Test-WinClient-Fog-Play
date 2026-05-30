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

Default pattern config:

```text
testdata/privacy-patterns.example.json
```

Implemented checks:

- access token patterns;
- refresh token patterns;
- password/passwd assignments with non-empty secret-like values;
- API key patterns;
- private key blocks;
- local developer paths;
- TURN/ICE/STUN credential-like diagnostics.

Findings are sanitized: the script reports pattern id, severity, relative path and line number only.

Known finding from the installed artifact observed on 2026-05-30:

- `bin/installer_info.txt` contained a local user path.

The scanner intentionally avoids treating every occurrence of the word `password` as a secret because UI bundles can contain field names and labels.
