select
    c.customer_id,
    c.email,
    c.country,
    c.segment,
    c.value_tier,
    c.total_orders,
    c.completed_revenue,
    {{ safe_divide('c.completed_revenue', 'c.total_orders') }} as avg_revenue_per_order
from {{ ref('dim_customers') }} c

