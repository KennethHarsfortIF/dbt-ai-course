# Prompt 3: Suggest Improvements (Concrete, Copy-Paste)

Use one of the prompts below exactly as-is.

## Prompt A: Review Marts Layer

```text
You are a senior analytics engineer performing a dbt code review.

Scope:
- models/marts/
- models/marts/schema.yml

Task:
Suggest improvements across:
1) Correctness and data quality
2) Maintainability and readability
3) Performance and scalability
4) Testing and documentation coverage

Output format:
- Prioritized findings: high, medium, low
- For each finding: issue, why it matters, concrete fix
- Include exact SQL or YAML snippets for the top 3 fixes
- End with a "quick wins in 30 minutes" section

Important:
- Focus on dim_customers.sql, fct_orders.sql, rpt_customer_ltv.sql, and rpt_saas_mrr.sql.
- Do not give generic advice; tie each finding to a specific file and column.
```

## Prompt B: Review Staging Test Strategy

```text
You are a senior analytics engineer reviewing dbt staging quality controls.

Scope:
- models/staging/schema.yml
- tests/assert_non_negative_order_amount.sql

Task:
Recommend concrete testing and documentation improvements with emphasis on:
1) Accepted values coverage
2) Relationship integrity coverage
3) Null handling checks for critical columns
4) Missing singular tests

Output format:
- Prioritized findings: high, medium, low
- For each finding: issue, why it matters, concrete fix
- Provide full YAML snippets for the top 3 schema.yml improvements
- Provide 1 new singular test SQL example

Important:
- Keep recommendations compatible with current dbt syntax already used in this project.
```

## Expected High-Quality Answer Example (Prompt A)

```text
High:
1) fct_orders grain risk if stg_payments becomes multi-row per order_id.
Why it matters: duplicates inflate revenue and success counts.
Fix: aggregate payments to one row per order_id before join, then join.

2) rpt_customer_ltv divide-by-zero logic should consistently use macro.
Why it matters: avoids inconsistent null/zero behavior across models.
Fix: enforce safe_divide macro for all ratio metrics.

Medium:
3) Add relationship tests from fct_orders.customer_id to dim_customers.customer_id.
Why it matters: catches orphaned facts.

Low:
4) Add clearer column descriptions for value_tier and total_mrr_usd.

Quick wins in 30 minutes:
- Add 2 schema tests and 3 column descriptions.
- Add one staging aggregation CTE in fct_orders.
```

## Common Bad Answer Example (Prompt A)

```text
- "Use better naming" with no file references.
- "Optimize queries" with no concrete SQL change.
- No severity levels.
- No quick wins section.
```

## Expected High-Quality Answer Example (Prompt B)

```text
High:
1) Add accepted_values tests for status-like fields not yet constrained.
2) Add singular test for duplicate business keys if source data quality degrades.

Medium:
3) Add explicit relationship tests for all foreign keys in stg_subscriptions.

Top snippet examples:
- Full YAML block adding accepted_values on status.
- Full YAML block adding relationships on account_id and plan_id.
- New singular SQL test to detect duplicate active subscriptions per account/plan/start_date.
```

## Common Bad Answer Example (Prompt B)

```text
- Recommends dbt-utils package without showing install/config changes.
- Uses test syntax incompatible with the project.
- Suggests deleting existing tests without justification.
```

