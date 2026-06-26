# dbt Code Review — Marts Models
## Prompt, AI Response, and Follow-up Chat

---

## User Prompt

```
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

---

## AI Code Review Response

### HIGH

**1. `fct_orders.sql` — Broken order grain due to undeduped payments join**

- **Issue:** `stg_payments` is joined directly on `order_id` (line 22). If an order has multiple payment attempts, this creates multiple rows per order.
- **Why it matters:** Violates the `unique` test on `order_id`, can inflate downstream counts/revenue, and misfires `is_successful_order`.
- **Fix:** Pre-aggregate or rank payments to one row per order before joining.

**2. `fct_orders.sql` — `is_successful_order` can produce false negatives for retried payments**

- **Issue:** `is_successful_order` (line 17) depends on a single joined payment row. If a retry payment succeeded but isn't the joined row, the flag is false.
- **Why it matters:** Business success should be: order completed AND at least one paid payment.
- **Fix:** Derive `has_paid_payment` at order grain, then base `is_successful_order` on that flag.

**3. `rpt_customer_ltv.sql` — Mixed-denominator metric in `avg_revenue_per_order`**

- **Issue:** `avg_revenue_per_order` (line 9) divides `completed_revenue` (completed orders only) by `total_orders` (all statuses from `dim_customers`).
- **Why it matters:** Systematically understates per-completed-order value and can mislead segmentation/retention analysis.
- **Fix:** Divide by `completed_orders` (add upstream), or rename metric to reflect total-order denominator.

---

### MEDIUM

**1. `fct_orders.sql` — `select *` from source CTEs**

- **Issue:** Lines 2 and 5 use `select *`.
- **Why it matters:** Schema drift can silently change model behavior; unnecessary columns increase scan/compute cost.
- **Fix:** Select only the columns needed by `fct_orders`.

**2. `rpt_saas_mrr.sql` — Ordinal `GROUP BY`**

- **Issue:** `group by 1,2` (line 8) is brittle when select-list order changes.
- **Why it matters:** Reduces readability and causes silent bugs during maintenance.
- **Fix:** Use explicit `group by region, status`.

**3. `dim_customers.sql` — Hard-coded, undocumented segmentation thresholds**

- **Issue:** `value_tier` thresholds of 300/100 (lines 10–11) are embedded with no documentation.
- **Why it matters:** Threshold drift leads to inconsistent KPI interpretation across teams.
- **Fix:** Document thresholds in schema and parameterize via `vars` or a seed-based lookup table.

**4. `rpt_saas_mrr.sql` — `avg_mrr_usd` across non-active statuses is structurally zero**

- **Issue:** Because `mrr_usd` is zeroed for non-active subscriptions upstream, `avg_mrr_usd` for non-active rows is misleadingly zero.
- **Why it matters:** Can be misread as signal rather than an artifact of upstream zeroing logic.
- **Fix:** Add `active_subscriptions` / `active_mrr_usd` columns or filter to active only in a separate model, and document intended usage.

---

### LOW

**1. `schema.yml` — Thin documentation coverage**

- **Issue:** Business-critical columns (`completed_revenue`, `total_orders`, `order_status`, `payment_status`, `avg_revenue_per_order`) have no descriptions.
- **Why it matters:** Slower onboarding and higher risk of metric misuse.
- **Fix:** Add column descriptions for every exposed metric/dimension.

**2. `schema.yml` — Minimal test coverage for domain constraints**

- **Issue:** No `accepted_values` or `relationships` tests on status/ID fields; no non-negative checks on monetary fields.
- **Why it matters:** Invalid statuses, orphaned keys, and negative amounts can slip into marts undetected.
- **Fix:** Add relevant tests (see YAML snippet below).

**3. `schema.yml` — No `relationships` test for `fct_orders.customer_id`**

- **Issue:** `fct_orders.customer_id` (line 23) has only `not_null`, not a referential integrity check.
- **Why it matters:** Orphaned facts appear undetected.
- **Fix:** Add `relationships` test to `dim_customers.customer_id`.

---

### Top 3 Fix Snippets

#### Fix 1 — `fct_orders.sql`: One-row-per-order payments + robust success logic

```sql
with orders as (
    select
        order_id,
        customer_id,
        order_date,
        order_status,
        order_amount
    from {{ ref('stg_orders') }}
),
payments_ranked as (
    select
        order_id,
        payment_method,
        payment_status,
        processed_at,
        row_number() over (
            partition by order_id
            order by processed_at desc nulls last
        ) as rn,
        max(case when payment_status = 'paid' then 1 else 0 end) over (
            partition by order_id
        ) as has_paid_payment_int
    from {{ ref('stg_payments') }}
),
payments_one_row as (
    select
        order_id,
        payment_method,
        payment_status,
        processed_at,
        has_paid_payment_int = 1 as has_paid_payment
    from payments_ranked
    where rn = 1
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.order_amount,
    p.payment_method,
    p.payment_status,
    p.processed_at,
    case
        when o.order_status = 'completed' and coalesce(p.has_paid_payment, false) then true
        else false
    end as is_successful_order
from orders o
left join payments_one_row p
    on o.order_id = p.order_id
```

#### Fix 2 — `rpt_customer_ltv.sql`: Correct denominator for avg revenue metric

```sql
select
    c.customer_id,
    c.email,
    c.country,
    c.segment,
    c.value_tier,
    c.total_orders,
    c.completed_orders,
    c.completed_revenue,
    {{ safe_divide('c.completed_revenue', 'c.completed_orders') }} as avg_completed_revenue_per_order
from {{ ref('dim_customers') }} c
```

> Requires adding `completed_orders` in `int_customer_orders` and surfacing it through `dim_customers`.

#### Fix 3 — `schema.yml`: Test hardening for `fct_orders`

```yaml
- name: fct_orders
  description: "Order-level fact model joined with payment status."
  columns:
    - name: order_id
      tests:
        - not_null
        - unique
    - name: customer_id
      tests:
        - not_null
        - relationships:
            to: ref('dim_customers')
            field: customer_id
    - name: order_status
      tests:
        - accepted_values:
            values: ['completed', 'pending', 'cancelled']
    - name: payment_status
      tests:
        - accepted_values:
            values: ['paid', 'failed', 'pending']
            where: "payment_status is not null"
    - name: order_amount
      tests:
        - not_null

- name: rpt_customer_ltv
  columns:
    - name: avg_completed_revenue_per_order
      description: "Completed revenue divided by completed orders."

- name: rpt_saas_mrr
  columns:
    - name: subscriptions
      tests:
        - not_null
```

---

### Quick Wins in 30 Minutes

1. **Refactor `fct_orders`** to one payment row per order and recompute `is_successful_order` from `has_paid_payment`.
2. **Replace `group by 1,2`** with `group by region, status` in `rpt_saas_mrr`.
3. **Add `relationships` + `accepted_values` tests** in the marts schema for `fct_orders`.
4. **Add column descriptions** for `completed_revenue`, `total_orders`, `avg_revenue_per_order`, `payment_status`.
5. **Align LTV metric naming** — either add `completed_orders` and compute correctly, or rename to avoid semantic confusion.

---

## Follow-up: Implement High Finding #1

**User:** Implement the first issue on the high list.

**AI:** Implemented by restructuring `fct_orders.sql` to enforce order grain:

- Added a `payments_ranked` CTE using `row_number()` partitioned by `order_id`.
- Added a `payments` CTE filtering to `payment_rank = 1` before the join.
- All 3 existing dbt tests passed (`not_null_fct_orders_customer_id`, `not_null_fct_orders_order_id`, `unique_fct_orders_order_id`).

> Note: if two payment records share the same `processed_at`, row selection is non-deterministic — flagged for follow-up.

---

## Follow-up: Add Deterministic Tiebreaker + Restore Source CTE Style

**User:** Make a deterministic tiebreaker. Also keep source CTEs in `select * from source` form for payments while maintaining the implemented logic.

**AI:** Updated `fct_orders.sql` with two changes:

1. **Tiebreaker:** `order by processed_at desc, payment_id desc` — when two payments share the same timestamp, the highest `payment_id` (latest inserted) wins, giving fully deterministic row selection.
2. **Source CTE style restored:** `payments` is now `select * from {{ ref('stg_payments') }}` again. Ranking and deduplication happen in two subsequent CTEs (`payments_ranked`, `payments_deduped`).

### Final `fct_orders.sql`

```sql
with orders as (
    select * from {{ ref('stg_orders') }}
),
payments as (
    select * from {{ ref('stg_payments') }}
),
payments_ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by processed_at desc, payment_id desc
        ) as payment_rank
    from payments
),
payments_deduped as (
    select
        order_id,
        payment_method,
        payment_status,
        processed_at
    from payments_ranked
    where payment_rank = 1
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.order_amount,
    p.payment_method,
    p.payment_status,
    p.processed_at,
    case
        when o.order_status = 'completed' and p.payment_status = 'paid' then true
        else false
    end as is_successful_order
from orders o
left join payments_deduped p
    on o.order_id = p.order_id
```

**CTE structure summary:**

| CTE | Role |
|---|---|
| `orders` | `select *` from `stg_orders` — raw source |
| `payments` | `select *` from `stg_payments` — raw source |
| `payments_ranked` | Adds `row_number()` with deterministic tiebreaker |
| `payments_deduped` | Filters to `payment_rank = 1` — one row per order |

All 3 dbt tests passed: PASS=3, ERROR=0.
