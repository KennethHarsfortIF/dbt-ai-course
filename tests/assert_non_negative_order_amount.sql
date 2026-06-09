select *
from {{ ref('stg_orders') }}
where order_amount < 0
