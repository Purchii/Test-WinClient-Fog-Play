# Incident stop policy

Automation must stop before any action that could affect production users, production state, real credentials, runtime user data or cloud-gaming sessions.

Stop-and-ask triggers:

- installed-client-launch
- webview-debug-cdp
- authentication
- synthetic-login
- production-backend-network
- streaming-network
- network-call
- game-session-execution
- runtime-user-data
- credentials
- production-impact
- replay-server-runtime
- network-shaping
- hardware-inspection
- update-rollback-execution
- cicd-enablement
- dependency-upgrade
- guard-weakening
- scope-expansion

Default handling:

- keep the task local and dry-run only;
- do not launch the installed client;
- do not enable WebView debug/CDP;
- do not authenticate;
- do not call production backend or streaming services;
- do not start or stop a real game session;
- do not read user AppData, logs, cookies, databases or dumps;
- do not enable CI/CD or upgrade dependencies.
