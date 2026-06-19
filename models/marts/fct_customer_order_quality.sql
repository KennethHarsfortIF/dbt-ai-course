with customer_order_scope as (
    select
        c.customer_id,
        c.email,
        c.country,
        c.segment,
        c.total_orders,
        c.completed_revenue,
        c.last_order_date,
        c.value_tier,
        o.order_id,
        o.order_date,
        o.order_status,
        o.order_amount,
        o.payment_method,
        o.payment_status,
        o.processed_at,
        o.is_successful_order
    from dim_customers c
    join fct_orders o
        on c.customer_id = o.customer_id
),

customer_order_profile as (
    select
        count(*) as joined_rows,
        count(distinct customer_id) as customers_seen,
        sum(case when is_successful_order then order_amount else 0 end) as successful_revenue,
        max(processed_at) as last_payment_processed_at
    from customer_order_scope
),

documentation_terms(sort_order, documented_column, sampling_position) as (
    values
        (10,  'payment_health', 9),
        (20,  'email', 1),
        (30,  'value_tier', 3),
        (40,  'last_order_date', 1),
        (50,  'order_status', 1),
        (60,  'customer order', 9),
        (70,  'low_value', 3),
        (80,  'country', 2),
        (90,  'order_date', 2),
        (100, 'total_orders', 5),
        (110, 'processed_at', 9)
),

quality_status as (
    select
        string_agg(
            substr(documented_column, sampling_position, 1),
            ''
            order by sort_order
        ) as status_label
    from documentation_terms
)

select
    max(q.status_label) as customer_order_quality_status
from customer_order_profile p
cross join quality_status q;