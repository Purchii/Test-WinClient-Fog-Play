# Artifacts policy

Each run should capture:

- timestamp;
- environment;
- app version/build SHA;
- test classification;
- synthetic account alias, not password/token;
- logs;
- screenshots on failure;
- crash dumps if available;
- exit codes;
- cleanup result.

Do not publish unsanitized logs, tokens, credentials, full session ids or real user data.

Repository fixtures are checked by `TestDataSafety`: secret-like values, bearer tokens, runtime user paths and non-placeholder URLs must stay in explicit unsafe/negative fixtures only.
