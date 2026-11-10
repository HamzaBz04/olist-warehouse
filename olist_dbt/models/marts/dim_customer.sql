select
    row_number() over (order by customer_unique_id) as customer_key,
    customer_unique_id,
    max(city)  as city,
    max(state) as state
from {{ ref('stg_customers') }}
group by customer_unique_id