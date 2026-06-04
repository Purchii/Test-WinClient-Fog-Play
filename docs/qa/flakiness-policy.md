# Flakiness policy

- Blind retry is not a fix.
- Retry must have a strict limit and a reason.
- Retry must not create extra production sessions outside budget.
- Prefer observable waits over arbitrary sleep.
- Flaky tests must be stabilized or quarantined with reason.
- Quarantine must have a follow-up task.
