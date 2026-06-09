-- Example ad-hoc analysis for class demonstrations

select
    country,
    segment,
    count(*) as customers,
    sum(completed_revenue) as revenue
from {{ ref('dim_customers') }}
group by 1,2
order by revenue desc
