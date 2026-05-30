# Codex communication and reasoning policy

## Purpose

This policy defines how Codex must communicate with the project owner during the MTC Fog Play Windows client QA automation project.

The project owner communicates in Russian. Codex must make the work understandable for the owner while preserving technical precision for code, commands and machine-readable artifacts.

## Language rules

- User-facing answers, plans, status updates, final reports, blockers and questions must be written in Russian by default.
- Technical identifiers must stay unchanged: file paths, class names, method names, enum values, CLI flags, environment variables, branch names, commands, test names and error codes.
- Code should follow the repository language/style conventions. Do not translate code identifiers unless the task explicitly requires it.
- Machine-readable configuration, JSON/YAML keys, test metadata values and scripts should remain English unless the repository already uses Russian naming.
- Documentation may be in English if it is intended primarily for Codex, CI or engineering tooling. When reporting the result to the user, summarize it in Russian.
- If a task affects business/product decisions, add a Russian summary even if the underlying technical document is English.

## Reasoning / “размышления” rules

Codex must not expose private chain-of-thought or raw scratchpad reasoning.

Instead, Codex must provide a concise Russian reasoning summary that is safe to show and useful for review:

- key assumptions;
- why this approach was chosen;
- alternatives considered, if relevant;
- production-safety implications;
- risks and mitigations;
- verification performed;
- what remains uncertain or blocked.

Do not write long hidden-style internal monologues. Do not fabricate certainty. If a conclusion is based on incomplete evidence, say so clearly.

## Required response structure for substantial tasks

For non-trivial tasks, final reports must be in Russian and include:

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

For short status updates, Russian is still required, but the structure can be brief.

## Stop-and-ask language

Any stop-and-ask question must be written in Russian and must explain:

- what decision is needed;
- why Codex cannot safely proceed without it;
- what options are available;
- which option Codex recommends and why.

## Examples

Good:

```text
Режим работы: BOUNDED_AUTONOMOUS.
Сделал ProdGuard skeleton и dry-run проверки. Выбрал config-based metadata, потому что в репозитории пока нет стабильного тестового фреймворка. Production-impacting тесты не запускались.
```

Bad:

```text
I implemented everything. Looks fine.
```

Bad:

```text
Here is my full internal reasoning...
```
