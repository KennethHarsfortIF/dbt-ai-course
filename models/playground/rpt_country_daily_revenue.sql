with orders as (
    select * from {{ ref('fct_orders') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
),
joined as (
    select
        o.order_date,
        c.country,
        o.is_successful_order,
        o.order_amount
    from orders o
    left join customers c
        on o.customer_id = c.customer_id
)

select
    order_date,
    country,
    count(case when is_successful_order then 1 end)         as successful_orders,
    sum(case when is_successful_order then order_amount
             else 0 end)                                    as successful_revenue,
    {{ safe_divide(
        'sum(case when is_successful_order then order_amount else 0 end)',
        'count(case when is_successful_order then 1 end)'
    ) }}                                                    as avg_successful_order_value
from joined
group by 1, 2
order by 1, 2
