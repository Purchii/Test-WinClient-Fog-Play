# Инструкция: как начать проект с Codex

Этот документ — короткая практическая инструкция. Его можно открыть перед первым запуском Codex.

---

## 1. Что сделать с пакетом

1. Распакуй пакет в корень репозитория Windows-клиента или в отдельный репозиторий автоматизации.
2. Убедись, что в корне появился `AGENTS.md`.
3. Убедись, что есть папки:

```text
docs/context/
docs/qa/
docs/codex/
testdata/
scripts/
```

4. Открой новый диалог Codex.
5. Передай Codex содержимое проекта и скажи, что source of truth — файлы в репозитории, а не старый чат.
6. Вставь prompt из `CODEX_FIRST_GOAL_PROMPT.md`.

---

## 2. Что Codex должен сделать первым

Первый milestone:

```text
M0: ProdSafety + Git/Handoff/Verification + Autonomy Modes foundation.
```

Не проси Codex сразу автоматизировать всё приложение. Первый результат должен быть guard layer и правила работы.

Режим работы:

```text
Первый ответ / discovery / plan: NON_AUTONOMOUS.
После принятия детального плана текущего milestone: BOUNDED_AUTONOMOUS только внутри M0 scope.
Любое production-impacting действие: снова NON_AUTONOMOUS.
Merge в main: только по явному разрешению.
```

Правильная первая задача:

```text
Implement production-safe QA automation guard foundation.
```

Неправильная первая задача:

```text
Напиши E2E тесты запуска игры на production.
```

---

## 3. Что означает “план” перед автономным режимом

Codex должен сам составить план, но не огромный detailed plan всего проекта.

Правильная граница:

```text
Весь проект = high-level roadmap.
Текущий milestone = detailed technical implementation plan.
Реализация = только после принятия плана текущего milestone.
```

В первом `NON_AUTONOMOUS` ответе Codex должен дать:

```text
1. repo map;
2. подтверждённые факты;
3. assumptions/blockers;
4. high-level roadmap M0-M6;
5. детальный технический план M0;
6. allowed files/paths для M0;
7. forbidden actions для M0;
8. acceptance criteria для M0;
9. verification commands для M0;
10. stop-and-ask triggers;
11. запрос на подтверждение плана.
```

Codex не должен детально планировать и тем более реализовывать будущие milestones M1-M6, пока для них не будет отдельного `NON_AUTONOMOUS` planning step.

---

## 4. Что Codex должен показать в первом ответе

Codex не должен сразу менять код. Сначала он должен дать:

```text
repo map;
найденные frontend/WebView/native/backend/update/release зоны;
существующие тесты/CI;
предлагаемую ветку;
production risks;
high-level roadmap M0-M6;
детальный план M0;
acceptance criteria M0;
verification commands M0;
что он не будет делать в M0.
```

После этого можно ответить:

```text
План принимаю. Приступай только к M0: ProdSafety + Git/Handoff/Verification + Autonomy Modes foundation.
Не добавляй game-session tests.
Не запускай production-impacting tests.
Работай в bounded autonomous mode только внутри M0 scope после принятия плана.
Не merge-ь main без моего явного разрешения.
После реализации покажи changed files, commands, verification result, blockers и next steps.
```

---

## 5. Контрольные правила для тебя

Перед тем как разрешить Codex писать код, проверь:

```text
создал/предложил task branch;
не работает напрямую в main;
прочитал AGENTS.md и docs/context;
понял, что production-sensitive;
дал roadmap M0-M6 только верхнеуровнево;
дал детальный план только для M0;
не собирается добавлять game-session tests в M0;
не собирается хардкодить credentials;
не собирается включать WebView debug port в production по умолчанию;
указал verification commands;
указал execution mode;
понимает, что первый план неавтономный;
понимает, что автономность разрешена только после принятия плана и только внутри M0 scope;
перечислил stop-and-ask triggers.
```

---

## 6. Когда M0 можно считать выполненным

M0 готов, когда Codex доказал:

```text
unclassified tests блокируются на production;
PROD_FORBIDDEN блокируются на production;
PROD_CONDITIONAL требуют explicit flag;
kill switch работает;
synthetic user allowlist example есть;
resource budget example есть;
cleanup verifier skeleton есть;
Git workflow зафиксирован;
active-run/verification-memory/session-log обновляются;
autonomy mode зафиксирован в active-run;
никакие production game sessions не запускались.
```

---

## 7. Второй milestone после M0

После M0 следующий prompt:

```text
/goal Implement release artifact and privacy gates.

Use existing ProdSafety foundation.
Do not add game-session tests.
Start in NON_AUTONOMOUS planning mode.
Produce high-level project context refresh and detailed M1 plan only.
Implement release artifact checks for signing, sourcemaps/PDB, local paths, secrets and unsafe configs after the M1 plan is accepted.
Implement privacy/logging scanner skeleton for tokens, passwords, session tokens, real user identifiers and unsafe logs.
Add or update scripts/run-release-gate.ps1 and scripts/quality-gate.ps1 -Scope Release -Scope Privacy.
Run verification on available local artifact or document blocker.
Update verification-memory.md and active-run.md.
Do not merge to main without explicit approval.
```

---

## 8. Когда можно переходить к game-session canary

Только после того, как есть:

```text
ProdGuard;
SyntheticUserGuard;
ResourceBudget;
KillSwitch;
CleanupVerifier;
artifact collector;
log sanitizer;
synthetic account allowlist;
allowlisted game;
explicit human approval;
script requiring -AllowProdConditional.
```

Game-session canary всегда `PROD_CONDITIONAL`, не `PROD_SAFE`.
