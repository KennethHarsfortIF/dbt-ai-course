-- One row per order/payment combination for lightweight order reporting.
-- This model is intended for analysts who need a simple fact view of orders,
-- including payment context and a basic success flag.
with orders as (
    select * from {{ ref('stg_orders') }}
),
payments as (
    select * from {{ ref('stg_payments') }}
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
        when o.order_status = 'completed' and p.payment_status = 'paid' then true
        else false
    end as is_successful_order
from orders o
left join payments p
    on o.order_id = p.order_id
