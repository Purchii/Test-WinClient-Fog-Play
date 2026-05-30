# Prod-safe test matrix

| Scenario | Classification | Notes |
|---|---|---|
| App launch | PROD_SAFE | No auth/session required |
| Main window visible | PROD_SAFE | Black-box/native UI |
| WebView ready | PROD_SAFE | No debug port unless safe diagnostic mode |
| Login/logout synthetic user | PROD_SAFE | Requires SyntheticUserGuard |
| Catalog read-only | PROD_SAFE | No game start |
| Open game card read-only | PROD_SAFE | CTA visible only |
| Release artifact signing | PROD_SAFE | Offline gate |
| Privacy/log scanner | PROD_SAFE | Offline/safe gate |
| One short game session canary | PROD_CONDITIONAL | Requires explicit flag/budget/cleanup |
| Reconnect smoke | PROD_CONDITIONAL | Short, allowlisted only |
| Update rollback | PROD_FORBIDDEN on production | NON_PROD_ONLY |
| Load/stress | PROD_FORBIDDEN | NON_PROD_ONLY |
| Network chaos | PROD_FORBIDDEN on production | NON_PROD_ONLY |
| Destructive cleanup | PROD_FORBIDDEN | NON_PROD_ONLY |
