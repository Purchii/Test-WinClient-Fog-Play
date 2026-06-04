# Техническое задание для Codex: QA automation для Windows-клиента MTC Fog Play

Версия документа: 1.0  
Дата: 2026-05-29  
Формат работы: Codex, мультиагентный goal-mode  
Проект: Windows-приложение на C++ с WebView/CEF внутри, продуктовая цель — облачный гейминг  
Текущий QA-контекст: тестирование сейчас преимущественно/полностью на production-среде; любые проверки, способные повлиять на пользователей, backend, update-chain или telemetry, должны быть безопасными, ограниченными и явно помеченными.

---

## 0. Готовый prompt для запуска Codex

Скопировать в новый диалог Codex и приложить этот файл к проекту/репозиторию.

```text
Ты работаешь в существующем проекте MTC Fog Play как мультиагентная команда QA automation / testability / release engineering.

Главная цель: спроектировать и начать внедрение многоуровневой автоматизации тестирования Windows-клиента облачного гейминга: release artifact gates, WebView↔native bridge contract tests, update tests, backend/API contract tests, Windows smoke, playability E2E, network degradation, hardware/decoder matrix и privacy/logging checks.

Работай в goal-mode. Не делай хаотичные изменения. Сначала изучи репозиторий, документацию, AGENTS.md, build/CI, структуру frontend/native/backend/test. Затем составь краткий execution plan, разложи работу между агентами, подтверди или опровергни предварительные находки из этого ТЗ по исходникам, после этого внедряй задачи по приоритету.

Приоритет на первый этап: максимальный value при минимальном effort:
1. release artifact QA gate;
2. проверка и фиксы быстрых WebView/bridge-багов;
3. формальный CEF/WebView bridge contract;
4. fake native host + contract tests для WebView;
5. update integrity/rollback test design;
6. backend contract smoke без опасного воздействия на production.

Важное ограничение: production-среда не должна использоваться для нагрузочных, разрушающих, массовых, update rollback, chaos/network и destructive-тестов. Если staging/mocks отсутствуют, реализуй безопасные mock/local тесты и явно зафиксируй blockers.

Ожидаемый результат первой итерации:
- карта репозитория и тестируемых слоев;
- подтвержденный risk register;
- backlog с value/risk/effort;
- добавленные/обновленные docs в docs/qa-automation/;
- минимальные artifact gate скрипты;
- bridge contract registry;
- fake native host или test harness для WebView;
- первые contract tests для settings/stream-settings/update/error-connect;
- отчет, какие тесты были запущены и что осталось заблокировано.
```

---

## 1. Контекст продукта

Продукт — Windows-клиент для облачного гейминга. Критичный пользовательский опыт:

1. пользователь запускает клиент;
2. клиент корректно проходит проверку версии/конфига;
3. пользователь запускает игровую сессию;
4. происходит backend/session orchestration;
5. WebSocket/WebRTC signaling проходит успешно;
6. появляется первый кадр;
7. работает ввод: клавиатура, мышь, возможно геймпад;
8. работает звук и, если включено, микрофон;
9. качество адаптируется под сеть;
10. ошибки понятны пользователю и дают recovery path;
11. обновление не ломает установленный клиент;
12. telemetry/logs помогают диагностировать проблему, но не утекают чувствительные данные.

QA-автоматизация должна проверять не только “backend не упал” и “UI открылся”, а пользовательские обещания продукта:

```text
Я могу быстро запустить игру.
Я вижу стабильную картинку.
Мой ввод работает.
Я понимаю, что происходит при ошибке.
Качество адаптируется к сети.
Сессия восстанавливается после кратковременных проблем.
Обновление не ломает клиент.
```

---

## 2. Предварительная информация по артефакту

По ранее изученному архиву был виден не полный source tree, а собранный Windows-дистрибутив:

```text
rds-client.exe
rds-updater.exe
CEF/WebView resources
React sourcemaps
WebRTC/SDL/Sentry/codec DLLs
updater/runtime resources
```

Codex должен перепроверить эти находки в исходниках/CI/release package. Не считать их истиной, пока они не подтверждены в репозитории.

### 2.1. Предварительно обнаруженные backend/native точки

В бинарях/ресурсах были видны строки и endpoints вида:

```text
https://fogplay.mts.ru/
wss://remoteplay.mts.ru/ws/
/orchestration/config/?app=rds-client
/check?application=rds-client&version=
/getUpdateAsync?application=rds-client
/log/rds?event=start_client
/log/rds?event=stream_stats
/api/release/client/?version=...
```

Требование: оформить backend/API contract tests так, чтобы base URL, токены, test user и environment задавались через env/config, без хардкода production-учеток и секретов.

### 2.2. Предварительно обнаруженные WebView/native bridge commands

Были видны команды через `window.cefQuery`:

```text
StartEvents
StartUpdateEvents
GetSettings
SetCodec
SetVendor
GetVendors
SetUseMic
SetMicrophone
GetMicrophones
SetGamepadType
SetRunAtStartup
Retry
close_session
set_autoquality
set_lowquality
set_midquality
set_highquality
set_ultraquality
apply_scale
set_fps
mouse_capture
client_set
client_input_set
close_stream_settings
display_network_information
disable_notifications
set_monitor_saves_interval
DownloadUpdate
Close
```

Требование: Codex должен подтвердить актуальный список команд по source code и оформить их как формальный bridge contract.

---

## 3. Главная цель работ

Создать основу QA automation для MTC Fog Play, которая:

1. ловит критичные регрессии до релиза;
2. проверяет release artifact, а не только исходники;
3. формализует контракт WebView↔native;
4. позволяет тестировать WebView-экраны без реального native-клиента;
5. проверяет backend/update контракты безопасно;
6. готовит фундамент для настоящих playability E2E cloud gaming сценариев;
7. не создает риска для production-среды;
8. дает понятный backlog с приоритетами value/risk/effort.

---

## 4. Non-goals для первой итерации

В первой итерации НЕ нужно:

1. строить полный E2E-фреймворк для всех игр и всех устройств;
2. запускать нагрузочные тесты на production;
3. ломать production update-chain;
4. делать network chaos на реальных пользователях;
5. покрывать все UI-состояния pixel-perfect visual regression;
6. автоматизировать всё через Windows UI tree, если можно дешевле проверить contract/harness;
7. писать хрупкие тесты на sleeps/timeouts вместо событий/логов/contract assertions.

---

## 5. Рекомендуемая модель приоритизации

Использовать не только Value/Effort, а расширенную модель:

```text
Priority Score = (2 * User Value + 2 * Risk Reduction + Frequency + Observability Gain + Testability Gain) / Effort
```

Оценки: 1–5.

Где:

- `User Value` — насколько сценарий влияет на пользователя;
- `Risk Reduction` — насколько задача снижает риск релизного фейла;
- `Frequency` — насколько часто сценарий встречается;
- `Observability Gain` — насколько задача улучшает диагностику;
- `Testability Gain` — насколько задача облегчает будущие тесты;
- `Effort` — сложность внедрения.

Если оценки спорные, агент-координатор фиксирует допущения и выбирает консервативный приоритет.

---

## 6. Роли агентов в мультиагентном goal-mode

Codex должен работать как команда. Если платформа goal-mode сама не создает агентов, симулировать роли явно в плане и review.

### 6.1. Coordinator / Goal Manager

Ответственность:

- прочитать AGENTS.md и проектную документацию;
- составить execution plan;
- разбить работу на этапы;
- следить, чтобы задачи не противоречили production safety;
- принимать решения по приоритетам;
- готовить итоговый отчет.

Выход:

```text
repo map
execution plan
risk register
iteration summary
```

### 6.2. QA Automation Architect

Ответственность:

- выбрать тестовые слои;
- определить test pyramid для продукта;
- спроектировать test harness;
- определить, что автоматизировать через unit/contract/API/E2E;
- не допустить хрупких UI-only тестов.

Выход:

```text
docs/qa-automation/test-strategy.md
backlog с value/risk/effort
DoD по тестовым слоям
```

### 6.3. WebView / Frontend Test Agent

Ответственность:

- найти frontend/WebView исходники;
- подтвердить bridge commands;
- сделать fake native host;
- добавить Playwright/Jest/Vitest tests, если стек проекта позволяет;
- проверить быстрые баги в settings/stream-settings/update/error-connect.

Выход:

```text
bridge-contract.yaml
webview contract tests
список подтвержденных/неподтвержденных багов
```

### 6.4. Native Windows / C++ Agent

Ответственность:

- изучить CEF integration;
- проверить native handlers для bridge commands;
- проверить updater flow;
- проверить signing/version/resources;
- предложить testability hooks: remote debugging, env override, structured logs.

Выход:

```text
native bridge mapping
updater test plan
testability requirements
```

### 6.5. Backend / API Contract Agent

Ответственность:

- найти API clients/endpoints;
- описать API contracts;
- сделать безопасные smoke/contract tests;
- учесть production-only ограничение;
- не отправлять массовые события и не создавать нагрузку.

Выход:

```text
backend-contract-tests
api-contract.md
prod safety notes
```

### 6.6. DevOps / Release Engineering Agent

Ответственность:

- найти build/packaging/CI;
- добавить artifact gate;
- проверить подписи, sourcemaps, PDB/local paths, DLL presence, version resources;
- подготовить запуск в CI/Windows runner.

Выход:

```text
qa/artifact-gate/*
CI job proposal
artifact-gate report format
```

### 6.7. Security / Privacy QA Agent

Ответственность:

- проверить логи/telemetry/Sentry на секреты и PII;
- проверить SDP/TURN/ICE/session/token masking;
- предложить log scrubber tests;
- проверить debug flags в production.

Выход:

```text
privacy-logging-checklist.md
privacy/logging tests или scanner
```

### 6.8. Reviewer / Red Team Agent

Ответственность:

- критически проверить изменения других агентов;
- искать flaky tests, hidden production risks, false positives;
- проверять, что DoD выполнен;
- не принимать “тест есть”, если oracle слабый.

Выход:

```text
review notes
risks left open
merge readiness assessment
```

---

## 7. Базовая стратегия тестирования

Рекомендуемые слои, сверху вниз по скорости/value.

### 7.1. Release artifact QA gate

Проверяет собранный дистрибутив до релиза.

Обязательные проверки:

```text
все .exe подписаны валидной подписью;
критичные .dll подписаны, если это policy проекта;
timestamp подписи валиден;
version resource соответствует build/version;
нет .map в production-дистрибутиве;
нет .pdb в production-дистрибутиве;
нет локальных путей вида C:\Users\, C:\repo\, Downloads;
нет dev/debug config по умолчанию;
есть все нужные CEF/resources файлы;
есть updater/uninstaller/client binaries;
installer/updater/uninstaller подписаны;
архив обновления не содержит path traversal;
размеры/хэши критичных файлов фиксируются в отчете.
```

Ожидаемая реализация:

```text
qa/artifact-gate/
  README.md
  artifact_gate.ps1 или artifact_gate.py
  rules.yaml
  sample-report.json
```

Acceptance criteria:

```text
artifact gate можно запустить локально на Windows;
artifact gate падает при найденном production-critical нарушении;
есть машинно-читаемый report JSON;
есть human-readable summary;
CI может запускать gate после сборки/упаковки.
```

Приоритет: очень высокий.  
Value: 5. Risk reduction: 5. Effort: 2.

---

### 7.2. WebView↔native bridge contract tests

Цель: формализовать протокол между React/WebView и C++/CEF host.

Создать contract registry:

```text
docs/qa-automation/bridge-contract.yaml
```

Пример структуры:

```yaml
commands:
  GetSettings:
    direction: webview_to_native
    payload_schema: {}
    expected_native_events:
      - OnGetSettings

  SetCodec:
    direction: webview_to_native
    payload_schema:
      type: object
      required: [value]
      properties:
        value:
          type: number
    expected_native_events:
      - OnGetSettings

  set_fps:
    direction: webview_to_native
    payload_schema:
      type: object
      required: [fps]
      properties:
        fps:
          type: number
          enum: [30, 60]

  mouse_capture:
    direction: webview_to_native
    payload_schema:
      type: object
      required: [enable]
      properties:
        enable:
          type: boolean
    allowed_when:
      clients.allowed: true
      settings.grabber_name: WinCaptureAPI
```

Требования:

```text
каждая команда имеет payload schema;
каждое native event имеет detail schema;
есть explicit fallback для неизвестных/битых events;
frontend не отправляет неизвестные команды;
native handlers соответствуют frontend commands;
тесты проверяют malformed JSON, missing fields, unexpected values.
```

Приоритет: очень высокий.  
Value: 5. Risk reduction: 5. Effort: 2.

---

### 7.3. Fake native host для WebView

Нужен тестовый harness, позволяющий запускать WebView-экраны без native-клиента.

Минимальная идея:

```js
window.cefQuery = ({ request, onSuccess, onFailure }) => {
  const command = JSON.parse(request);
  window.__recordedCefCommands.push(command);
  if (onSuccess) onSuccess('ok');
};

function emitNativeEvent(name, detail) {
  document.dispatchEvent(new CustomEvent(name, {
    detail: JSON.stringify(detail),
  }));
}
```

Покрыть экраны:

```text
settings
stream-settings
update
error-connect
```

Минимальные тесты settings:

```text
GetSettings вызывается при открытии;
GetVendors вызывается на вкладке трансляции;
GetMicrophones вызывается на вкладке трансляции;
SetCodec отправляет корректный payload;
SetVendor отправляет корректный payload;
SetUseMic неактивен, если микрофон недоступен;
SetGamepadType отправляет корректный payload;
SetRunAtStartup отправляет корректный payload;
release notes загружаются после прихода settings.version.
```

Минимальные тесты stream-settings:

```text
StartEvents вызывается при открытии;
set_lowquality/set_midquality/set_highquality/set_ultraquality/set_autoquality отправляются корректно;
set_fps отправляет fps;
apply_scale отправляет scale;
display_network_information отправляет expected payload;
disable_notifications отправляет expected payload;
set_monitor_saves_interval отправляет expected payload;
mouse_capture disabled при clients.allowed=false;
client_set/client_input_set отправляют корректные значения;
close_session отправляется при закрытии сессии.
```

Минимальные тесты update:

```text
StartUpdateEvents вызывается при открытии;
update_progress 0/50/100 корректно отображается;
update_get_status updatePreparing/updatePrepared/error корректно отображается;
unknown status не ломает UI;
DownloadUpdate вызывается при retry;
Close вызывается при закрытии.
```

Минимальные тесты error-connect:

```text
Retry отправляет Retry;
кнопка retry не зависает навсегда при отсутствии ответа;
ошибка отображает понятный recovery path.
```

Приоритет: очень высокий.  
Value: 5. Risk reduction: 4. Effort: 2.

---

### 7.4. Быстрые WebView-баги для проверки Codex

Codex должен проверить по исходникам, актуальны ли эти места. Если подтверждаются — исправить и покрыть тестами. Если не подтверждаются — отметить как false positive с объяснением.

#### 7.4.1. `useMemo` используется для side effects/listeners

Предварительная находка:

```tsx
useMemo(() => {
  document.addEventListener('OnGetVendors', handleGetVendors);
  document.addEventListener('OnGetMicrophones', handleGetMicrophones);

  getVendors();
  getMicrophones();

  return () => {
    document.removeEventListener('OnGetVendors', handleGetVendors);
    document.removeEventListener('OnGetMicrophones', handleGetMicrophones);
  }
}, [])
```

Ожидание: заменить на `useEffect`, если код действительно такой.

Acceptance test:

```text
переключить вкладку туда-обратно несколько раз;
сгенерировать OnGetVendors;
handler должен сработать один раз, не N раз.
```

#### 7.4.2. Release notes effect зависит от settings.version, но dependency array пустой

Предварительная проблема: если `settings.version` приходит после первого render, release notes могут не загрузиться.

Ожидание: добавить зависимость от `settings.version` и состояния загрузки.

Acceptance test:

```text
открыть Updates до прихода OnGetSettings;
задержать OnGetSettings;
после прихода version release notes должны загрузиться.
```

#### 7.4.3. Подозрительное disabled-состояние `mouse_capture`

Предварительная находка:

```tsx
disabled={mouseCapture.current !== null ?? !clients.allowed}
```

Ожидание, если подтверждается:

```tsx
disabled={mouseCapture.current !== null || !clients.allowed}
```

Acceptance test:

```text
clients.allowed=false;
settings.grabber_name=WinCaptureAPI;
Пользовательский курсор disabled;
клик не отправляет mouse_capture.
```

#### 7.4.4. Индикатор качества соединения захардкожен как `good`

Предварительная находка:

```tsx
<ConnectInfo quality="good" ... />
```

Ожидание: либо зафиксировать как product debt, либо добавить derived quality на основе stream metrics.

Минимальная безопасная задача первой итерации:

```text
описать mapping metrics -> connection_quality;
добавить тесты на отображение warning/bad, если в проекте уже есть нужные данные.
```

#### 7.4.5. Error retry loading может не сбрасываться

Предварительная находка:

```tsx
setLoading(true);
callback();
```

Без сброса loading пользователь может потерять retry.

Ожидание:

```text
сброс по native event, route change или timeout fallback;
покрыть тестом.
```

---

### 7.5. Updater integrity / rollback tests

Updater является критичным пользовательским сценарием. Ошибка обновления может полностью сломать клиент.

Тестировать через mock/local update server и controlled package, не через production.

Сценарии:

```text
happy path update;
битый update archive;
неполный download;
archive без rds-client.exe;
archive со старой версией;
archive с неподписанным exe;
archive с path traversal ../ или ..\;
очень длинные пути;
locked files;
недостаточно места на диске;
kill updater во время unpack/apply;
network drop во время download;
rollback после неуспешного update;
повторный запуск после failed update;
сохранение рабочей предыдущей версии.
```

UI status contract для update:

```text
Native status -> UI state -> текст -> кнопки -> telemetry event
```

Проверить статусы:

```text
updatePreparing
updatePrepared
updateReady
updateRequired
noUpdate
error
unknown status
```

Acceptance criteria:

```text
после неудачного update предыдущий клиент запускается;
пользователь видит понятную ошибку;
retry не вызывает бесконечный silent loop;
неподписанный или битый update package не применяется;
отчет теста содержит шаги, версию до/после, exit codes, логи.
```

Приоритет: высокий.  
Value: 5. Risk reduction: 5. Effort: 3.

---

### 7.6. Backend/API contract tests

Покрыть контракты, а не только HTTP 200.

Кандидаты:

```text
config/orchestration;
check client version;
get update info;
release notes;
start_client log;
stream_stats log;
websocket/signaling handshake smoke.
```

Production safety:

```text
все тесты должны иметь отдельный test user / test marker;
частота запусков ограничена;
нет load/stress;
нет массовой генерации stream_stats;
нет destructive actions;
base URL и токены только через env;
в отчете явно указать, какие тесты safe for production, а какие требуют staging/mock.
```

Acceptance criteria:

```text
contract tests валидируют schema;
тесты проверяют обязательные поля;
ошибки auth/version/session корректно классифицируются;
тесты не завязаны на реальные пользовательские данные;
есть mock mode, если production endpoint недоступен.
```

Приоритет: высокий.  
Value: 5. Risk reduction: 5. Effort: 3.

---

### 7.7. Windows smoke tests

Цель: проверить минимальную жизнеспособность клиента на Windows runner/agent.

Сценарии:

```text
install;
launch;
process started;
main window/WebView available;
no crash during startup;
settings screen opens;
logs created;
app closes normally;
uninstall;
crashpad/Sentry local artifacts handled correctly;
update smoke на controlled package.
```

Рекомендуемый подход:

```text
для WebView — CEF remote debugging в test build;
для native window — FlaUI/pywinauto/Appium только там, где CDP недоступен;
для процессов/логов — PowerShell/Python scripts;
не строить весь UI automation на координатах и sleeps.
```

Testability hook request:

```text
CLI/env флаг для CEF remote debugging;
env override backend URL;
test mode для fake/mocked backend;
structured logs в JSON;
app version/build id в логах;
session/test correlation id.
```

Приоритет: средне-высокий.  
Value: 4. Risk reduction: 5. Effort: 3.

---

### 7.8. Playability E2E oracle

Классический E2E “запустилось” недостаточен. Для cloud gaming нужен oracle: можно ли играть.

Метрики:

```text
Time to app ready;
Time to session allocated;
Time to WebSocket connected;
Time to PeerConnection connected;
Time to first video packet;
Time to first decoded frame;
Time to first rendered frame;
input response latency;
FPS stability;
bitrate stability;
video freeze count;
audio underrun/drop count;
reconnect success rate;
black screen detection count;
quality downgrade/upgrade count;
decoder fallback used;
crash-free session.
```

Тестовая игра/сцена должна иметь:

```text
deterministic moving marker;
visual response на keyboard/mouse input;
audio marker;
overlay with session_id/build_id;
простую повторяемую сцену без randomness.
```

Acceptance criteria:

```text
тест определяет first frame;
тест подтверждает, что картинка не статичная;
тест подтверждает input response;
тест подтверждает audio marker, если есть audio testing setup;
при проблеме тест сохраняет скриншот/видео/логи/metrics.
```

Приоритет: стратегически высокий, но не первый из-за Effort.  
Value: 5. Risk reduction: 5. Effort: 4–5.

---

### 7.9. Network degradation tests

Тестировать не просто “не упало”, а реакцию клиента.

Сценарии:

```text
packet loss 1%, 3%, 5%, 10%;
latency 50/100/150/250 ms;
jitter;
bandwidth throttling;
short disconnect;
long disconnect;
UDP blocked;
TURN-only;
DNS failure;
WebSocket disconnect;
STUN/TURN malformed;
server no video;
no key frames;
black screen.
```

Ожидаемые реакции:

```text
FEC/NACK/key frame requests растут при потере пакетов;
quality degrade при плохой сети;
quality recover после восстановления;
UI показывает warning/bad, а не always good;
reconnect работает или пользователь получает понятную ошибку;
нет crash/hang/silent failure.
```

Требует staging/mock/fake signaling или изолированной лаборатории. Не запускать destructive/chaos tests на production.

Приоритет: высокий после contract/update фундамента.  
Value: 5. Risk reduction: 5. Effort: 4.

---

### 7.10. Hardware / decoder matrix

По предварительным строкам в артефакте были видны варианты:

```text
nvidia
nvidia_legacy8
amd
intel
software
H264
H265
banned_intel_cards
min_nvidia_driver_version
unsupported codec/resolution paths
```

Минимальная матрица:

```text
NVIDIA modern driver + H.264;
NVIDIA modern driver + H.265;
NVIDIA old driver ниже min version;
NVIDIA legacy path;
AMD + H.264;
AMD + H.265;
Intel supported;
Intel banned chipset -> software fallback;
No hardware decoder -> software;
Unsupported H.265 -> fallback или понятная ошибка;
Dynamic resolution change на legacy decoder.
```

Проверять:

```text
выбран правильный decoder;
fallback сработал;
stream_stats содержит codec/vendor/decoder;
UI не предлагает невозможные комбинации;
при unsupported codec нет silent black screen.
```

Приоритет: высокий, но дорогой.  
Value: 5. Risk reduction: 5. Effort: 5.

---

### 7.11. Privacy / logging QA

Проверить, что production logs/telemetry/Sentry не содержат чувствительные данные.

Риски:

```text
SDP;
TURN credentials;
ICE candidates;
локальные IP;
session ids;
tokens;
GUID/user identifiers;
названия устройств;
пути пользователя;
raw websocket messages;
микрофон/audio device data;
Sentry attachments с secrets.
```

Требования:

```text
debug logs выключены в production по умолчанию;
чувствительные поля маскируются;
логи содержат correlation id, build id, session id/test id, но не секреты;
Sentry events scrubbed;
crash attachments безопасны;
есть scanner/test на prohibited patterns.
```

Приоритет: высокий.  
Value: 4. Risk reduction: 5. Effort: 2–3.

---

## 8. Рекомендуемая структура файлов в репозитории

Codex должен адаптировать под реальную структуру проекта. Если такой структуры нет — создать минимально аккуратно.

```text
docs/
  qa-automation/
    README.md
    test-strategy.md
    risk-register.md
    backlog.md
    bridge-contract.yaml
    api-contract.md
    update-test-plan.md
    playability-e2e-plan.md
    privacy-logging-checklist.md

qa/
  artifact-gate/
    README.md
    artifact_gate.ps1 или artifact_gate.py
    rules.yaml
    sample-report.json

  webview-contract/
    README.md
    fake-native-host.ts или fake-native-host.js
    bridge-contract.spec.ts
    fixtures/
      settings.json
      stream-stats-good.json
      stream-stats-bad.json
      update-statuses.json

  backend-contract/
    README.md
    api-contract.spec.*
    schemas/

  update-tests/
    README.md
    mock-update-server.*
    fixtures/

  windows-smoke/
    README.md
    smoke-launch.ps1
    collect-logs.ps1

  privacy-logging/
    README.md
    prohibited-patterns.yaml
    log-scrubber-test.*
```

Если в проекте уже есть `tests/`, `e2e/`, `qa/`, `packages/` или монорепозиторная структура, использовать существующий стиль.

---

## 9. Backlog первой очереди

| ID | Задача | User Value | Risk Reduction | Effort | Priority | Комментарий |
|---|---|---:|---:|---:|---:|---|
| QA-001 | Repo/testability discovery | 5 | 5 | 1 | 10.0 | Сначала понять проект, build, CI, frontend/native/backend |
| QA-002 | Release artifact QA gate | 5 | 5 | 2 | 5.0 | Подписи, sourcemaps, PDB/local paths, DLL/resources |
| QA-003 | Confirm/fix quick WebView bugs | 4 | 4 | 1 | 8.0 | useMemo/useEffect, release notes, mouse_capture, retry loading |
| QA-004 | Bridge contract registry | 5 | 5 | 2 | 5.0 | Формальный контракт команд/events/payloads |
| QA-005 | Fake native host | 5 | 4 | 2 | 4.5 | Позволяет дешево тестировать UI logic |
| QA-006 | WebView contract tests: settings | 4 | 4 | 2 | 4.0 | Get/Set settings, vendors, microphones |
| QA-007 | WebView contract tests: stream-settings | 5 | 5 | 2 | 5.0 | Качество, FPS, cursor, clients, close session |
| QA-008 | WebView contract tests: update/error | 4 | 5 | 2 | 4.5 | Update statuses, progress, retry/error states |
| QA-009 | Update integrity/rollback plan + mock foundation | 5 | 5 | 3 | 3.3 | Сначала mock/local, не production |
| QA-010 | Backend contract smoke safe mode | 5 | 5 | 3 | 3.3 | Production-safe, env-configured |
| QA-011 | Privacy/logging scanner | 4 | 5 | 2 | 4.5 | Секреты/PII в logs/Sentry |
| QA-012 | Windows smoke design | 4 | 5 | 3 | 3.0 | Install/launch/close/logs/crash |
| QA-013 | Playability E2E plan | 5 | 5 | 4 | 2.5 | First frame/input/audio/freeze oracle |
| QA-014 | Network degradation plan | 5 | 5 | 4 | 2.5 | Packet loss/latency/TURN/reconnect |
| QA-015 | Hardware/decoder matrix plan | 5 | 5 | 5 | 2.0 | NVIDIA/AMD/Intel/software/H264/H265 |

Codex может уточнить оценки после discovery, но должен объяснить изменения.

---

## 10. Sprint plan

### Sprint 0 — Discovery + быстрые gates/fixes

Цель: быстро снизить релизные риски.

Задачи:

```text
прочитать AGENTS.md и docs;
составить repo map;
найти frontend/native/updater/build/CI;
подтвердить/опровергнуть предварительные находки;
добавить docs/qa-automation skeleton;
добавить artifact gate skeleton;
проверить подписи и source maps policy;
проверить quick WebView bugs;
пофиксить подтвержденные low-effort bugs;
добавить unit/contract tests на фиксы.
```

Definition of Done:

```text
есть risk-register.md;
есть backlog.md;
есть artifact gate script или MVP;
есть список подтвержденных/неподтвержденных багов;
первые тесты проходят локально;
нет production-destructive изменений.
```

### Sprint 1 — Bridge contract + fake native host

Цель: стабилизировать самый дешевый и важный слой автоматизации.

Задачи:

```text
описать bridge-contract.yaml;
сделать fake native host;
покрыть settings/stream-settings/update/error-connect;
проверить malformed native events;
добавить data-testid/test selectors, если нужно и безопасно;
подготовить запуск в CI.
```

Definition of Done:

```text
каждая подтвержденная bridge command имеет schema;
каждый ключевой экран имеет contract tests;
тесты не требуют настоящего C++ клиента;
тесты стабильны без sleeps;
CI job documented или добавлен.
```

### Sprint 2 — Update + backend contract

Цель: закрыть критичные операционные сценарии.

Задачи:

```text
mock update server;
update package fixtures;
happy path + corrupt package + rollback design;
backend contract tests в safe mode;
API schemas;
telemetry schema checks.
```

Definition of Done:

```text
update tests не используют production destructive flow;
backend tests запускаются с env config;
unsafe tests clearly skipped unless staging enabled;
отчеты машинно-читаемые.
```

### Sprint 3 — Windows smoke

Цель: проверить реальный Windows-клиент.

Задачи:

```text
Windows runner/agent requirements;
install/launch/close/uninstall;
log collection;
crash detection;
CEF remote debugging testability hook;
settings screen smoke.
```

Definition of Done:

```text
smoke можно запустить на Windows;
логи и артефакты сохраняются;
failure дает понятный report;
flaky sleep-based logic минимизирована.
```

### Sprint 4 — Playability / network / hardware

Цель: перейти к настоящему cloud gaming quality.

Задачи:

```text
test game/scene requirements;
first frame detector;
input response detector;
audio marker detector;
network degradation lab;
hardware/decoder matrix;
playability score.
```

Definition of Done:

```text
есть proof-of-concept playability E2E;
есть план лаборатории/стендов;
есть metrics thresholds;
есть troubleshooting artifacts.
```

---

## 11. Testability requirements к разработке

Codex должен оформить эти требования в docs и, если возможно, добавить минимальные hooks.

### 11.1. CEF/WebView

```text
test build flag для CEF remote debugging;
стабильные data-testid;
mockable window.cefQuery;
явный bridge contract;
structured native events;
ошибки bridge возвращаются через понятные events/error codes.
```

### 11.2. Backend/environment

```text
base URL override через env/config;
test user/test token через secure env;
correlation id для тестов;
mock/staging mode;
ограничение частоты production-safe тестов.
```

### 11.3. Logs/telemetry

```text
JSON logs;
app_version;
build_id;
session_id/test_correlation_id;
backend_env;
stream_id;
codec;
decoder/vendor;
fps;
bitrate;
packet_loss;
latency;
reconnect_count;
error_code;
no secrets/PII.
```

### 11.4. Updater

```text
mock update URL override;
controlled update package;
dry-run/check-only mode если возможен;
rollback status exposed in logs;
exit codes documented;
update status events documented.
```

---

## 12. Production safety rules

Так как сейчас тестирование завязано на production, Codex обязан соблюдать правила:

```text
не запускать нагрузочные тесты;
не запускать chaos/network destructive tests на production;
не делать массовую генерацию логов/stream_stats;
не проверять rollback/update на production package без явного controlled стенда;
не использовать реальные пользовательские аккаунты;
не хранить токены в коде;
не добавлять debug flags в production по умолчанию;
все production-safe тесты должны быть read-only или low-impact;
каждый production test должен иметь test marker/correlation id;
unsafe tests должны быть skipped by default.
```

Если staging отсутствует:

```text
сделать mock/local implementation;
задокументировать blocker;
предложить минимальный staging/test account requirement;
не блокировать весь прогресс из-за отсутствия staging.
```

---

## 13. Quality bar для автотестов

Тест считается хорошим, если:

```text
имеет понятный oracle;
не полагается на координаты экрана;
не полагается на случайные sleeps;
сохраняет диагностические артефакты;
имеет clear failure message;
не зависит от production state без необходимости;
может запускаться повторно;
не оставляет мусор в системе;
не ломает installed client;
не скрывает flaky behavior через retry без анализа.
```

Запрещено:

```text
автоматизация ради покрытия без реального value;
большие E2E перед contract foundation;
хардкод секретов;
скрытый доступ к production endpoints;
добавление тестовых дыр в production behavior;
игнорирование failed artifact gate;
коммиты без описания, что проверено.
```

---

## 14. Формат итогового отчета Codex после первой итерации

Codex должен завершить работу отчетом:

```text
1. Что изучено
   - структура проекта;
   - найденные frontend/native/backend/update/CI части.

2. Что подтверждено из предварительных находок
   - подтверждено;
   - не подтверждено;
   - требует ручной проверки.

3. Что реализовано
   - файлы;
   - тесты;
   - скрипты;
   - docs.

4. Что запущено
   - команды;
   - результаты;
   - failures;
   - flaky/blocked.

5. Риски
   - production safety;
   - testability blockers;
   - missing staging;
   - missing Windows runner;
   - missing test accounts.

6. Следующие задачи
   - prioritized backlog;
   - recommended next sprint.
```

---

## 15. Ожидаемые артефакты первой поставки

Минимум:

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

Желательно:

```text
docs/qa-automation/api-contract.md
docs/qa-automation/update-test-plan.md
docs/qa-automation/privacy-logging-checklist.md
qa/privacy-logging/prohibited-patterns.yaml
qa/backend-contract/schemas/*
CI job для artifact gate и webview contract tests
```

---

## 16. Критерии приемки всего направления

Направление QA automation считается успешно начатым, если:

```text
1. Есть понятная тестовая стратегия по слоям.
2. Есть risk-based backlog с value/risk/effort.
3. Есть artifact gate, который реально ловит релизные проблемы.
4. Есть формальный bridge contract.
5. Есть WebView contract tests без запуска настоящего native-клиента.
6. Есть список testability gaps к разработке.
7. Есть production safety policy.
8. Есть понятный план update/backend/windows/playability/network/hardware следующих этапов.
9. Первые тесты можно запустить локально или в CI.
10. Итоговый отчет честно фиксирует, что сделано, что не сделано и что заблокировано.
```

---

## 17. Рекомендуемые первые команды для Codex

Codex должен адаптировать команды под реальный репозиторий, но порядок такой:

```text
1. Прочитать AGENTS.md, README, docs, package/build/CI files.
2. Найти frontend/WebView исходники: settings, stream-settings, update, error-connect.
3. Найти native CEF bridge handlers.
4. Найти updater source/build/package scripts.
5. Найти backend/API client code.
6. Найти existing tests.
7. Найти CI/CD.
8. Составить repo map и plan.
9. Подтвердить/опровергнуть quick findings.
10. Внедрить Sprint 0 задачи.
```

---

## 18. Главная рекомендация

Не начинать с большого E2E через реальную игру. Для этого проекта самый правильный старт:

```text
release artifact gate
+ bridge contract
+ fake native host
+ быстрые WebView fixes
+ safe backend/update contracts
```

Только после этого переходить к дорогим слоям:

```text
Windows smoke
playability E2E
network degradation
hardware/decoder matrix
```

Такой порядок даст быстрый прирост качества, снизит релизные риски и подготовит основу для серьезной автоматизации облачного гейминга.
