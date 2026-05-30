# Synthetic users policy

Production tests must use only allowlisted synthetic accounts.

Forbidden:

- real user accounts;
- personal employee accounts;
- temporary manual accounts without allowlist;
- hardcoded credentials;
- credentials in commit history;
- printing tokens/passwords to logs.

Credentials must come from secure CI secrets, environment variables or local secure config ignored by git.
