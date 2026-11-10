select
    order_id,
    cast(order_item_id as int)           as item_sequence,
    product_id,
    seller_id,
    cast(price as numeric(10,2))         as price,
    cast(freight_value as numeric(10,2)) as freight_value
from {{ source('bronze', 'order_items') }}