# Короткий prompt для Codex goal-mode

```text
Ты работаешь в существующем проекте MTC Fog Play как мультиагентная команда QA automation / testability / release engineering.

Контекст: Windows-приложение на C++ с WebView/CEF внутри, продукт — облачный гейминг. Мне важны не только backend-ошибки, но и пользовательский опыт на ключевых бизнес-сценариях: запуск клиента, старт игровой сессии, первый кадр, ввод, качество стрима, reconnect, понятные ошибки и безопасное обновление.

Главная цель: спроектировать и начать внедрение многоуровневой QA automation: release artifact gates, WebView↔native bridge contract tests, update tests, backend/API contract tests, Windows smoke, playability E2E, network degradation, hardware/decoder matrix и privacy/logging checks.

Работай в мультиагентном goal-mode. Роли: Coordinator, QA Automation Architect, WebView/Frontend Test Agent, Native Windows/C++ Agent, Backend/API Contract Agent, DevOps/Release Engineering Agent, Security/Privacy QA Agent, Reviewer/Red Team Agent.

Сначала изучи репозиторий: AGENTS.md, docs, build/CI, frontend/WebView, native C++ bridge, updater, backend/API clients, existing tests. Затем составь краткий execution plan и repo map. После этого подтверди или опровергни предварительные QA-находки из приложенного ТЗ.

Приоритет первой итерации:
1. release artifact QA gate;
2. быстрые WebView/bridge bug checks и фиксы;
3. bridge contract registry;
4. fake native host + WebView contract tests;
5. update integrity/rollback test plan;
6. production-safe backend contract smoke.

Production safety: сейчас тестирование завязано на production. Не запускай load/stress/chaos/destructive/update rollback тесты на production. Unsafe tests должны быть skipped by default. Если staging/mocks отсутствуют — реализуй mock/local основу и зафиксируй blocker.

Ожидаемые артефакты первой поставки:
- docs/qa-automation/README.md
- docs/qa-automation/test-strategy.md
- docs/qa-automation/risk-register.md
- docs/qa-automation/backlog.md
- docs/qa-automation/bridge-contract.yaml
- qa/artifact-gate/*
- qa/webview-contract/*
- первые тесты для settings/stream-settings/update/error-connect
- итоговый отчет: что изучено, что подтверждено, что реализовано, какие тесты запущены, что заблокировано.

Используй модель приоритизации:
Priority = (2 * User Value + 2 * Risk Reduction + Frequency + Observability Gain + Testability Gain) / Effort.
```
```
