select
    product_id,
    coalesce(product_category_name, 'unknown') as category_pt,
    cast(product_weight_g as numeric)          as weight_g,
    cast(product_photos_qty as int)            as photos_qty
from {{ source('bronze', 'products') }}