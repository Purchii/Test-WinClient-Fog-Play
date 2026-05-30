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
