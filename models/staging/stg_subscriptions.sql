select
    cast(subscription_id as integer) as subscription_id,
    cast(account_id as integer) as account_id,
    cast(plan_id as integer) as plan_id,
    cast(start_date as date) as start_date,
    cast(nullif(end_date, '') as date) as end_date,
    lower(status) as status
from {{ ref('raw_subscriptions') }}
