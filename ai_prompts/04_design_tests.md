# Prompt 4: Design Tests Example Prompts

These are facilitator examples and reference prompts.
Learners should write their own prompt using the exercise brief, not copy these by default.

## Example Prompt A: Strengthen SaaS Test Coverage

```text
You are a senior analytics engineer improving dbt test coverage.

Work in this project area:
- models/staging/schema.yml
- tests/

Focus on one model only:
- stg_subscriptions

Task:
1) Protect this business rule: subscription status values must stay within the expected domain and critical keys must be present.
2) Propose concrete test additions using dbt syntax already used in this project.
3) Add exactly:
   - 2 schema.yml test improvements for stg_subscriptions
   - 1 new singular SQL test in tests/
4) Explain why each proposed test matters.

Important:
- Keep recommendations compatible with the project's existing dbt style.
- Do not assume extra packages are installed.
- Keep the scope narrow to this one model and risk area.

Return exactly:
1) Short statement of the chosen risk
2) Full YAML changes
3) Full SQL for one new singular test file
4) Short explanation of why each change matters
```


## Expected High-Quality Answer Example (Prompt A)

```text
Chosen risk:
- stg_subscriptions needs tighter protection around valid status values and critical subscription keys.

YAML changes:
- Adds targeted accepted_values, not_null, or relationships coverage on stg_subscriptions.

Singular test:
- Adds a focused test such as duplicate active subscriptions by account_id, plan_id, start_date, or another clearly justified business rule.

Why it matters:
- Ties each test directly to downstream MRR correctness and referential integrity.
```

## Common Bad Answer Example (Prompt A)

```text
- Says "add more tests" without naming exact YAML or SQL changes.
- Recommends dbt-utils without explaining installation or project changes.
- Suggests tests across many models instead of staying on the chosen model.
- Gives no business reason for why the tests matter.
```
