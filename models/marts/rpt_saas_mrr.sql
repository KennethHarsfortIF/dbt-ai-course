select
    region,
    status,
    count(subscription_id) as subscriptions,
    sum(mrr_usd) as total_mrr_usd,
    avg(mrr_usd) as avg_mrr_usd
from {{ ref('int_account_subscriptions') }}
group by 1,2
