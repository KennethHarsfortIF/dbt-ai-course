with subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),
plans as (
    select * from {{ ref('stg_plans') }}
),
accounts as (
    select * from {{ ref('stg_accounts') }}
)

select
    s.subscription_id,
    s.account_id,
    a.account_name,
    a.region,
    s.plan_id,
    p.plan_name,
    p.price_usd,
    s.status,
    s.start_date,
    s.end_date,
    case
        when s.status = 'active' then p.price_usd
        else 0
    end as mrr_usd
from subscriptions s
left join plans p
    on s.plan_id = p.plan_id
left join accounts a
    on s.account_id = a.account_id
