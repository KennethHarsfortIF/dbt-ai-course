with orders as (
    select * from {{ ref('stg_orders') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
)

select
    c.customer_id,
    c.email,
    c.country,
    c.segment,
    count(o.order_id) as total_orders,
    sum(case when o.order_status = 'completed' then o.order_amount else 0 end) as completed_revenue,
    max(o.order_date) as last_order_date
from customers c
left join orders o
    on c.customer_id = o.customer_id
group by 1,2,3,4
