# Быстрый старт для Codex: QA automation MTC Fog Play

Ниже — короткая инструкция, как использовать подготовленное ТЗ в Codex.

---

## 1. Что передать Codex

Передай Codex эти файлы:

```text
CODEX_QA_AUTOMATION_TZ_MTC_FOG_PLAY.md
CODEX_MULTIAGENT_GOAL_RULES_MTC_FOG_PLAY.md
CODEX_GOAL_PROMPT_QA_AUTOMATION_MTC_FOG_PLAY.md
```

Если Codex работает локально с репозиторием, положи документы в проект, например:

```text
docs/qa-automation/_incoming/CODEX_QA_AUTOMATION_TZ_MTC_FOG_PLAY.md
docs/qa-automation/_incoming/CODEX_MULTIAGENT_GOAL_RULES_MTC_FOG_PLAY.md
docs/qa-automation/_incoming/CODEX_GOAL_PROMPT_QA_AUTOMATION_MTC_FOG_PLAY.md
```

Или просто приложи их в новый диалог Codex.

---

## 2. Prompt для запуска

Скопируй в новый диалог Codex:

```text
Работаем в мультиагентном goal-mode.

Изучи приложенные документы:
1. CODEX_QA_AUTOMATION_TZ_MTC_FOG_PLAY.md
2. CODEX_MULTIAGENT_GOAL_RULES_MTC_FOG_PLAY.md
3. CODEX_GOAL_PROMPT_QA_AUTOMATION_MTC_FOG_PLAY.md

Задача: начать внедрение QA automation foundation для Windows-клиента MTC Fog Play.

Сначала сделай repository discovery: AGENTS.md, README, docs, CI/CD, frontend/WebView, native C++ bridge, updater, backend/API client, existing tests. Затем дай короткий execution plan и repo map. После этого подтверди или опровергни предварительные находки из ТЗ и приступай к первой итерации.

Главный приоритет первой итерации:
1. release artifact QA gate;
2. production safety policy;
3. bridge contract registry;
4. fake native host / WebView contract harness;
5. первые tests для settings/stream-settings/update/error-connect;
6. update/backend/privacy test plans или scaffolds, если полноценное внедрение заблокировано.

Не запускай destructive/load/chaos/update rollback тесты на production. Unsafe tests должны быть skipped by default. Если staging/mocks/test accounts/Windows runner отсутствуют — не заменяй их production-экспериментами, а создай mock/local основу и зафиксируй blocker.

Финальный ответ дай в формате:
- что изучено;
- что подтверждено/опровергнуто;
- что реализовано;
- какие файлы изменены;
- какие команды запущены;
- результаты тестов;
- blockers;
- следующий backlog.
```

---

## 3. Что попросить Codex сделать первым

Первая команда после discovery:

```text
Сначала не меняй код. Составь repo map, найди места для WebView, native bridge, updater, packaging, CI и existing tests. Затем покажи план первой итерации максимум на 10 пунктов и только после этого начинай изменения.
```

Вторая команда, если план ок:

```text
Приступай к Sprint 0 из ТЗ: docs/qa-automation, artifact gate scaffold, bridge-contract.yaml, fake native host scaffold, первые WebView contract tests или структура под них. Все production-unsafe проверки должны быть skipped by default.
```

---

## 4. Как оценивать результат Codex

Хороший результат:

```text
Codex не пытается сразу сделать огромный E2E;
сначала строит foundation;
делает документы и тестовые scaffolds;
добавляет artifact gate;
формализует bridge contract;
создает fake native host;
фиксирует blockers;
запускает доступные проверки;
честно пишет, что не запустилось.
```

Плохой результат:

```text
сразу лезет в production;
начинает load/chaos/update rollback без staging;
пишет только теорию, без файлов;
создает flaky UI-тесты через sleep;
игнорирует bridge contract;
не проверяет релизный package;
скрывает failing tests;
не читает AGENTS.md.
```

---

## 5. Короткая версия цели

```text
Нам нужен не набор случайных автотестов, а QA automation foundation для cloud gaming Windows client:
release safety + bridge contracts + update safety + backend contracts + product playability path.
```
