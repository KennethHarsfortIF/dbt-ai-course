-- Placeholder model so playground config is used and visible in docs.
select
    order_date,
    count(*) as order_count,
    sum(case when is_successful_order then order_amount else 0 end) as successful_revenue
from {{ ref('fct_orders') }}
group by 1
