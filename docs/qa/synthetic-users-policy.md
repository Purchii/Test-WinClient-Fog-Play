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

Committed allowlist fixtures must stay alias-only. They may describe synthetic aliases, purpose, allowed environments and bounded game-session permission, but must not contain usernames, emails, phone numbers, passwords, tokens, cookies, auth headers, URLs or user runtime paths. Canary synthetic user game-session duration must not exceed the committed resource budget.
