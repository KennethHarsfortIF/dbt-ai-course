select
    cast(plan_id as integer) as plan_id,
    lower(plan_name) as plan_name,
    lower(billing_cycle) as billing_cycle,
    cast(price_usd as double) as price_usd
from {{ ref('raw_plans') }}
