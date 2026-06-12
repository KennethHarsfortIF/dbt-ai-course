with orders as (
    select * from {{ ref('fct_orders') }}
),
customers as (
    select * from {{ ref('dim_customers') }}
)

select
    o.order_date,
    c.country,
    count(case when o.is_successful_order then 1 end) as successful_orders,
    sum(case when o.is_successful_order then o.order_amount else 0 end) as successful_revenue,
    {{ safe_divide(
        "sum(case when o.is_successful_order then o.order_amount else 0 end)",
        "count(case when o.is_successful_order then 1 end)"
    ) }} as avg_successful_order_value
from orders o
left join customers c
    on o.customer_id = c.customer_id
group by 1, 2