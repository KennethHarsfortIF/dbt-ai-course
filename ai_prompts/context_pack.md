# AI Context Pack (Paste Before Prompting)

Use this context when asking an AI assistant to work on this project.

## Project Goal

This is a teaching dbt project using DuckDB and local seed data.

## Modeling Rules

1. Prefer layered modeling: `staging -> intermediate -> marts`.
2. Use `ref()` for model dependencies.
3. Keep SQL readable and deterministic.
4. Add tests and documentation when creating or changing models.
5. Avoid warehouse-specific SQL unless needed.

## File Conventions

- New report-style models: `models/marts/rpt_*.sql`
- New intermediate logic: `models/intermediate/int_*.sql`
- New learning experiments: `models/playground/*.sql`
- Model docs/tests: update matching `schema.yml`

## Available Base Models

- `stg_customers`
- `stg_orders`
- `stg_payments`
- `stg_accounts`
- `stg_plans`
- `stg_subscriptions`
- `int_customer_orders`
- `int_account_subscriptions`
- `dim_customers`
- `fct_orders`
- `rpt_customer_ltv`
- `rpt_saas_mrr`

## Recommended Prompt Workflow

1. Paste this context pack first.
2. Paste one of the concrete prompts from `01_create_model.md`, `02_explain_code.md`, or `03_suggest_improvements.md`.
3. Ask the AI to return full file content blocks so the result is copy-paste ready.

## Quality Expectations

- Include at least `not_null` tests for key fields.
- Use `unique` on natural grain keys when appropriate.
- Explain assumptions in model descriptions.
