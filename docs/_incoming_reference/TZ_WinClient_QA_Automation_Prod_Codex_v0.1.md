# Техническое задание v0.1

# Проект автоматизации тестирования Windows-клиента с WebView для облачного гейминга

Дата: 29 мая 2026  
Текущий ключевой контекст: **автоматизация тестирования сейчас всегда запускается на production-среде**.  
Целевой потребитель документа: владелец проекта, QA, разработчики клиента/бэкенда, Codex в multi-agent + goal mode.

---

## 1. Назначение документа

Настоящее ТЗ описывает, как организовать проект автоматизации тестирования Windows-приложения на C++ с embedded WebView/WebView2 для облачного гейминга, если в текущей операционной модели тестирование проводится на production-среде.

Документ должен использоваться как:

- стартовое ТЗ для создания отдельного проекта автоматизации;
- источник требований к структуре репозитория;
- источник правил безопасности production-тестирования;
- набор правил для Codex при работе в multi-agent + goal mode;
- основание для первого backlog автоматизации;
- чеклист того, что нельзя автоматизировать на production.

Главная цель проекта автоматизации — не просто кликать UI, а защищать основные бизнес-сценарии и качество пользовательского опыта без риска для реальных пользователей и production-инфраструктуры.

---

## 2. Исходные условия и допущения

### 2.1. Известные условия

- Тестируемое приложение — Windows desktop client.
- Нативная часть приложения написана на C++.
- Внутри приложения есть WebView/WebView2 или аналогичный embedded web layer.
- Продуктовая цель клиента — облачный гейминг.
- QA интересует не только техническая корректность, но и основной пользовательский опыт.
- На текущий момент тестирование всегда проводится на production-среде.
- Отдельной полноценной staging/fake/replay-среды может не быть или она не является текущим рабочим контуром.
- Codex планируется использовать активно, в том числе в multi-agent + goal mode.

### 2.2. Основное архитектурное следствие

Автоматизация должна проектироваться не как обычная широкая E2E-регрессия, а как:

- **prod-safe synthetic monitoring**;
- **canary QA**;
- **осторожные smoke-сценарии**;
- **релизные и privacy/security gates**;
- **основа для будущей non-prod регрессии**.

### 2.3. Ключевое ограничение

На production нельзя запускать любые тесты, которые могут:

- затронуть реальные пользовательские данные;
- создать финансовые или операционные побочные эффекты;
- загрузить инфраструктуру сверх согласованного лимита;
- повлиять на реальные игровые сессии;
- создать массовые игровые сессии;
- сломать пользовательские метрики, алерты, антифрод или capacity;
- удалить или изменить данные, не принадлежащие synthetic test users.

---

## 3. Цели проекта автоматизации

### 3.1. Бизнес-цели

1. Быстро понимать, что основной пользовательский путь жив:
   - запуск клиента;
   - login;
   - загрузка каталога;
   - выбор игры;
   - старт игровой сессии;
   - появление stream ready / first frame;
   - корректная остановка сессии.

2. Снижать риск выката неработоспособного клиента.

3. Защищать пользовательский опыт в самых важных сценариях.

4. Получать полезные артефакты при падениях:
   - логи приложения;
   - скриншоты;
   - crash dumps;
   - WebView console/network diagnostics, если безопасно и доступно;
   - сведения о версии клиента и окружении.

5. Выявлять production-проблемы как synthetic/canary monitoring, не мешая реальным пользователям.

### 3.2. QA-цели

1. Создать управляемый каркас автоматизации.
2. Зафиксировать prod-safe правила до написания большого набора тестов.
3. Разделить тесты по уровню риска для production.
4. Исключить случайный запуск опасных сценариев.
5. Обеспечить минимальную, но стабильную smoke/canary-регрессию.
6. Создать основу для будущей staging/fake/replay-регрессии.

### 3.3. Цели для Codex

1. Дать Codex однозначную структуру проекта.
2. Описать правила работы в multi-agent + goal mode.
3. Запретить небезопасные изменения и тесты по умолчанию.
4. Ввести формат задач, acceptance criteria, verification commands и stop condition.
5. Снизить риск “самодеятельности” Codex при работе с production-сценариями.

---

## 4. Не цели текущего этапа

На текущем этапе не требуется и не допускается на production:

- нагрузочное тестирование;
- stress/chaos testing;
- массовое создание игровых сессий;
- тестирование всех игр каталога;
- длительные игровые сессии;
- destructive cleanup;
- изменение или удаление реальных пользовательских данных;
- тестирование платежей с реальными финансовыми операциями;
- тестирование антифрода/банов на реальных пользователях;
- update/rollback тесты на обычном production release channel без отдельного canary-контроля;
- искусственное создание no-capacity через потребление production-ресурсов;
- любые тесты без classification и guard-слоя.

---

## 5. Рекомендуемый стек

### 5.1. Базовый стек

Рекомендуемый основной стек:

```text
.NET test project
NUnit или xUnit
Microsoft Playwright for WebView2/CDP automation
FlaUI для native Windows UI automation
PowerShell scripts для запуска smoke/canary suites
CI/runner на Windows-машине
```

### 5.2. Обоснование

- .NET удобен для Windows automation, typed framework и стабильного test harness.
- Playwright хорошо подходит для WebView2-слоя при наличии безопасного CDP/debug-порта в test/canary режиме.
- FlaUI подходит для native Windows UI через UI Automation.
- PowerShell удобен для Windows runners, запуска клиента, сбора артефактов и cleanup.

### 5.3. Важное ограничение по WebView debug port

Если тестируется строго production build, включение WebView remote debugging port может быть небезопасным.

Требуется разделить два режима:

```text
Prod user-like smoke:
- без debug port;
- black-box/native UI/accessibility проверки;
- максимально похоже на действия реального пользователя.

Prod diagnostic/canary smoke:
- только на специально разрешённом test/canary build или test-mode;
- только на изолированной машине;
- только для synthetic users;
- debug port только localhost;
- запуск только с явным флагом;
- без доступа извне.
```

Если debug port недоступен или небезопасен, WebView-проверки должны выполняться через native UI/accessibility, логи, видимые состояния и backend/API diagnostics, доступные безопасным способом.

---

## 6. Production testing policy

### 6.1. Обязательная классификация тестов

Каждый тест обязан иметь одну из классификаций:

```text
PROD_SAFE
PROD_CONDITIONAL
PROD_FORBIDDEN
```

Правило:

```text
No classification = no prod run.
```

Тест без классификации не имеет права запускаться на production.

### 6.2. PROD_SAFE

Тесты, которые можно запускать на production автоматически при наличии synthetic users и базовых guard-условий.

Примеры:

- запуск приложения;
- проверка главного окна;
- проверка, что WebView отобразился;
- login/logout synthetic user;
- загрузка каталога;
- открытие карточки игры без старта сессии;
- проверка видимых read-only состояний;
- проверка отсутствия crash;
- проверка отсутствия критичных ошибок в логах;
- проверка, что токены не попали в логи;
- release artifact checks: подпись, debug files, secrets, PDB/sourcemaps.

### 6.3. PROD_CONDITIONAL

Тесты, которые можно запускать на production только при явном разрешении, лимитах, synthetic accounts, resource budget и cleanup verification.

Примеры:

- создание игровой сессии;
- старт stream;
- ожидание stream ready / first frame;
- короткая проверка input accepted;
- остановка сессии;
- reconnect smoke;
- краткая проверка качества стрима.

Обязательные условия для PROD_CONDITIONAL:

- явный флаг запуска, например `-AllowProdConditional`;
- synthetic account из allowlist;
- allowlisted game/title;
- лимит количества сессий;
- лимит длительности сессии;
- запрет неконтролируемого parallelism;
- обязательный cleanup;
- обязательная проверка, что сессия завершена;
- сбор артефактов;
- понятный failure reason.

### 6.4. PROD_FORBIDDEN

Тесты, которые нельзя запускать на production никогда, пока явно не изменится среда/политика.

Примеры:

- load/stress tests;
- chaos tests;
- массовое создание сессий;
- destructive cleanup;
- удаление аккаунтов;
- изменение данных реальных пользователей;
- реальные платежи;
- тесты банов/антифрода;
- искусственное заполнение capacity;
- update/rollback на обычном production channel;
- тесты с production secrets или real credentials;
- тесты, влияющие на live-сессии других пользователей.

---

## 7. Synthetic users и test data policy

### 7.1. Требования к synthetic users

Все production-тесты должны использовать только явно разрешённые synthetic accounts.

Пример allowlist:

```text
qa-smoke-001
qa-smoke-002
qa-catalog-001
qa-canary-stream-001
qa-release-check-001
```

Запрещено использовать:

- реальные пользовательские аккаунты;
- личные аккаунты сотрудников;
- временные “ручные” аккаунты без allowlist;
- аккаунты, не помеченные в системе как synthetic/test;
- credentials, hardcoded в коде или commit history.

### 7.2. Требования к тестовым данным

Для тестов должны быть определены:

- allowlisted games/titles;
- allowlisted regions;
- expected catalog entries;
- допустимые product states;
- ожидаемые ограничения на session duration;
- cleanup expectations.

### 7.3. Credentials

Credentials должны передаваться только через безопасный механизм:

- secret storage CI/runner;
- environment variables;
- local secure config, не попадающий в git;
- masked logs.

Запрещено:

- хранить пароли в `appsettings.json`, `.cs`, `.ps1`, `.md`;
- печатать токены в stdout/stderr;
- прикладывать unsanitized logs к отчётам;
- коммитить `.env` с реальными значениями.

---

## 8. Resource budget policy

Для production-тестов, которые создают игровые сессии, должен существовать resource budget.

Пример конфигурации:

```yaml
prodResourceBudget:
  maxSessionsPerRun: 1
  maxParallelSessions: 1
  maxSessionDurationSeconds: 120
  maxRunsPerHour: 3
  allowedRegions:
    - eu-west
  allowedGames:
    - qa-allowlisted-game-1
  requireCleanupVerification: true
  requireExplicitConditionalFlag: true
```

Минимальные правила:

- одна сессия за раз, пока не согласовано иное;
- короткая длительность сессии;
- только allowlisted games;
- обязательный stop session в teardown/finally;
- отдельная проверка, что сессия не зависла;
- запрет silent retries, которые повторно создают сессии;
- отказ от запуска при превышении бюджета.

---

## 9. Kill switch и аварийная остановка

Должен существовать kill switch, отключающий production automation без изменения кода.

Примеры:

```text
PROD_AUTOMATION_ENABLED=false
QA_PROD_CANARY_ENABLED=false
```

Правила:

- если kill switch выключен, runner не запускает production tests;
- если отключён canary flag, PROD_CONDITIONAL не запускаются;
- failure должен быть явным: “Prod automation disabled by kill switch”;
- запрещено обходить kill switch в тестах;
- Codex не должен удалять или ослаблять kill switch.

---

## 10. Cleanup verification

На production недостаточно, чтобы тест “прошёл”. Нужно доказать, что тест ничего не оставил после себя.

После каждого теста проверяется:

- приложение закрыто или приведено в ожидаемое состояние;
- пользователь разлогинен, если сценарий требует logout;
- игровая сессия остановлена;
- backend не показывает активную сессию synthetic user;
- нет зависших процессов клиента;
- нет незакрытого WebView/debug connection;
- нет непредвиденных созданных сущностей;
- логи собраны и санитизированы.

Для PROD_CONDITIONAL cleanup verification обязателен.

---

## 11. Artifacts policy

### 11.1. Артефакты на каждый запуск

Каждый test run должен сохранять:

- timestamp;
- environment;
- app version/build SHA;
- test classification;
- synthetic account alias, но не password/token;
- test suite name;
- runner machine info;
- logs;
- screenshots on failure;
- crash dumps, если появились;
- exit codes;
- cleanup result.

### 11.2. Артефакты для WebView

Если безопасно и доступно:

- console errors;
- network errors;
- page URL/route без секретов;
- selected DOM state или accessibility snapshot;
- trace для diagnostic/canary режима.

### 11.3. Артефакты для streaming/canary

Для PROD_CONDITIONAL stream tests:

- session id в masked/safe форме;
- region;
- selected game alias;
- time to stream ready;
- time to first frame, если доступно;
- decode/render errors;
- reconnect events, если проверяются;
- session stop result;
- cleanup verification result.

### 11.4. Privacy

Перед публикацией или прикреплением в отчёт артефакты должны быть санитизированы.

Запрещено сохранять в открытом виде:

- access token;
- refresh token;
- password;
- personal data;
- real user identifiers;
- private backend URLs, если они чувствительны;
- secrets;
- full session tokens.

---

## 12. Предлагаемая структура репозитория

```text
winclient-qa-automation/
  AGENTS.md
  README.md
  .gitignore
  .editorconfig
  .codex/
    config.toml

  .github/
    workflows/
      prod-safe-smoke.yml
      prod-canary.yml
      release-gate.yml

  docs/
    context/
      current-state.md
      decision-log.md
      session-log.md
      handoff.md
      verification-memory.md

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
      task-template.md
      goal-template.md
      review-template.md

  src/
    TestFramework/
      AppLauncher/
        AppLauncher.cs
        AppProcess.cs
        AppConfig.cs
        TestModeArgs.cs

      NativeUi/
        NativeAppDriver.cs
        WindowObjects/
        AccessibilityIds.cs

      WebView/
        WebViewConnector.cs
        WebViewPageObjects/
        WebViewConsoleCollector.cs
        WebViewNetworkCollector.cs

      Backend/
        ApiClient.cs
        AuthClient.cs
        CatalogClient.cs
        SessionClient.cs

      ProdSafety/
        ProdGuard.cs
        TestClassification.cs
        TestMetadata.cs
        ResourceBudget.cs
        SyntheticUserGuard.cs
        KillSwitch.cs
        RateLimitGuard.cs
        CleanupVerifier.cs

      Fixtures/
        UserFixture.cs
        GameFixture.cs
        NetworkFixture.cs
        CleanStateFixture.cs

      Oracles/
        AppLaunchOracle.cs
        WebViewReadyOracle.cs
        StreamReadinessOracle.cs
        FirstFrameOracle.cs
        VideoFreezeOracle.cs
        InputAcceptedOracle.cs
        ReconnectOracle.cs
        LogPrivacyOracle.cs

      Artifacts/
        ScreenshotCollector.cs
        VideoCollector.cs
        TraceCollector.cs
        LogCollector.cs
        CrashDumpCollector.cs
        ReportBuilder.cs
        LogSanitizer.cs

      Utils/
        RetryPolicy.cs
        Waits.cs
        Ports.cs
        FileSystem.cs

  tests/
    ProdSafeSmoke/
      AppLaunchProdSmokeTests.cs
      LoginLogoutProdSmokeTests.cs
      CatalogReadOnlyProdSmokeTests.cs
      WebViewInitProdSmokeTests.cs

    ProdConditional/
      GameSessionProdCanaryTests.cs
      StreamReadyProdCanaryTests.cs
      ReconnectProdCanaryTests.cs

    ReleaseArtifact/
      SigningTests.cs
      DebugArtifactLeakTests.cs
      SecretLeakTests.cs
      LocalPathLeakTests.cs

    PrivacyLogging/
      TokenLeakTests.cs
      PersonalDataLeakTests.cs
      LogRedactionTests.cs

    NonProdOnly/
      LoadTests.cs
      DestructiveStateTests.cs
      UpdateRollbackTests.cs
      ErrorInjectionTests.cs

  tools/
    artifact-scanner/
    log-sanitizer/
    app-state-reset/
    inspect-accessibility/
    collect-diagnostics/
    fake-backend/
    fake-signaling-server/
    replay-server/
    network-shaper/

  testdata/
    synthetic-users.example.json
    allowed-games.example.json
    prod-resource-budget.example.yaml
    api-responses/
    signaling-replays/
    stream-samples/

  reports/
    .gitkeep

  scripts/
    bootstrap.ps1
    run-prod-safe-smoke.ps1
    run-prod-canary.ps1
    run-release-gate.ps1
    collect-artifacts.ps1
    reset-test-env.ps1
```

---

## 13. Обязательные компоненты framework

### 13.1. ProdGuard

Назначение:

- запрещает запуск unclassified тестов на production;
- запрещает запуск `PROD_FORBIDDEN` на production;
- запрещает `PROD_CONDITIONAL` без явного флага;
- проверяет kill switch;
- проверяет resource budget;
- проверяет synthetic user allowlist.

Минимальная логика:

```text
if environment == production:
  require test classification
  reject PROD_FORBIDDEN
  reject unclassified
  reject PROD_CONDITIONAL unless explicit flag is present
  require synthetic user for auth scenarios
  require cleanup verification for state-mutating scenarios
```

### 13.2. TestClassification

Пример:

```csharp
public enum TestClassification
{
    ProdSafe,
    ProdConditional,
    ProdForbidden,
    NonProdOnly
}
```

### 13.3. TestMetadata

Каждый тест должен описывать свои production-свойства.

Пример:

```csharp
[TestMetadata(
    Classification = TestClassification.ProdConditional,
    MutatesBackendState = true,
    StartsGameSession = true,
    RequiresSyntheticUser = true,
    MaxRuntimeSeconds = 120,
    CanRunInParallel = false,
    RequiresCleanupVerification = true
)]
public async Task GameSession_Should_Start_And_Stop_Cleanly()
{
    ...
}
```

### 13.4. SyntheticUserGuard

Проверяет, что:

- username/account id входит в allowlist;
- аккаунт имеет synthetic/test marker;
- credentials не печатаются;
- тест не использует real user;
- teardown очищает состояние synthetic user, если нужно.

### 13.5. ResourceBudget

Проверяет:

- max sessions per run;
- max parallel sessions;
- max session duration;
- allowed games;
- allowed regions;
- max runs per hour/day, если применимо.

### 13.6. KillSwitch

Проверяет:

- `PROD_AUTOMATION_ENABLED`;
- `QA_PROD_CANARY_ENABLED`;
- дополнительные remote/config flags, если они есть.

### 13.7. CleanupVerifier

Проверяет:

- сессия остановлена;
- backend не показывает активную сессию synthetic user;
- клиент закрыт;
- процессы очищены;
- артефакты собраны;
- лог не содержит секретов.

---

## 14. Требования к запуску тестов

### 14.1. Prod-safe smoke

Команда:

```powershell
.\scripts\run-prod-safe-smoke.ps1
```

Должна запускать только:

```text
PROD_SAFE
```

Запрещено запускать:

```text
PROD_CONDITIONAL
PROD_FORBIDDEN
Unclassified
```

### 14.2. Prod canary

Команда:

```powershell
.\scripts\run-prod-canary.ps1 -AllowProdConditional
```

Должна запускать:

```text
PROD_SAFE + PROD_CONDITIONAL
```

Обязательные условия:

- explicit flag;
- kill switch enabled;
- resource budget available;
- synthetic user configured;
- cleanup verification enabled;
- no uncontrolled parallelism.

### 14.3. Release gate

Команда:

```powershell
.\scripts\run-release-gate.ps1 -ArtifactPath <path-to-build-artifact>
```

Проверяет:

- подпись exe/msi/msix, если применимо;
- отсутствие debug artifacts;
- отсутствие PDB/sourcemaps в релизном артефакте, если они не должны поставляться;
- отсутствие локальных путей разработчиков;
- отсутствие secrets;
- отсутствие test endpoints в release config;
- корректность update manifest, если применимо.

---

## 15. Первый backlog с value/effort

### M0. Prod-safe policy and framework guards

```text
Value: very high
Effort: low/medium
Priority: P0
```

Сделать:

- `docs/qa/prod-testing-policy.md`;
- `docs/qa/synthetic-users-policy.md`;
- `docs/qa/prod-safe-test-matrix.md`;
- `docs/qa/resource-budget-policy.md`;
- `src/TestFramework/ProdSafety/`;
- `TestClassification`;
- `TestMetadata`;
- `ProdGuard`;
- `SyntheticUserGuard`;
- `ResourceBudget`;
- `KillSwitch`;
- `CleanupVerifier`;
- dry-run проверки runner.

Acceptance criteria:

- unclassified tests не запускаются на production;
- `PROD_FORBIDDEN` не запускаются на production;
- `PROD_CONDITIONAL` не запускаются без explicit flag;
- synthetic user allowlist существует;
- kill switch работает;
- resource budget config существует;
- docs описывают, что запрещено на production.

### M1. App launch + WebView smoke

```text
Value: very high
Effort: low/medium
Priority: P0
Classification: PROD_SAFE
```

Проверки:

- приложение запускается;
- главное окно найдено;
- WebView отображается или observable WebView-ready state найден;
- нет crash;
- нет критичных ошибок в логах;
- screenshot on failure;
- logs collected and sanitized.

### M2. Login/logout synthetic user smoke

```text
Value: very high
Effort: medium
Priority: P0
Classification: PROD_SAFE
```

Проверки:

- login synthetic user;
- пользовательское состояние корректное;
- logout работает;
- токены не попадают в логи;
- состояние очищено после теста.

### M3. Catalog read-only smoke

```text
Value: high
Effort: medium
Priority: P0/P1
Classification: PROD_SAFE
```

Проверки:

- каталог загружается;
- карточки игр видны;
- CTA видны;
- карточка игры открывается без старта сессии;
- нет пустого/битого состояния;
- видимые ошибки понятны, если backend вернул ошибку.

### M4. Minimal game session canary

```text
Value: very high
Effort: high
Priority: P1
Classification: PROD_CONDITIONAL
```

Проверки:

- создаётся одна игровая сессия;
- используется synthetic user;
- используется allowlisted game;
- session duration ограничена;
- stream ready / first frame достигнут;
- сессия корректно остановлена;
- cleanup verification подтверждает отсутствие зависшей сессии;
- нет uncontrolled retries;
- artifacts collected.

### M5. Privacy/logging/release gates

```text
Value: very high
Effort: medium
Priority: P0/P1
Classification: PROD_SAFE
```

Проверки:

- access/refresh tokens не попадают в логи;
- passwords не попадают в логи;
- personal data не попадает в отчёты;
- production secrets отсутствуют в артефактах;
- release artifact подписан;
- debug files отсутствуют;
- PDB/sourcemaps/local paths отсутствуют, если не должны быть в релизе.

### M6. Future non-prod foundation

```text
Value: high
Effort: medium/high
Priority: P2
Classification: NonProdOnly / future
```

Сделать позже:

- fake backend;
- fake signaling server;
- replay server;
- network shaper;
- non-prod destructive scenarios;
- update/rollback scenarios;
- load/stress tests вне production.

---

## 16. Требования к тестам

### 16.1. Общие правила

- Не использовать arbitrary sleep, если можно ждать observable state.
- Не скрывать flakiness blind retries.
- Не добавлять широкие E2E без guard-слоя.
- Каждый тест должен иметь понятный failure reason.
- Каждый тест должен собирать достаточные artifacts.
- Каждый state-mutating тест должен иметь cleanup.
- Каждый production-тест должен быть классифицирован.

### 16.2. Ожидания и oracles

Предпочтительные источники truth:

- observable UI state;
- UI Automation state;
- WebView DOM state, если безопасно;
- backend state synthetic user;
- structured diagnostics logs;
- explicit app events;
- session lifecycle state;
- crash/no-crash state.

Для streaming:

- stream ready event;
- first frame rendered;
- video not frozen for short interval;
- input accepted event;
- reconnect completed event;
- stop session confirmed.

### 16.3. Запреты

Запрещено:

- sleep-only ожидания без observable condition;
- бесконечные retries;
- retries, создающие новые production-сессии без бюджета;
- hardcoded credentials;
- вывод токенов;
- любые действия с real users;
- тесты без cleanup для state mutation;
- запуск conditional tests из smoke-команды.

---

## 17. Testability contract для приложения

Даже если сейчас тестирование идёт на production, в приложении желательно предусмотреть безопасные testability hooks.

### 17.1. Потенциальные launch flags

```text
--test-mode
--test-config=<path>
--log-dir=<path>
--crash-dump-dir=<path>
--clean-user-data
--disable-auto-update
--enable-diagnostics
--webview-debug-port=<localhost-port>
```

В production/canary режиме каждый такой flag должен быть безопасно ограничен и не должен открывать debug-возможности реальным пользователям.

### 17.2. WebView требования

- стабильные `data-testid`, если доступны;
- стабильные route/page names;
- безопасный CDP/debug только для разрешённого test/canary режима;
- отдельный user data folder для тестов;
- сбор console errors, если безопасно;
- запрет secrets в frontend logs;
- явный bridge contract.

### 17.3. Native shell требования

- стабильные AutomationId/Name для ключевых элементов;
- предсказуемые window titles;
- возможность найти главное окно;
- доступные состояния loading/ready/error;
- отсутствие необходимости blind sleep.

### 17.4. Backend/session requirements

Для synthetic users желательно иметь безопасные endpoints/возможности:

- получить активную сессию synthetic user;
- остановить зависшую synthetic session;
- проверить session state;
- получить catalog state;
- reset state synthetic user, если разрешено;
- не затрагивать real users.

---

## 18. WebView/native bridge contract

Должен быть отдельный документ:

```text
docs/qa/webview-bridge-contract.md
```

В нём фиксируется:

- direction: web → native или native → web;
- command/event name;
- payload schema;
- version;
- error behavior;
- logging policy;
- allowed production diagnostics;
- expected UI effect;
- security constraints.

Цель: не дать bridge ломаться незаметно и не позволить Codex писать тесты, которые полагаются на несуществующие или небезопасные команды.

---

## 19. Release artifact gates

Release gate должен выполняться независимо от E2E.

Проверки:

- подпись исполняемых файлов;
- отсутствие debug-only файлов;
- отсутствие PDB/sourcemaps, если они не должны поставляться;
- отсутствие локальных путей разработчика;
- отсутствие secrets;
- отсутствие test endpoints в release config;
- корректность version metadata;
- корректность update manifest;
- отсутствие лишних diagnostic flags в production config.

Release gate особенно ценен, потому что он не требует взаимодействия с production backend и почти не несёт риска для пользователей.

---

## 20. Privacy and logging gates

Обязательные проверки:

- access token не логируется;
- refresh token не логируется;
- password не логируется;
- user personal data не попадает в открытые отчёты;
- session id маскируется или хранится безопасно;
- backend URLs/secrets не попадают в публичные artifacts;
- screenshot не содержит sensitive data, если может быть опубликован;
- crash dumps обрабатываются по отдельной политике.

Для Codex:

```text
Codex must not print or commit credentials, tokens, personal data, production secrets, or real user identifiers.
```

---

## 21. Flakiness policy

Правила:

1. Blind retry не является лечением flaky test.
2. Retry допустим только как диагностическая мера или для известных transient-событий с жёстким лимитом.
3. Нельзя использовать retry, который создаёт новые production-сессии сверх бюджета.
4. Flaky test должен быть либо стабилизирован, либо quarantined с причиной.
5. Quarantine требует отдельного issue/записи в docs.
6. Любой flaky production canary должен сохранять артефакты и cleanup result.

---

## 22. Правила для Codex

### 22.1. Общий принцип

Codex должен считать, что любой тест может быть запущен на production, если явно не указано обратное.

Поэтому:

```text
Production-safe by default.
No classification = no prod run.
No synthetic user guard = no prod auth test.
No resource budget = no prod game session test.
No cleanup verification = no prod state mutation test.
```

### 22.2. Рекомендуемые файлы Codex-документации

```text
AGENTS.md
docs/codex/codex-workflow.md
docs/codex/goal-mode-rules.md
docs/codex/agent-roles.md
docs/codex/prod-safe-codex-rules.md
docs/codex/task-template.md
docs/codex/goal-template.md
docs/codex/review-template.md
```

### 22.3. Обязательные правила в AGENTS.md

```md
## Production environment rule

This project currently tests against production.

All automation must be production-safe by default.

Every test must declare:
- environment classification;
- whether it mutates backend state;
- whether it starts a game session;
- whether it requires cleanup;
- maximum allowed runtime;
- synthetic account requirements.

No test may run on production unless it is classified as `PROD_SAFE` or explicitly allowed as `PROD_CONDITIONAL`.

`PROD_FORBIDDEN` tests must exist only for documentation or future non-production environments and must be excluded from prod runs.

Do not add blind retries to hide production instability.
Do not perform load, stress, chaos, destructive, payment, or real-user-data tests on production.

Cloud gaming session tests must:
- use synthetic accounts only;
- use allowlisted games only;
- enforce max duration;
- stop the session in cleanup;
- verify cleanup;
- collect logs and screenshots;
- avoid parallel execution unless explicitly approved.
```

---

## 23. Multi-agent roles for Codex

### 23.1. Planner Agent

Назначение:

- изучить docs/code;
- понять задачу;
- найти риски;
- предложить план;
- выделить acceptance criteria;
- определить verification commands.

Не должен менять код без явного разрешения.

### 23.2. Prod Safety Agent

Назначение:

- классифицировать тесты;
- находить production risks;
- проверять synthetic users;
- проверять resource budget;
- искать опасные побочные эффекты;
- запрещать небезопасные сценарии.

### 23.3. Framework Builder Agent

Назначение:

- писать reusable framework code;
- app launcher;
- Native UI driver;
- WebView connector;
- ProdSafety layer;
- artifact collectors;
- cleanup verifier.

Не должен добавлять бизнес-сценарии до готовности primitives.

### 23.4. Scenario Builder Agent

Назначение:

- писать тесты сценариев на базе существующего framework;
- не создавать low-level hacks внутри тестов;
- не использовать arbitrary sleeps;
- соблюдать production classification.

### 23.5. QA Reviewer Agent

Назначение:

- независимый review;
- поиск flaky waits;
- поиск missing cleanup;
- проверка artifacts;
- проверка false positives;
- проверка privacy/security risks.

### 23.6. Release Gate Agent

Назначение:

- проверка release artifacts;
- подпись;
- debug files;
- sourcemaps/PDB;
- local path leaks;
- secrets;
- unsafe configs.

---

## 24. Когда использовать обычный режим, plan, goal и subagents

```text
Обычный Codex:
- мелкая правка;
- один helper;
- маленький тест;
- обновить README;
- поправить selector.

Plan mode:
- новая область автоматизации;
- выбор архитектуры;
- рискованная задача;
- refactor framework;
- задача с production impact.

Goal mode:
- bounded milestone;
- есть acceptance criteria;
- есть verification commands;
- есть stop condition;
- несколько файлов, но понятный scope.

Subagents:
- большой анализ;
- независимый review;
- prod-safety анализ;
- параллельно framework/scenario/review;
- release artifact audit.
```

Для текущего проекта multi-agent + goal mode подходит, но только при жёстком scope и production safety constraints.

---

## 25. Шаблон goal-задачи для Codex

```md
/goal Complete the following bounded QA automation task.

Context:
The current automation target is production.
All tests must be production-safe by default.
No classification = no prod run.

Objective:
Implement [specific capability/test suite] for the Windows cloud gaming client.

Read first:
- AGENTS.md
- docs/context/current-state.md
- docs/context/decision-log.md
- docs/qa/prod-testing-policy.md
- docs/qa/synthetic-users-policy.md
- docs/qa/resource-budget-policy.md
- docs/codex/prod-safe-codex-rules.md
- relevant existing code under [paths]

Scope:
Allowed to change:
- [paths]

Not allowed to change:
- [paths]

Forbidden:
- load/stress/chaos tests on production;
- destructive tests;
- real user data;
- hardcoded credentials;
- uncontrolled game session creation;
- weakening ProdGuard/KillSwitch.

Acceptance criteria:
- [criterion 1]
- [criterion 2]
- [criterion 3]

Verification:
Run:
- [command 1]
- [command 2]

Artifacts:
- test report;
- logs on failure;
- screenshots/traces where applicable;
- cleanup verification result;
- updated docs/context/handoff.md.

Checkpoints:
1. Inspect current structure and summarize plan.
2. Confirm production safety classification.
3. Implement smallest framework/scenario change.
4. Run verification.
5. Review for flakiness/security/privacy.
6. Final report.

Stop when:
- all acceptance criteria pass;
- verification has been run or a blocker is documented;
- changed files and risks are reported.

Pause and ask only if:
- required build artifact is missing;
- test environment cannot launch the app;
- requested behavior conflicts with production safety rules;
- credentials/secrets are missing and cannot be safely mocked or configured.
```

---

## 26. Первый рекомендуемый prompt для Codex

```md
/goal Implement production-safe automation guard foundation.

Context:
The current automation target is production. All tests must be safe by default.
No classification = no prod run.

Read first:
- AGENTS.md
- docs/qa/test-strategy.md if exists
- existing test framework code

Objective:
Add a production safety foundation for the Windows client QA automation project.

Scope:
Allowed:
- docs/qa/prod-testing-policy.md
- docs/qa/synthetic-users-policy.md
- docs/qa/prod-safe-test-matrix.md
- docs/qa/resource-budget-policy.md
- src/TestFramework/ProdSafety/
- scripts/run-prod-safe-smoke.ps1
- scripts/run-prod-canary.ps1

Not allowed:
- adding game session tests yet
- adding load/stress/destructive tests
- hardcoding real credentials
- changing production app behavior
- weakening existing safety checks

Acceptance criteria:
- tests must declare PROD_SAFE, PROD_CONDITIONAL, or PROD_FORBIDDEN
- prod runner must refuse unclassified tests
- prod runner must refuse PROD_FORBIDDEN tests
- prod runner must refuse PROD_CONDITIONAL unless explicit flag is provided
- synthetic user allowlist exists
- resource budget config exists
- kill switch exists
- docs explain what is forbidden on production

Verification:
- run unit tests for ProdGuard if available
- run dry-run of prod-safe command
- show that unclassified/prod-forbidden tests are rejected
- show that PROD_CONDITIONAL requires explicit flag

Stop when:
- guard foundation is implemented
- docs are updated
- verification result is reported
- risks and next steps are listed
```

---

## 27. Acceptance criteria для версии 0.1 проекта автоматизации

Версия 0.1 считается готовой, если выполнено:

1. Репозиторий имеет базовую структуру.
2. Есть `AGENTS.md` с production safety rules.
3. Есть документы:
   - `prod-testing-policy.md`;
   - `synthetic-users-policy.md`;
   - `prod-safe-test-matrix.md`;
   - `resource-budget-policy.md`;
   - `artifacts-policy.md`;
   - `flakiness-policy.md`.
4. Есть `ProdSafety` слой.
5. Есть classification для тестов.
6. Runner запрещает unclassified/forbidden tests на production.
7. Conditional tests требуют explicit flag.
8. Есть synthetic user allowlist example.
9. Есть resource budget example.
10. Есть kill switch.
11. Есть smoke test запуска приложения или подготовленный skeleton для него.
12. Есть artifact collector/log collector skeleton.
13. Есть privacy/log sanitizer skeleton или policy.
14. Есть handoff/update discipline для Codex.

---

## 28. Риски и меры снижения

### Риск 1. Автотест случайно повлияет на production users

Меры:

- synthetic users only;
- ProdGuard;
- no real user data;
- explicit classification;
- cleanup verification;
- resource budget;
- kill switch.

### Риск 2. Тесты создадут нагрузку на cloud gaming infrastructure

Меры:

- max sessions per run;
- max parallel sessions = 1;
- short session duration;
- no load tests on prod;
- no uncontrolled retries;
- allowlisted games.

### Риск 3. Codex напишет опасный тест

Меры:

- AGENTS.md;
- prod-safe-codex-rules.md;
- bounded goal prompt;
- explicit forbidden scope;
- QA Reviewer Agent;
- Prod Safety Agent.

### Риск 4. Секреты попадут в логи или артефакты

Меры:

- log sanitizer;
- masked values;
- privacy gate;
- no hardcoded credentials;
- artifact policy.

### Риск 5. Flaky tests создадут ложные алерты

Меры:

- observable waits;
- artifacts;
- flakiness policy;
- quarantine with reason;
- no blind retries.

### Риск 6. Нет доступа к WebView internals

Меры:

- black-box native UI checks;
- UI Automation states;
- safe logs;
- backend/session observations;
- optional diagnostic/canary debug mode only if approved.

---

## 29. Рекомендованный порядок внедрения

1. Создать репозиторий/папку automation.
2. Добавить `AGENTS.md` и docs/codex.
3. Добавить prod-safe policy docs.
4. Реализовать `ProdSafety` skeleton.
5. Реализовать scripts:
   - `run-prod-safe-smoke.ps1`;
   - `run-prod-canary.ps1`;
   - `run-release-gate.ps1`.
6. Реализовать AppLauncher и artifact collector.
7. Добавить App launch smoke.
8. Добавить Login/logout synthetic user smoke.
9. Добавить Catalog read-only smoke.
10. Добавить Release/privacy gates.
11. Только после этого добавлять minimal game session canary.
12. Отдельно планировать non-prod/fake/replay infrastructure.

---

## 30. Критически важное итоговое правило

Для текущей модели “тестируем на production всегда” ценность автоматизации определяется не количеством E2E-тестов, а качеством контроля риска.

Правильный первый результат:

```text
5-10 очень надёжных synthetic/canary сценариев
+
жёсткий ProdSafety layer
+
понятные artifacts
+
privacy/release gates
+
Codex rules
```

Неправильный первый результат:

```text
50 широких UI-тестов без classification, без cleanup, без budget и без kill switch.
```

---

## 31. Краткая сводка для владельца проекта

Рекомендуемая стратегия:

1. Сначала сделать production safety framework.
2. Потом безопасные smoke-тесты: launch, login/logout, catalog.
3. Потом release/privacy gates.
4. Затем осторожный canary: одна короткая игровая сессия.
5. Все опасные сценарии пометить как `PROD_FORBIDDEN` до появления non-prod среды.
6. Codex использовать в multi-agent + goal mode, но только с bounded задачами, acceptance criteria, verification commands и stop condition.
7. В каждом prompt явно писать: current target environment is production.

Конечная цель первой версии — получить управляемую, безопасную и расширяемую автоматизацию, которая проверяет основной пользовательский путь и не создаёт риска для production.
