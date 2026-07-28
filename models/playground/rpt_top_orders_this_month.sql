select
    order_id,
    customer_id,
    order_date,
    order_amount as revenue
from {{ ref('fct_orders') }}
where is_successful_order = true
  and order_date >= date_trunc('month', current_date)
  and order_date < date_trunc('month', current_date) + interval '1 month'
order by revenue desc
limit 10
