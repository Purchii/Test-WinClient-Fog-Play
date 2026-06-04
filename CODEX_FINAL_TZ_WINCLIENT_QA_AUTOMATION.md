# Итоговое ТЗ для Codex

# Проект: QA automation для Windows-клиента MTC Fog Play

Дата: 30 мая 2026  
Назначение: стартовый документ для Codex, работающего в multi-agent + goal mode.  
Цель: организовать безопасный, управляемый и расширяемый проект автоматизации тестирования Windows-клиента облачного гейминга.

---

## 0. Краткая суть

Мы автоматизируем тестирование Windows desktop client для облачного гейминга.

Известный контекст:

- приложение — Windows-клиент;
- нативный слой — C++;
- внутри есть embedded WebView/CEF/WebView-like слой;
- продуктовая цель — облачный гейминг;
- важны не только backend/API проверки, но и пользовательский опыт в основных бизнес-сценариях;
- текущая рабочая модель допускает запуск части автоматизации на production;
- Codex будет использоваться как coding agent в multi-agent + goal mode.

Главный принцип:

```text
Сначала безопасность и управляемость автоматизации, потом широкие E2E.
```

Неправильный старт:

```text
Сразу написать 50 UI/E2E тестов, которые могут создавать production-сессии без guard-слоя.
```

Правильный старт:

```text
1. Production-safety foundation.
2. Git/handoff/verification governance.
3. Release/privacy gates.
4. App/WebView smoke.
5. Bridge contract/fake host.
6. Только потом минимальный PROD_CONDITIONAL game-session canary.
```

---

## 1. Source of truth

Codex должен считать источником истины только репозиторий и актуальные документы в нём.

Source of truth:

```text
AGENTS.md
docs/context/**
docs/qa/**
docs/codex/**
текущий код проекта
текущий git diff
```

Не source of truth:

```text
старый чат;
сжатый контекст;
память модели;
устные договорённости, не перенесённые в docs;
предположения Codex без проверки в репозитории.
```

Правило:

```text
Если важное решение существует только в чате, Codex сначала должен перенести его в docs/context/governance/decisions-log.md или active-run.md, а уже потом опираться на него.
```

---

## 1.5. Режимы автономности Codex

Из Android-документации нужно перенести не только Git/handoff discipline, но и явное разделение режимов работы Codex:

```text
NON_AUTONOMOUS / supervised mode
BOUNDED_AUTONOMOUS mode
```

### 1.5.1. NON_AUTONOMOUS / supervised mode

В этом режиме Codex обязан останавливаться на контрольных точках и ждать разрешения пользователя.

Это режим по умолчанию для:

- первичного discovery и плана;
- неясного scope;
- production-impacting задач;
- `PROD_CONDITIONAL` тестов;
- любых действий, способных создать игровую сессию;
- изменений CI/CD, которые могут автоматически запускать production tests;
- credentials/secrets/auth/synthetic-user конфигурации;
- dependency upgrades;
- изменений ProdGuard, KillSwitch, ResourceBudget, CleanupVerifier;
- commit/push, если prompt явно этого не разрешил;
- merge в `main`.

### 1.5.2. BOUNDED_AUTONOMOUS mode

Codex может работать автономно только внутри заранее согласованного bounded goal.

Условия:

```text
план принят пользователем;
scope понятен;
allowed/forbidden actions понятны;
acceptance criteria есть;
verification commands есть;
используется task branch;
нет production-impact без отдельного разрешения;
нет реальных credentials;
нет production game session;
нет merge в main.
```

В bounded autonomous mode Codex может сам выполнять мелкие шаги реализации, запускать локальные/dry-run проверки, чинить проверки внутри scope и обновлять handoff/verification-memory.

Но Codex обязан остановиться и спросить перед:

```text
расширением scope;
production-impacting action;
запуском PROD_CONDITIONAL;
использованием credentials/secrets;
изменением CI/CD;
ослаблением ProdGuard/KillSwitch/ResourceBudget/CleanupVerifier;
commit/push, если не разрешено;
merge в main.
```

Для первого milestone рекомендуется:

```text
M0 discovery and plan: NON_AUTONOMOUS.
M0 implementation after accepted plan: BOUNDED_AUTONOMOUS внутри M0 scope.
Any production-impacting action: NON_AUTONOMOUS.
Merge to main: NON_AUTONOMOUS + explicit approval.
```

Подробная политика: `docs/codex/autonomy-modes.md`.



## 1.6. Правило планирования milestones

`NON_AUTONOMOUS` режим перед автономной работой нужен для того, чтобы Codex сам составил технический план, но граница плана должна быть строгой:

```text
Весь проект = high-level roadmap.
Текущий milestone = detailed technical implementation plan.
Будущие milestones = high-level до их собственного NON_AUTONOMOUS planning step.
```

В первом ответе Codex должен сделать:

1. `repo map`;
2. список подтверждённых фактов;
3. список assumptions/blockers;
4. high-level roadmap `M0-M6`;
5. детальный технический план текущего milestone `M0`;
6. exact allowed file changes для `M0`;
7. forbidden actions для `M0`;
8. acceptance criteria для `M0`;
9. verification commands для `M0`;
10. stop-and-ask triggers;
11. запрос на подтверждение плана.

Codex не должен детально планировать и реализовывать весь проект сразу. Детальный план будущих milestones делается только при переходе к соответствующему milestone.

После принятия детального плана текущего milestone Codex может перейти в `BOUNDED_AUTONOMOUS` mode только внутри утверждённого scope.

Для старта проекта:

```text
M0-M6 = roadmap.
M0 = detailed technical plan.
M0 implementation = только после acceptance пользователя.
```

Подробная политика: `docs/codex/milestone-planning-policy.md`.

---

## 2. Production-safety правила

Codex должен считать, что любой тест потенциально может быть запущен на production, если явно не указано обратное.

Обязательные правила:

```text
No classification = no prod run.
No synthetic user guard = no prod auth test.
No resource budget = no prod game session test.
No cleanup verification = no prod state mutation test.
No explicit canary flag = no PROD_CONDITIONAL run.
```

Каждый тест должен иметь classification:

```text
PROD_SAFE
PROD_CONDITIONAL
PROD_FORBIDDEN
NON_PROD_ONLY
```

### 2.1. PROD_SAFE

Можно запускать на production автоматически при выполнении базовых guard-условий.

Примеры:

- запуск приложения;
- проверка главного окна;
- проверка, что WebView отображается;
- login/logout synthetic user;
- загрузка каталога read-only;
- открытие карточки игры без старта сессии;
- отсутствие crash;
- отсутствие критичных ошибок в логах;
- release artifact checks;
- privacy/logging gates.

### 2.2. PROD_CONDITIONAL

Можно запускать на production только с явным разрешением и ограничениями.

Примеры:

- создание одной короткой игровой сессии;
- start stream;
- stream ready / first frame;
- короткая проверка input accepted;
- stop session;
- reconnect smoke.

Обязательные условия:

```text
explicit flag, например -AllowProdConditional;
synthetic account из allowlist;
allowlisted game/title;
resource budget;
max sessions per run;
max session duration;
no uncontrolled parallelism;
teardown/finally;
cleanup verification;
artifacts;
clear failure reason.
```

### 2.3. PROD_FORBIDDEN

Нельзя запускать на production.

Примеры:

- load/stress tests;
- chaos tests;
- network degradation на реальной production-инфраструктуре;
- массовое создание игровых сессий;
- destructive cleanup;
- удаление аккаунтов;
- изменение данных реальных пользователей;
- реальные платежи;
- тесты банов/антифрода;
- искусственное заполнение capacity;
- update/rollback на обычном production channel;
- тесты с real user accounts;
- тесты с production secrets в коде;
- тесты, влияющие на live-сессии других пользователей.

### 2.4. NON_PROD_ONLY

Тесты, которые нужны проекту, но должны жить только в staging/fake/replay/local средах.

Примеры:

- update rollback;
- fake signaling malformed messages;
- TURN/STUN error injection;
- network packet loss/jitter/bandwidth shaping;
- load/stress;
- destructive state reset;
- replay server scenarios;
- fake backend chaos.

---

## 3. Git workflow для Codex

Codex не должен работать напрямую в `main` для backlog-задач.

Правила:

```text
main = protected trunk.
Каждый bounded goal = отдельная ветка.
Ветка должна быть atomic but useful: один rollback-sized backlog slice.
Codex не делает force-push в main.
Codex не merge-ит в main без явного разрешения пользователя.
Builder/subagent не commit/push.
Commit/push делает только orchestrator после verification.
```

Рекомендуемые имена веток:

```text
codex/prod-safety-foundation
codex/release-artifact-gates
codex/webview-bridge-contract
qa/app-launch-smoke
docs/git-handoff-governance
fix/prodguard-classification
```

Перед началом задачи:

```powershell
git status --short
git checkout main
git pull --ff-only
git checkout -b codex/<task-name>
```

Перед финальным отчётом:

```powershell
git status --short
git diff --check
# plus project-specific verification
```

Если Codex не может создать ветку, он должен явно написать blocker и не продолжать с изменениями в `main`, если пользователь не разрешил.

---

## 4. Handoff и context governance

Для работы в нескольких Codex-сессиях нужен не один огромный handoff, а короткие актуальные документы.

Рекомендуемая структура:

```text
docs/context/
  current-state.md

  handoff/
    active-run.md
    context-protocol.md
    executor-policy.md
    executor-checklist.md
    task-request-log.md
    task-request-template.md

  governance/
    decisions-log.md
    session-log.md
    context-integrity-checklist.md

  engineering/
    git-workflow.md
    implementation-status.md
    verification-memory.md
    quality-gates.md
```

### 4.1. active-run.md

Короткий текущий статус:

```text
текущий goal;
ветка;
scope;
что запрещено;
какие файлы можно менять;
verification plan;
blockers;
следующий recommended goal.
```

`active-run.md` не должен превращаться в длинный журнал. История идёт в `session-log.md`.

### 4.2. verification-memory.md

Фиксирует проверки:

```text
дата;
ветка;
goal;
команды;
результат;
что не запускалось;
почему не запускалось;
известные warnings;
production impact: none / dry-run / conditional;
no credentials committed;
no game session started, если применимо.
```

### 4.3. decisions-log.md

Фиксирует долговечные решения:

```text
D-001: ProdSafety foundation before broad E2E.
D-002: Branch-per-task Git workflow.
D-003: No game-session tests before ProdGuard/SyntheticUserGuard/ResourceBudget/CleanupVerifier.
D-004: Release/privacy gates are P0 and independent from E2E.
D-005: WebView/native bridge contract before broad UI automation.
D-006: Dangerous tests are NON_PROD_ONLY/PROD_FORBIDDEN until fake/staging/replay exists.
```

---

## 5. Read order для новой Codex-сессии

Каждая новая независимая задача начинается с чтения:

```text
1. AGENTS.md
2. docs/context/handoff/active-run.md
3. docs/context/current-state.md
4. docs/context/handoff/context-protocol.md
5. docs/codex/codex-workflow.md
6. docs/codex/autonomy-modes.md
7. docs/context/handoff/executor-policy.md
8. docs/context/handoff/executor-checklist.md
9. docs/qa/prod-testing-policy.md
10. docs/qa/prod-safe-test-matrix.md
11. docs/qa/value-effort-backlog.md
12. task-specific docs/code
```

Codex не должен начинать реализацию до repo discovery и краткого плана.

---

## 6. Multi-agent роли

### 6.1. Planner Agent

Задачи:

- читает docs/code;
- делает repo map;
- уточняет scope;
- выявляет риски;
- предлагает acceptance criteria;
- предлагает verification commands;
- не меняет код без разрешения.

### 6.2. Prod Safety Agent

Задачи:

- классифицирует тесты;
- проверяет production impact;
- проверяет synthetic users;
- проверяет resource budget;
- проверяет cleanup;
- запрещает небезопасные сценарии;
- проверяет, что Codex не ослабляет guard/kill switch.

### 6.3. Framework Builder Agent

Задачи:

- reusable framework;
- ProdSafety layer;
- AppLauncher;
- Native UI driver;
- WebView connector;
- artifact collectors;
- cleanup verifier;
- не добавляет business E2E до готовности primitives.

### 6.4. Scenario Builder Agent

Задачи:

- пишет сценарии поверх framework;
- не использует low-level hacks внутри тестов;
- не использует arbitrary sleep;
- соблюдает classification;
- не создаёт production game session без explicit conditional guard.

### 6.5. QA Reviewer Agent

Задачи:

- независимый review diff;
- flaky waits;
- missing cleanup;
- false positives;
- artifacts;
- privacy/security;
- scope creep.

### 6.6. Release Gate Agent

Задачи:

- подпись исполняемых файлов;
- PDB/sourcemaps;
- local paths;
- secrets;
- unsafe configs;
- release package integrity.

### 6.7. Orchestrator

Задачи:

- держит scope;
- запускает gates;
- делает commit/push task branch;
- не merge-ит main без явного разрешения;
- обновляет handoff/verification-memory/session-log.

---

## 7. Рекомендуемая структура репозитория

```text
winclient-qa-automation/
  AGENTS.md
  README.md
  .gitignore
  .editorconfig

  docs/
    context/
      current-state.md
      handoff/
        active-run.md
        context-protocol.md
        executor-policy.md
        executor-checklist.md
        task-request-log.md
        task-request-template.md
      governance/
        decisions-log.md
        session-log.md
        context-integrity-checklist.md
      engineering/
        git-workflow.md
        implementation-status.md
        verification-memory.md
        quality-gates.md

    qa/
      test-strategy.md
      prod-testing-policy.md
      synthetic-users-policy.md
      prod-safe-test-matrix.md
      resource-budget-policy.md
      test-data-policy.md
      testability-contract.md
      selectors-policy.md
      webview-bridge-contract.md
      streaming-quality-oracles.md
      release-gates.md
      privacy-and-logging-checks.md
      artifacts-policy.md
      flakiness-policy.md
      incident-stop-policy.md
      value-effort-backlog.md

    codex/
      codex-workflow.md
      goal-mode-rules.md
      agent-roles.md
      prod-safe-codex-rules.md
      git-handoff-rules.md
      autonomy-modes.md
      task-template.md
      goal-template.md
      review-template.md

  src/
    TestFramework/
      ProdSafety/
      AppLauncher/
      NativeUi/
      WebView/
      Backend/
      Artifacts/
      Oracles/
      Utils/

  tests/
    ProdSafety/
    ProdSafeSmoke/
    ProdConditional/
    ReleaseArtifact/
    PrivacyLogging/
    NonProdOnly/

  scripts/
    bootstrap.ps1
    quality-gate.ps1
    run-prod-safe-smoke.ps1
    run-prod-canary.ps1
    run-release-gate.ps1
    collect-artifacts.ps1
    reset-test-env.ps1

  testdata/
    synthetic-users.example.json
    allowed-games.example.json
    prod-resource-budget.example.yaml

  reports/
    .gitkeep
```

---

## 8. Первый backlog

### M0. Governance + ProdSafety foundation

Priority: P0  
Value: very high  
Effort: low/medium

Сделать:

- AGENTS.md;
- Git workflow docs;
- handoff/context protocol;
- verification-memory;
- decisions-log;
- prod-testing-policy;
- synthetic-users-policy;
- resource-budget-policy;
- prod-safe-test-matrix;
- TestClassification;
- TestMetadata;
- ProdGuard;
- SyntheticUserGuard;
- ResourceBudget;
- KillSwitch;
- CleanupVerifier skeleton;
- dry-run scripts.

Acceptance criteria:

- unclassified tests cannot run on production;
- PROD_FORBIDDEN cannot run on production;
- PROD_CONDITIONAL requires explicit flag;
- kill switch exists;
- synthetic user allowlist example exists;
- resource budget example exists;
- cleanup verifier skeleton exists;
- Codex branch-per-task rules documented;
- active-run/verification-memory/session-log updated;
- no game-session tests added yet.

### M1. Release artifact + privacy gates

Priority: P0  
Value: very high  
Effort: medium

Проверки:

- exe/updater/installer signing;
- no PDB in release package;
- no sourcemaps unless explicitly allowed;
- no local developer paths;
- no secrets;
- no tokens/passwords in logs;
- no unsafe production debug flags.

### M2. App launch + WebView smoke

Priority: P0/P1  
Classification: PROD_SAFE

Проверки:

- app starts;
- main window found;
- WebView visible or observable ready state;
- no crash;
- logs collected and sanitized;
- screenshot on failure.

### M3. WebView/native bridge contract + fake native host

Priority: P1  
Classification: local / PROD_SAFE contract layer

Проверки:

- command registry;
- payload schemas;
- malformed events;
- UI reacts correctly;
- bridge command names do not silently change.

### M4. Safe backend smoke

Priority: P1  
Classification: PROD_SAFE if read-only / PROD_CONDITIONAL if state-mutating

Проверки:

- config/check endpoints;
- release notes/update info read-only;
- catalog read-only;
- auth only with synthetic users;
- no real user data.

### M5. Minimal game-session canary

Priority: P1/P2  
Classification: PROD_CONDITIONAL

Проверки:

- one synthetic user;
- one allowlisted game;
- one short session;
- stream ready / first frame;
- stop session;
- cleanup verification;
- artifacts;
- no uncontrolled retries.

### M6. Future non-prod/replay/network/hardware

Priority: P2  
Classification: NON_PROD_ONLY until safe environment exists

Сделать позже:

- fake backend;
- fake signaling;
- replay server;
- update rollback;
- network degradation;
- hardware decoder matrix;
- load/stress outside production.

---

## 9. Quality gates

Codex должен стремиться к единой команде:

```powershell
.\scripts\quality-gate.ps1 -Scope Context
.\scripts\quality-gate.ps1 -Scope ProdSafety
.\scripts\quality-gate.ps1 -Scope Release
.\scripts\quality-gate.ps1 -Scope Privacy
.\scripts\quality-gate.ps1 -Scope Dotnet
.\scripts\quality-gate.ps1 -Scope Full
```

На старте можно сделать skeleton/dry-run, но структура должна быть готова.

Минимальный `ProdSafety` gate проверяет:

```text
unclassified rejected on production;
PROD_FORBIDDEN rejected on production;
PROD_CONDITIONAL requires explicit flag;
kill switch works;
synthetic users config validates;
resource budget config validates;
no game session starts during dry-run.
```

---

## 10. Первый goal для Codex

Первый goal должен быть строго ограничен:

```text
Implement production-safe QA automation guard foundation.
```

В первом milestone нельзя:

```text
добавлять реальные game-session tests;
запускать production game sessions;
делать load/stress/chaos/destructive tests;
делать update rollback на production;
хардкодить credentials;
использовать real user accounts;
ослаблять kill switch / ProdGuard;
включать WebView debug port в production по умолчанию;
скрывать flaky behavior blind retries.
```

---

## 11. Definition of Done для M0

M0 считается выполненным, если:

1. Есть отдельная task branch.
2. Обновлён `AGENTS.md`.
3. Создан/обновлён `docs/context/handoff/active-run.md`.
4. Создан `docs/context/engineering/git-workflow.md`.
5. Создан `docs/context/engineering/verification-memory.md`.
6. Создан `docs/context/governance/decisions-log.md`.
7. Созданы QA policy docs.
8. Есть ProdSafety skeleton/implementation.
9. Есть dry-run scripts.
10. Есть примеры synthetic users/resource budget.
11. Есть проверки, показывающие, что unsafe tests rejected.
12. В verification-memory записано, что game-session tests не запускались.
13. Codex дал final report с changed files, commands, blockers, risks, next steps.
15. Codex не merge-ил main без явного разрешения.

---

## 12. Итоговое правило

Для этого проекта успех автоматизации измеряется не количеством тестов, а безопасностью и полезностью покрытия.

Правильная первая версия:

```text
маленький, надёжный, production-safe foundation
+ guard layer
+ release/privacy gates
+ disciplined Git/handoff workflow
+ несколько safe smoke checks
```

Неправильная первая версия:

```text
большой набор широких E2E без classification, budget, cleanup, artifacts и git discipline.
```

## Communication and reasoning policy

Codex must communicate with the project owner in Russian by default. This applies to plans, status updates, final reports, blockers and stop-and-ask questions.

Technical identifiers must remain unchanged: file paths, commands, class names, enum values, environment variables, branch names, test names and error codes. Code and machine-readable configs should follow repository conventions and usually remain English.

Codex must not expose private chain-of-thought or raw scratchpad reasoning. Instead, it must provide concise Russian reasoning summaries: assumptions, chosen approach, alternatives if relevant, production-safety implications, risks, verification and blockers.

For substantial tasks, final reports must include:

```text
1. Режим работы: NON_AUTONOMOUS или BOUNDED_AUTONOMOUS.
2. Что было сделано.
3. Краткое обоснование решений.
4. Какие файлы изменены.
5. Какие проверки выполнены.
6. Что не удалось проверить и почему.
7. Production-safety результат.
8. Риски/блокеры.
9. Следующий рекомендуемый шаг.
```

The detailed policy is stored in `docs/codex/communication-policy.md`.

