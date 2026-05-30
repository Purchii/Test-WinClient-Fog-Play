# QA strategy

Layered strategy:

1. ProdSafety framework.
2. Git/handoff/verification governance.
3. Release artifact gates.
4. Privacy/logging gates.
5. App launch and WebView smoke.
6. WebView/native bridge contract and fake native host.
7. Safe backend read-only smoke.
8. Minimal game-session canary as PROD_CONDITIONAL.
9. Future non-prod fake/replay/network/hardware regression.

Do not start with broad E2E.
