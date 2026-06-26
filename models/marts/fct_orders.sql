with orders as (
    select * from {{ ref('stg_orders') }}
),
payments as (
    select * from {{ ref('stg_payments') }}
),
payments_ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by processed_at desc, payment_id desc
        ) as payment_rank
    from payments
),
payments_deduped as (
    select
        order_id,
        payment_method,
        payment_status,
        processed_at
    from payments_ranked
    where payment_rank = 1
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
left join payments_deduped p
    on o.order_id = p.order_id
