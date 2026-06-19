## User
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

## Assistant
1. Business purpose (2-3 sentences, plain language)
This model creates an order fact table that combines each order with payment details so analysts can track fulfillment and payment outcomes in one place. It is designed for reporting on order performance, payment behavior, and a boolean success flag for downstream KPIs. The core logic is in models/marts/fct_orders.sql.

2. Inputs and lineage (explicit ref chain)
Lineage chain 1:
raw_orders seed -> stg_orders -> fct_orders

Lineage chain 2:
raw_payments seed -> stg_payments -> fct_orders

Join relationship used in mart:
left join stg_payments onto stg_orders by order_id.

3. Output grain (state exact row-level grain)
Exact grain is one row per joined order-payment record after left join on order_id, not strictly one row per order.
- If an order has zero payments: one row with null payment fields.
- If an order has one payment: one row.
- If an order has multiple payment rows: multiple rows for the same order_id.

4. Key transformations (bullet list)
- Pulls all columns from upstream staging models via two CTEs: orders and payments.
- Selects core order attributes plus payment attributes into a single output.
- Performs a left join from orders to payments on order_id.
- Calculates is_successful_order exactly as:
  true only when order_status = completed AND payment_status = paid; otherwise false (including null payment_status from unmatched left join rows).

5. Data quality and edge cases (at least 3)
- Join duplication risk if payment grain changes:
  If stg_payments becomes multi-event per order (retries, partial captures, status history), this model duplicates orders because it joins at order_id without deduplication/aggregation. This can inflate counts and revenue in downstream analyses.
- Success flag may undercount “business-successful” orders:
  Completed orders with missing payment rows (or non-paid statuses like pending) are forced to false due to the CASE ELSE branch.
- Potential mismatch between business semantics and technical status:
  The model uses one exact condition only (completed + paid). Any future status variants (for example settled/captured) would be treated as false unless added to logic.
- Uniqueness expectation conflict:
  The mart schema expects unique order_id, but SQL can emit multiple rows per order if multiple payments exist; this can cause test failures or force hidden assumptions about payment grain.
- Payment timing ambiguity:
  processed_at is selected per payment row; if multiple payments exist, order-level “payment timestamp” becomes ambiguous unless canonicalized (first paid, latest paid, etc.).

6. Existing test coverage (what each test protects)
Direct tests on fct_orders:
- order_id not_null: protects against missing order keys in mart output.
- order_id unique: protects one-row-per-order expectation; will fail when join creates duplicates from multi-payment orders.
- customer_id not_null: protects required customer linkage on each mart row.

Upstream protections that support fct_orders:
- stg_orders.order_id not_null + unique: protects clean order keys before join.
- stg_orders.customer_id relationship to stg_customers: protects referential integrity of customer_id in orders.
- stg_orders.order_status accepted_values: constrains order_status domain used by success flag logic.
- stg_payments.payment_id not_null + unique: protects payment event identity.
- stg_payments.order_id relationship to stg_orders: protects payment-to-order referential validity.
- Singular test for negative order amount: protects against negative order amounts in staging orders.

Important gap:
- No direct test validates is_successful_order logic outcomes (for example accepted values true/false plus conditional consistency checks).

7. Suggested schema.yml description text (copy-paste ready)

- name: fct_orders
  description: "Fact table at order-payment join grain. Combines cleaned orders with payment attributes using a left join on order_id. One order can appear multiple times if multiple payment records exist for that order."
  columns:
    - name: order_id
      description: "Order identifier from stg_orders. Expected to be unique in this mart; duplicates indicate multiple payment rows per order or join-grain drift."
    - name: customer_id
      description: "Customer identifier associated with the order."
    - name: order_date
      description: "Date the order was placed."
    - name: order_status
      description: "Normalized order lifecycle status from stg_orders."
    - name: order_amount
      description: "Order amount in source currency/units after staging type-casting."
    - name: payment_method
      description: "Normalized payment method from stg_payments; null when no matching payment row exists."
    - name: payment_status
      description: "Normalized payment status from stg_payments; null when no matching payment row exists."
    - name: processed_at
      description: "Payment processing timestamp from stg_payments."
    - name: is_successful_order
      description: "Boolean flag set to true only when order_status = 'completed' and payment_status = 'paid'; otherwise false, including orders with no matching payment row."

