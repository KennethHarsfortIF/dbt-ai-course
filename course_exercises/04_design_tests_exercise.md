# Exercise 4: Design Tests Prompt

## Objective

Use AI to design and implement targeted dbt tests.

## Task

Ask AI to add tests for one specific model and one specific risk in the project.

Choose one of these example directions:

- Protect `stg_subscriptions` against invalid `status` values or missing keys
- Protect `fct_orders` against order and payment logic issues
- Protect `rpt_saas_mrr` against null or inconsistent reporting dimensions

Your prompt should ask AI to work with:

- `models/staging/schema.yml`
- `models/marts/schema.yml`
- `tests/`

Requirements:

- Name the chosen model and the exact business rule or risk to protect
- Propose specific `schema.yml` test additions for that risk
- Add one new singular SQL test
- Explain why each proposed test matters
- Keep the scope narrow and practical for this demo project

## Submission Checklist

1. New tests use dbt syntax already used in this project
2. At least one schema test and one singular test are added for the chosen risk
3. `dbt test` passes for the new coverage, or failures are explained clearly