# MTC Fog Play Codex Updated Starter Package

Этот пакет содержит итоговое ТЗ и инструкцию для запуска Codex в проекте QA automation Windows-клиента облачного гейминга.

Главная идея:

```text
Сначала ProdSafety + Git/Handoff/Verification governance, потом широкие E2E.


Режимы работы Codex:

```text
Discovery/plan: NON_AUTONOMOUS.
Implementation after accepted plan: BOUNDED_AUTONOMOUS within approved scope.
Production impact and merge to main: NON_AUTONOMOUS.
```
```

## Главные файлы

```text
CODEX_FINAL_TZ_WINCLIENT_QA_AUTOMATION.md
CODEX_START_INSTRUCTION.md
CODEX_FIRST_GOAL_PROMPT.md
CODEX_AUTONOMY_MODES_INTEGRATION.md
AGENTS.md
```

## Что делать

1. Распаковать пакет в корень репозитория или отдельный automation repo.
2. Проверить, что `AGENTS.md` лежит в корне.
3. Открыть новый диалог Codex.
4. Скопировать `CODEX_FIRST_GOAL_PROMPT.md`.
5. Дождаться repo map и плана в NON_AUTONOMOUS режиме.
6. После принятия плана разрешить bounded autonomous execution только для M0: ProdSafety + Git/Handoff/Verification governance foundation.

## Не начинать с

```text
реальных game-session tests;
load/stress/chaos/destructive tests;
update rollback на production;
широких E2E без classification;
работы напрямую в main;
автоматического merge в main.
```

## Важное уточнение про план

Перед автономной работой Codex сам составляет план в `NON_AUTONOMOUS` режиме.
Но он должен делать не полный detailed plan всего проекта, а:

```text
M0-M6 = high-level roadmap.
Текущий milestone = detailed technical implementation plan.
```

Для старта проекта текущий milestone — `M0`.
После принятия M0-плана Codex может работать в `BOUNDED_AUTONOMOUS` режиме только внутри M0 scope.
