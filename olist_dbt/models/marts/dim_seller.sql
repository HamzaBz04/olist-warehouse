select
    row_number() over (order by seller_id) as seller_key,
    seller_id,
    city,
    state
from {{ ref('stg_sellers') }}