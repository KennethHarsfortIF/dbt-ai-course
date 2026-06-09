select
    cast(account_id as integer) as account_id,
    trim(account_name) as account_name,
    upper(region) as region,
    cast(created_date as date) as created_date
from {{ ref('raw_accounts') }}
