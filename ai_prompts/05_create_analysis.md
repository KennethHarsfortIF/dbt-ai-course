# Prompt 5: Create Analysis Example Prompts

These are facilitator examples and reference prompts.
Learners should write their own prompt using the exercise brief, not copy these by default.

## Example Prompt A: Customer Revenue Mix Analysis

```text
You are helping with a dbt project that runs on DuckDB.

Create this new analysis file:
- analyses/customer_revenue_mix.sql

Use these models:
- dim_customers
- rpt_customer_ltv

Business question:
- Which customer segments and countries contribute the most completed revenue?

Required output grain:
- One row per country and segment.

Required columns:
- country
- segment
- customers
- total_completed_revenue
- avg_revenue_per_customer
- high_value_customers

Rules:
1) Use ref() for all model dependencies.
2) customers should count distinct customer_id.
3) high_value_customers should count customers where value_tier = 'high_value'.
4) Sort by total_completed_revenue descending.
5) Keep SQL compatible with DuckDB.

Also include a short interpretation section that explains what patterns a stakeholder should look for in the result.

Return exactly:
1) Full SQL for analyses/customer_revenue_mix.sql
2) A short assumptions section
3) A short interpretation section
```

## Example Prompt B: Account Region MRR Analysis

```text
You are helping with a dbt project that runs on DuckDB.

Create this new analysis file:
- analyses/account_region_mrr_summary.sql

Use these models:
- int_account_subscriptions
- rpt_saas_mrr

Business question:
- Which account regions have the highest active MRR and subscription counts?

Required output grain:
- One row per region.

Required columns:
- region
- active_subscriptions
- total_active_mrr_usd
- avg_active_mrr_usd
- active_accounts

Rules:
1) Use ref() for all model dependencies.
2) Only active subscriptions should contribute to the active metrics.
3) active_accounts should count distinct account_id.
4) Sort by total_active_mrr_usd descending.
5) Keep SQL compatible with DuckDB.

Also include a short interpretation section that explains what patterns a stakeholder should look for in the result.

Return exactly:
1) Full SQL for analyses/account_region_mrr_summary.sql
2) A short assumptions section
3) A short interpretation section
```

## Expected High-Quality Answer Example (Prompt A)

```text
SQL:
- Uses ref('dim_customers') and ref('rpt_customer_ltv').
- Groups by country and segment.
- Calculates distinct customers, total_completed_revenue, avg_revenue_per_customer, and high_value_customers.
- Sorts by total_completed_revenue descending.

Assumptions:
- country and segment come from the modeled customer layer.
- completed_revenue is already prepared consistently in the marts layer.

Interpretation:
- Helps a stakeholder spot which country/segment combinations drive the most revenue and where high-value customer concentration is strongest.
```

## Common Bad Answer Example (Prompt A)

```text
- Queries raw_customers or raw_orders directly instead of modeled tables.
- Returns one row per customer_id instead of country + segment.
- Omits sorting, assumptions, or interpretation.
- Mixes total orders with revenue without defining the metric clearly.
```

## Expected High-Quality Answer Example (Prompt B)

```text
SQL:
- Uses ref('int_account_subscriptions') and optionally cross-checks logic against rpt_saas_mrr.
- Filters or conditions metrics so only active subscriptions contribute.
- Groups by region.
- Calculates active_subscriptions, total_active_mrr_usd, avg_active_mrr_usd, and active_accounts.
- Sorts by total_active_mrr_usd descending.

Assumptions:
- region represents account geography such as NA, EMEA, and APAC.
- mrr_usd in int_account_subscriptions is already zero for non-active statuses.

Interpretation:
- Helps a stakeholder compare where subscription revenue is concentrated and whether some regions have many accounts but lower average MRR.
```

## Common Bad Answer Example (Prompt B)

```text
- Calls the output SaaS growth analysis without using any growth logic.
- Includes cancelled or trial subscriptions in active metrics.
- Uses a customer-grain result instead of one row per region.
- Gives no stakeholder-facing interpretation.
```