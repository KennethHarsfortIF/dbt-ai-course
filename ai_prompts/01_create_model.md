# Prompt 1: Create Model (Concrete, Copy-Paste)

Use one of the prompts below exactly as-is.

## Prompt A: Build Country Daily Revenue Model

```text
You are helping with a dbt project that runs on DuckDB.

Create this new model file:
- models/playground/rpt_country_daily_revenue.sql

Use these source models:
- fct_orders
- dim_customers

Business goal:
- Daily successful order performance by country.

Required output grain:
- One row per order_date and country.

Required columns:
- order_date
- country
- successful_orders
- successful_revenue
- avg_successful_order_value

Rules:
1) Use ref() for all model dependencies.
2) Count successful orders where is_successful_order is true.
3) successful_revenue should sum order_amount only for successful orders.
4) avg_successful_order_value should divide successful_revenue by successful_orders and handle divide-by-zero safely.
5) Keep SQL compatible with DuckDB.

Also update or create the relevant schema.yml entries with:
- model description
- not_null tests for order_date and country
- not_null test for successful_revenue

Return exactly:
1) Full SQL for models/playground/rpt_country_daily_revenue.sql
2) Full YAML changes for schema documentation/tests
3) A short assumptions section
```

## Prompt B: Build SaaS Active Account MRR Model

```text
You are helping with a dbt project that runs on DuckDB.

Create this new model file:
- models/playground/rpt_active_account_mrr.sql

Use these source models:
- int_account_subscriptions

Business goal:
- Report active subscription MRR by account.

Required output grain:
- One row per account_id.

Required columns:
- account_id
- account_name
- region
- active_subscriptions
- total_active_mrr_usd
- avg_active_mrr_per_subscription

Rules:
1) Use ref() for model dependencies.
2) Only include rows where status = 'active'.
3) total_active_mrr_usd is sum(mrr_usd).
4) avg_active_mrr_per_subscription handles divide-by-zero safely.
5) Keep SQL compatible with DuckDB.

Also update or create the relevant schema.yml entries with:
- model description
- unique + not_null tests on account_id
- not_null test on total_active_mrr_usd

Return exactly:
1) Full SQL for models/playground/rpt_active_account_mrr.sql
2) Full YAML changes for schema documentation/tests
3) A short assumptions section
```

## Expected High-Quality Answer Example (Prompt A)

Use this as a grading reference for a strong AI answer shape.

```text
SQL (models/playground/rpt_country_daily_revenue.sql):
- Uses ref('fct_orders') and ref('dim_customers').
- Joins on customer_id.
- Groups by order_date and country.
- Computes:
	- successful_orders = count(case when is_successful_order then 1 end)
	- successful_revenue = sum(case when is_successful_order then order_amount else 0 end)
	- avg_successful_order_value = successful_revenue / nullif(successful_orders, 0)

YAML changes (models/playground/schema.yml):
- Model description explains grain and business purpose.
- Tests include:
	- not_null on order_date
	- not_null on country
	- not_null on successful_revenue

Assumptions:
- Country is sourced from dim_customers and reflects latest known customer country.
- Multiple payments per order are already normalized in fct_orders logic.
```

## Common Bad Answer Example (Prompt A)

Use this to show students what to avoid.

```text
- Uses raw_orders directly instead of ref('fct_orders').
- Returns one row per order_id instead of one row per order_date + country.
- Computes avg_successful_order_value as sum(order_amount)/count(*) without filtering successful orders.
- Omits schema.yml changes and tests.
- Does not mention assumptions.
```

## Expected High-Quality Answer Example (Prompt B)

```text
SQL (models/playground/rpt_active_account_mrr.sql):
- Uses ref('int_account_subscriptions').
- Filters status = 'active'.
- Groups by account_id, account_name, region.
- Computes active_subscriptions, total_active_mrr_usd, avg_active_mrr_per_subscription with safe division.

YAML changes:
- unique + not_null on account_id.
- not_null on total_active_mrr_usd.

Assumptions:
- account_name and region are stable within account_id.
```

## Common Bad Answer Example (Prompt B)

```text
- Includes trial and cancelled rows in totals.
- Missing account_name and region in output.
- Uses non-DuckDB-specific syntax.
- Adds tests in prose only, not actual YAML.
```
