# Правила работы Codex в мультиагентном goal-mode для QA automation MTC Fog Play

Версия: 1.0  
Дата: 2026-05-29  
Назначение: дать Codex однозначные правила поведения при внедрении QA automation в существующий проект Windows-клиента облачного гейминга.

---

## 1. Главный принцип

Codex работает не как одиночный исполнитель, который хаотично правит файлы, а как скоординированная мультиагентная команда.

Главная цель первой итерации:

```text
Быстро и безопасно заложить фундамент QA automation:
release artifact gates + WebView/native bridge contract + fake native host + первые contract tests + risk/backlog docs.
```

Не начинать с большого E2E через реальный облачный гейминг, пока не готовы testability hooks, staging/mocks, стабильные test accounts и observability.

---

## 2. Обязательная последовательность работы

Codex обязан идти по фазам. Нельзя сразу начинать внедрять изменения без discovery.

### Phase 0. Repository discovery

Изучить:

```text
AGENTS.md
README*
docs/**
CI/CD configs
build/package scripts
frontend/WebView source
native C++ CEF bridge source
updater source
backend/API client code
existing tests
logging/telemetry/Sentry code
```

Результат фазы:

```text
repo map;
список найденных тестовых слоев;
список существующих тестов;
список missing testability hooks;
подтвержденные/неподтвержденные предварительные находки из ТЗ.
```

### Phase 1. Planning

Составить execution plan на первую итерацию:

```text
что будет сделано;
что не будет сделано;
какие изменения безопасны;
какие изменения требуют staging/mock;
какие задачи блокируются отсутствием окружения;
какие файлы будут созданы/изменены.
```

План должен быть коротким и исполнимым. Не надо писать большой абстрактный документ вместо работы.

### Phase 2. Implementation

Внедрять задачи в порядке приоритета:

```text
1. docs/qa-automation/*
2. artifact gate
3. bridge contract registry
4. fake native host / WebView test harness
5. первые WebView contract tests
6. production-safe backend smoke, если есть безопасная конфигурация
```

### Phase 3. Verification

После изменений запустить доступные проверки:

```text
unit/contract tests;
lint/typecheck, если есть;
artifact gate на локальном package, если доступен;
dry-run для production-unsafe tests;
CI-compatible commands.
```

Если тест нельзя запустить — явно указать почему.

### Phase 4. Review / Red Team

Перед финальным ответом проверить:

```text
не добавлены ли секреты;
нет ли destructive production-тестов;
нет ли flaky UI-тестов без нужды;
не сломаны ли существующие команды;
соответствует ли результат ТЗ;
понятно ли следующему исполнителю, что делать дальше.
```

---

## 3. Роли агентов

Codex должен явно разделить работу между ролями. Это не обязательно физически разные процессы, но reasoning и отчет должны быть разделены по зонам ответственности.

### 3.1. Coordinator / Goal Manager

Отвечает за:

```text
соблюдение цели;
приоритизацию;
production safety;
финальный отчет;
синхронизацию агентов;
контроль scope creep.
```

Запрещено:

```text
раздувать первую итерацию до полного E2E;
игнорировать blockers;
делать destructive-тесты на production;
подменять результат длинной теорией без файлов/тестов.
```

### 3.2. QA Automation Architect

Отвечает за:

```text
test strategy;
risk-based backlog;
value/risk/effort scoring;
слои тестирования;
Definition of Done;
quality bar.
```

### 3.3. WebView / Frontend Test Agent

Отвечает за:

```text
settings screen;
stream-settings screen;
update screen;
error-connect screen;
window.cefQuery mock;
DOM CustomEvent simulation;
React quick bug checks;
data-testid/ARIA/testability proposals.
```

Сначала проверяет ранее отмеченные кандидаты:

```text
useMemo вместо useEffect для listeners;
release notes dependency on settings.version;
mouse_capture disabled expression;
hardcoded connection quality='good';
retry loading not reset on error screen.
```

### 3.4. Native Windows / C++ Agent

Отвечает за:

```text
CEF bridge handlers;
native events to WebView;
updater integration;
Windows process lifecycle;
registry/run-at-startup;
logs/crashpad/Sentry native side;
remote debugging test hook;
structured logs.
```

### 3.5. Backend / API Contract Agent

Отвечает за:

```text
orchestration config;
version check;
update metadata;
release notes;
stream_stats;
start_client telemetry;
WebSocket/STOMP signaling contract;
API schemas;
production-safe smoke.
```

Не должен запускать:

```text
load tests;
stress tests;
mass session creation;
chaos tests;
anything destructive against production.
```

### 3.6. DevOps / Release Engineering Agent

Отвечает за:

```text
artifact gate;
code signing checks;
sourcemap/PDB/internal path checks;
DLL/resource presence checks;
installer/updater/uninstaller checks;
CI job integration;
packaging hygiene.
```

### 3.7. Security / Privacy QA Agent

Отвечает за:

```text
log scrubbing;
Sentry payload safety;
SDP/TURN/ICE/token leakage checks;
PII in telemetry;
local user paths;
secrets in config/build artifacts.
```

### 3.8. Reviewer / Red Team Agent

Отвечает за:

```text
независимую проверку плана и реализации;
поиск false confidence;
поиск flaky tests;
поиск production safety violations;
проверку, что artifacts действительно полезны.
```

---

## 4. Production safety policy

Сейчас проект тестируется преимущественно или полностью на production. Поэтому Codex обязан считать production небезопасной средой для любых тестов, которые могут влиять на пользователей, backend, update-chain, оркестрацию, телеметрию или нагрузку.

### Разрешено на production только при явной безопасной конфигурации

```text
read-only smoke;
single-request health/version checks;
contract validation без создания игровых сессий;
проверка схем ответов;
проверка release notes metadata;
минимальная telemetry smoke только с test marker, если команда уже так делает.
```

### Запрещено на production по умолчанию

```text
load/stress tests;
chaos/network degradation;
update rollback tests;
битые update archives;
массовое создание сессий;
многократные reconnect loops;
packet loss tests against real users/services;
тесты, меняющие состояние реальных пользователей;
эксперименты с неподписанными/битым updater package;
тесты, создающие шум в Sentry/telemetry без test marker.
```

Если staging отсутствует, Codex должен:

```text
создать mock/local test foundation;
описать blocker;
не пытаться заменить staging production-экспериментами.
```

---

## 5. Модель приоритизации

Использовать формулу:

```text
Priority = (2 * User Value + 2 * Risk Reduction + Frequency + Observability Gain + Testability Gain) / Effort
```

Оценки от 1 до 5.

Пояснения:

```text
User Value — насколько задача влияет на реальный пользовательский опыт.
Risk Reduction — насколько снижает риск релизного/продуктового фейла.
Frequency — как часто сценарий используется.
Observability Gain — насколько задача улучшает диагностику.
Testability Gain — насколько задача упрощает будущую автоматизацию.
Effort — сложность внедрения.
```

В первой итерации предпочтение задачам с высоким value/risk и effort <= 2–3.

---

## 6. Первый backlog, который Codex должен подтвердить/уточнить

```text
P0 — Release artifact QA gate
P0 — Production safety policy in docs/config
P0 — Bridge contract registry
P0 — Fake native host / WebView contract harness
P0 — Quick WebView bug verification/fixes
P1 — Update integrity/rollback test plan and mock foundation
P1 — Backend contract smoke with env-based config
P1 — Privacy/logging prohibited-pattern scanner
P2 — Windows smoke automation
P2 — Fake signaling/replay server design
P2 — Playability E2E oracle design
P2 — Network degradation suite design
P2 — Hardware/decoder matrix plan
```

Codex может менять приоритеты только после repository discovery и должен объяснить почему.

---

## 7. Ожидаемые файлы после первой итерации

Минимальный набор:

```text
docs/qa-automation/README.md
docs/qa-automation/test-strategy.md
docs/qa-automation/risk-register.md
docs/qa-automation/backlog.md
docs/qa-automation/bridge-contract.yaml
qa/artifact-gate/README.md
qa/artifact-gate/artifact_gate.ps1 или artifact_gate.py
qa/webview-contract/README.md
qa/webview-contract/fake-native-host.*
qa/webview-contract/*contract*.spec.*
```

Дополнительно, если уместно:

```text
docs/qa-automation/api-contract.md
docs/qa-automation/update-test-plan.md
docs/qa-automation/privacy-logging-checklist.md
qa/privacy-logging/prohibited-patterns.yaml
qa/backend-contract/schemas/*
CI job для artifact gate и WebView contract tests
```

---

## 8. Требования к artifact gate

Artifact gate должен проверять релизный package, а не только исходники.

Минимальные проверки:

```text
все критичные .exe подписаны;
подписи валидны;
installer/updater/uninstaller подписаны;
нет .map в production package, если policy запрещает;
нет .pdb в production package;
нет локальных путей C:\Users\, Downloads, C:\repo\;
нет подозрительных debug-флагов;
есть CEF resources;
есть критичные DLL;
версия package соответствует version resource/config;
нет файлов, которые явно относятся к dev/debug окружению.
```

Важно: если gate не может выполнить проверку подписи на non-Windows runner, он должен:

```text
сделать best-effort статическую проверку;
пометить проверку как requires-windows;
не выдавать false pass.
```

---

## 9. Требования к bridge contract

Bridge contract должен быть формальным файлом, например YAML.

Для каждой команды:

```text
command name;
direction: webview_to_native или native_to_webview;
payload schema;
required fields;
allowed values;
success event;
error event;
preconditions;
screen/component;
telemetry expectation;
test cases.
```

Пример:

```yaml
commands:
  SetCodec:
    direction: webview_to_native
    screen: settings
    payload:
      type: object
      required: [value]
      properties:
        value:
          type: integer
    expected_native_event: OnSetCodec
    tests:
      - changing codec sends SetCodec with selected numeric value
      - malformed native response does not crash UI
```

Codex должен извлечь реальные имена команд из исходников и подтвердить предварительный список из ТЗ.

---

## 10. Требования к fake native host

Fake native host нужен для тестирования WebView без запуска настоящего Windows-клиента.

Он должен уметь:

```text
мокать window.cefQuery;
записывать все request payloads;
отдавать success/failure callbacks;
генерировать DOM CustomEvent;
подсовывать валидные и malformed native events;
симулировать задержки;
симулировать unknown status/event;
проверять, что UI не падает.
```

Первый набор экранов:

```text
settings;
stream-settings;
update;
error-connect.
```

---

## 11. Требования к отчету Codex

В конце первой итерации Codex должен дать отчет в формате:

```text
1. Repository map
2. Что было проверено
3. Предварительные находки: confirmed / disproved / needs manual check
4. Что реализовано
5. Какие файлы изменены
6. Какие команды запущены
7. Результаты тестов
8. Что заблокировано
9. Production safety notes
10. Следующий backlog
```

Отчет не должен скрывать неудачи. Если тесты не запустились — указать причину и следующую команду для запуска.

---

## 12. Definition of Done первой итерации

Первая итерация считается успешной, если:

```text
есть docs/qa-automation;
есть risk-based backlog;
есть production safety policy;
есть начальный bridge-contract.yaml;
есть fake native host или технический план с partial implementation;
есть первые WebView contract tests или подготовленная структура под них;
есть artifact gate script или scaffold;
есть список blockers для staging/test accounts/Windows runner;
есть честный отчет о запущенных проверках.
```

Не требуется в первой итерации:

```text
полный E2E облачного гейминга;
полная hardware matrix;
network chaos suite;
полный fake signaling server;
полное покрытие всех экранов;
нагрузочное тестирование backend.
```

---

## 13. Запреты для Codex

Codex не должен:

```text
хардкодить production credentials;
делать destructive production-тесты;
создавать тесты, которые зависят от случайного текста UI без необходимости;
писать flaky sleep-based E2E вместо contract tests;
переписывать архитектуру проекта без необходимости;
удалять существующие тесты без объяснения;
скрывать failing tests;
делать вид, что неподтвержденные находки точно являются багами;
игнорировать AGENTS.md и существующие правила проекта;
загрязнять production telemetry без test markers;
добавлять секреты в репозиторий;
помечать проверку как passed, если она не запускалась.
```

---

## 14. Главный ожидаемый результат

После применения этих правил Codex должен не просто “написать тесты”, а создать управляемый QA automation foundation, который отвечает на вопросы:

```text
сломали ли мы релизный package;
сломали ли мы WebView/native contract;
сломали ли мы updater;
сможет ли пользователь начать играть;
будет ли понятная диагностика при ошибке;
безопасны ли логи;
что надо построить дальше для playability E2E.
```
