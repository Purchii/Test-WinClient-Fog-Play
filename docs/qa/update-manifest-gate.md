# Update manifest gate

The update manifest gate validates local manifest policy fixtures without downloading packages, starting the updater or executing rollback.

Default policy:

```text
testdata/update-manifest.example.json
```

Implemented checks:

- runner and direct validator invocation require `-DryRun`;
- network, updater execution, rollback and credentials are disabled;
- real endpoints and executable commands are rejected;
- packages must have stable ids;
- package versions must be explicit semantic-like values;
- artifact paths must be local relative paths, not URLs or absolute paths;
- package hashes must be 64-character SHA-256 hex digests;
- package sizes must be positive;
- signatures must be required;
- rollback and post-install commands are rejected.

Safety defaults:

- no manifest or package download is attempted;
- no updater, installer or rollback command is started;
- no credentials are used;
- no installed client is launched;
- no production backend is contacted.

Runner:

```text
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run-update-manifest-gate.ps1 -DryRun
```

Known limitation:

- This gate proves local manifest shape only. It does not validate a real vendor manifest, package signature chain or updater runtime behavior until updater/package metadata is provided through an approved offline fixture.

Post-M6 guard hardening added `UpdateManifest` quality gate assertions that `-AllowNetwork`, `-AllowExecution`, `-AllowRollback` and `-AllowCredentials` are rejected before any download, updater, rollback or credential action can occur.
