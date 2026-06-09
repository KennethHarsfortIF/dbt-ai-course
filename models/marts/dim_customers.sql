select
    customer_id,
    email,
    country,
    segment,
    total_orders,
    completed_revenue,
    last_order_date,
    case
        when completed_revenue >= 300 then 'high_value'
        when completed_revenue >= 100 then 'medium_value'
        else 'low_value'
    end as value_tier
from {{ ref('int_customer_orders') }}
