# Prompt 2: Explain/Document Code (Concrete, Copy-Paste)

Use one of the prompts below exactly as-is.

## Prompt A: Explain fct_orders

```text
You are reviewing dbt SQL and documentation.

Explain this model:
- models/marts/fct_orders.sql

Use this response structure:
1) Business purpose (2-3 sentences, plain language)
2) Inputs and lineage (explicit ref chain)
3) Output grain (state exact row-level grain)
4) Key transformations (bullet list)
5) Data quality and edge cases (at least 3)
6) Existing test coverage (what each test protects)
7) Suggested schema.yml description text (copy-paste ready)

Important:
- Be precise about how is_successful_order is calculated.
- Call out potential join duplication risks if payment grain changes.
```

## Prompt B: Explain int_account_subscriptions

```text
You are reviewing dbt SQL and documentation.

Explain this model:
- models/intermediate/int_account_subscriptions.sql

Use this response structure:
1) Business purpose (2-3 sentences, plain language)
2) Inputs and lineage (explicit ref chain)
3) Output grain (state exact row-level grain)
4) Key transformations (bullet list)
5) Data quality and edge cases (at least 3)
6) Existing test coverage (what each test protects)
7) Suggested schema.yml description text (copy-paste ready)

Important:
- Be explicit that mrr_usd is zero for non-active statuses.
- Highlight how null end_date should be interpreted.
```

## Expected High-Quality Answer Example (Prompt A)

```text
1) Business purpose:
fct_orders provides an order-level fact table that combines order lifecycle and payment status to support conversion and revenue reporting.

2) Inputs and lineage:
stg_orders -> fct_orders
stg_payments -> fct_orders

3) Output grain:
One row per order_id (assuming one payment record per order_id).

4) Key transformations:
- Normalizes order and payment attributes from staging.
- Left joins payments to orders by order_id.
- Calculates is_successful_order = true only when order_status = 'completed' and payment_status = 'paid'.

5) Data quality and edge cases:
- If payments become multi-row per order_id, grain may duplicate.
- Null payment records produce false for is_successful_order.
- Returned/cancelled orders remain in table for full lifecycle analysis.

6) Existing tests:
- unique/not_null on order_id protects fact grain.
- not_null on customer_id ensures attribution completeness.

7) Suggested schema.yml description:
"Order-level fact model that combines order status and payment outcomes for revenue and success-rate reporting. One row per order_id under current payment assumptions."
```

## Common Bad Answer Example (Prompt A)

```text
- Says the model is customer-grain.
- Omits lineage.
- Fails to explain is_successful_order logic.
- Gives generic advice like "add more tests" without naming specific tests.
```

## Expected High-Quality Answer Example (Prompt B)

```text
1) Business purpose:
int_account_subscriptions enriches subscription records with account and plan context and computes mrr_usd for downstream SaaS reporting.

2) Inputs and lineage:
stg_subscriptions + stg_plans + stg_accounts -> int_account_subscriptions

3) Output grain:
One row per subscription_id.

4) Key transformations:
- Joins subscriptions to plans for pricing.
- Joins subscriptions to accounts for account attributes.
- Sets mrr_usd = price_usd only for status = 'active', else 0.

5) Data quality and edge cases:
- Null plan matches would null out pricing unless handled.
- status domain drift can misclassify mrr logic.
- null end_date should represent still-open subscriptions.

6) Existing tests:
- unique/not_null on subscription_id protects grain.
- relationship tests on account_id and plan_id protect referential integrity.

7) Suggested schema.yml description:
"Subscription-grain intermediate model with account and plan enrichments. Calculates mrr_usd as active-only revenue contribution for downstream MRR reporting."
```

## Common Bad Answer Example (Prompt B)

```text
- Claims mrr_usd includes trial/cancelled revenue.
- Says end_date null means bad data.
- Does not mention relationships tests or grain.
```
