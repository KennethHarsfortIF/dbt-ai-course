# 03 Suggest Improvements - Response

## User Request

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

## Assistant Response

### High
1. Issue: Order-level grain is broken in `models/marts/fct_orders.sql` because `stg_payments` is joined directly on `order_id`, which creates multiple rows per order when there are multiple payment attempts.  
Why it matters: This can violate the unique test on `order_id` in `models/marts/schema.yml`, inflate downstream counts/revenue if this fact is reused, and misstate `is_successful_order`.  
Concrete fix: Pre-aggregate or rank payments to one row per order before joining.

2. Issue: `is_successful_order` in `models/marts/fct_orders.sql` depends on a single joined payment row and can be false even when another payment attempt was paid.  
Why it matters: For retries/multiple attempts, business success should usually be order completed AND at least one paid payment. Current logic can produce false negatives.  
Concrete fix: Derive `has_paid_payment` at order grain and base `is_successful_order` on that flag.

3. Issue: `avg_revenue_per_order` in `models/marts/rpt_customer_ltv.sql` divides `completed_revenue` by `total_orders`, mixing completed-only numerator with all-status denominator from `models/marts/dim_customers.sql`.  
Why it matters: This systematically understates per-completed-order value and can mislead segmentation/retention analysis.  
Concrete fix: Divide by `completed_orders` (add upstream), or rename metric to reflect total-order denominator.

### Medium
1. Issue: `select *` is used in `models/marts/fct_orders.sql`.  
Why it matters: Schema drift can silently change model behavior, and unnecessary columns increase scan/compute cost.  
Concrete fix: Select explicit columns needed by `fct_orders`.

2. Issue: Grouping by ordinal positions in `models/marts/rpt_saas_mrr.sql`.  
Why it matters: `group by 1,2` is brittle when select-list order changes and reduces readability during maintenance.  
Concrete fix: Use explicit `group by region, status`.

3. Issue: Hard-coded segmentation thresholds in `models/marts/dim_customers.sql` for `value_tier` are undocumented business rules.  
Why it matters: Threshold drift over time leads to inconsistent KPI interpretation across teams.  
Concrete fix: Document thresholds in schema and ideally parameterize via vars or a seed-based lookup table.

4. Issue: `rpt_saas_mrr` defines `total_mrr_usd` and `avg_mrr_usd` but does not clarify active vs non-active interpretation in `models/marts/rpt_saas_mrr.sql`.  
Why it matters: Because `mrr_usd` is zeroed for non-active upstream, `avg_mrr_usd` across non-active statuses becomes structurally zero and can be misread as signal.  
Concrete fix: Add `active_subscriptions` and `active_mrr_usd` columns (or filter to active in a separate report model) and document intended usage.

### Low
1. Issue: Documentation coverage is thin in `models/marts/schema.yml`, especially for business-critical columns like `completed_revenue`, `total_orders`, `order_status`, `payment_status`, `avg_revenue_per_order`.  
Why it matters: Slower onboarding and higher risk of metric misuse.  
Concrete fix: Add column descriptions for every exposed metric/dimension.

2. Issue: Test coverage is minimal for domain constraints in `models/marts/schema.yml`.  
Why it matters: Invalid statuses, orphaned keys, and negative amounts may slip into marts.  
Concrete fix: Add `accepted_values` and `relationship` tests for key status/ID fields, and non-negative checks for monetary fields.

3. Issue: No explicit relationship test for `fct_orders.customer_id` in `models/marts/schema.yml`.  
Why it matters: Orphaned facts can appear undetected.  
Concrete fix: Add relationship test to `dim_customers.customer_id`.

## Top 3 Fix Snippets

### 1) SQL fix for one-row-per-order payments + robust success logic in `models/marts/fct_orders.sql`

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

### 2) SQL fix for denominator semantics in `models/marts/rpt_customer_ltv.sql`

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

Note: This requires adding `completed_orders` in upstream customer aggregation and carrying it into `dim_customers`.

### 3) YAML test/doc hardening in `models/marts/schema.yml`

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

## Quick Wins In 30 Minutes

1. Refactor `fct_orders` to one payment row per order and recompute `is_successful_order` from `has_paid_payment`.
2. Replace `group by 1,2` with `group by region, status` in `rpt_saas_mrr` for safer maintenance.
3. Add relationship + accepted_values tests in marts schema for `fct_orders`.
4. Add concise column descriptions for `completed_revenue`, `total_orders`, `avg_revenue_per_order`, `payment_status`.
5. Align LTV metric naming now: either add `completed_orders` and compute correctly, or rename current metric to avoid semantic confusion.
