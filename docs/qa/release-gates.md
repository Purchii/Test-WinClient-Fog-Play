# Release gates

Release gate should check:

- executable signing;
- installer/updater signing;
- no PDB in release package unless explicitly allowed;
- no sourcemaps in production package unless explicitly allowed;
- no local developer paths;
- no secrets;
- no unsafe debug flags;
- version metadata;
- update manifest integrity.

Release gates are valuable because they can run offline without production backend impact.

## M1 implementation

`scripts/run-release-gate.ps1` scans an installed artifact directory without launching the client.

Default artifact path:

```text
C:\Program Files\MTC Fog Play
```

Default policy:

```text
testdata/release-gate-policy.example.json
```

Implemented checks:

- required files exist;
- Authenticode status for configured executables;
- version metadata for configured executables;
- forbidden `.pdb` and `.map` files;
- local developer paths such as `C:\Users\...`;
- source map references;
- unsafe debug flags in text-like files.

Findings are sanitized: the script reports pattern ids, file paths and messages, not matched secret values.

Default behavior is fail-closed: the runner requires `-DryRun`, and fail-severity findings make the script fail unless `-ExpectFindings` is used for a negative fixture or `-ReportOnly` is used for explicit artifact discovery.

M1.1 hardening added:

- negative and clean fixtures;
- executable signature code-path coverage for client, updater, uninstaller and crashpad;
- version metadata code-path coverage;
- large text-like artifact fail findings instead of silent pass;
- unreadable text-like artifact fail findings;
- `quality-gate.ps1` assertions for concrete expected finding ids.

Update manifest hardening added:

- local fixture-based update manifest integrity validation;
- SHA-256, size, signature-required and rollback-disabled checks;
- URL, command and credential rejection;
- dry-run-only runner in `scripts/run-update-manifest-gate.ps1`.

Post-M6 dry-run hardening added:

- `scripts/run-release-gate.ps1` now rejects calls without `-DryRun` before reading the artifact root;
- `quality-gate.ps1 -Scope Release` asserts that missing `-DryRun` is rejected.

Known findings from the installed artifact observed on 2026-05-30:

- `bin/rds-client.exe` reported `NotSigned`;
- `Uninstall.exe` reported `NotSigned`;
- `bin/crashpad_handler.exe` reported `NotSigned`;
- `bin/rds-updater.exe` signature reported `Valid`;
- 8 sourcemap files were present under `bin/resources/**`;
- source map references were present in bundled CSS/JS;
- `bin/installer_info.txt` contained a local user path.

These findings are reported by the gate in dry-run mode. Whether any item is acceptable for release requires explicit owner/product approval before changing policy severity.
