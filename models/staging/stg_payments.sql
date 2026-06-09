select
    cast(payment_id as integer) as payment_id,
    cast(order_id as integer) as order_id,
    lower(payment_method) as payment_method,
    lower(payment_status) as payment_status,
    cast(processed_at as timestamp) as processed_at
from {{ ref('raw_payments') }}
