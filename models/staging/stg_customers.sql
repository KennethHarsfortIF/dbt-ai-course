select
    cast(customer_id as integer) as customer_id,
    lower(trim(email)) as email,
    first_name,
    last_name,
    cast(signup_date as date) as signup_date,
    upper(country) as country,
    lower(segment) as segment
from {{ ref('raw_customers') }}
