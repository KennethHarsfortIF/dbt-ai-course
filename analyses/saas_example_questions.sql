-- Example analysis for SaaS domain

select
    region,
    sum(total_mrr_usd) as mrr
from {{ ref('rpt_saas_mrr') }}
where status = 'active'
group by 1
order by mrr desc
