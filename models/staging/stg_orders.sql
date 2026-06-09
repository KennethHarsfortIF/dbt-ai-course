select
    cast(order_id as integer) as order_id,
    cast(customer_id as integer) as customer_id,
    cast(order_date as date) as order_date,
    lower(order_status) as order_status,
    cast(order_amount as double) as order_amount
from {{ ref('raw_orders') }}
