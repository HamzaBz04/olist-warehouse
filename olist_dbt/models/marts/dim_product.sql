select
    row_number() over (order by p.product_id) as product_key,
    p.product_id,
    coalesce(t.category_en, p.category_pt) as category,
    p.weight_g,
    p.photos_qty
from {{ ref('stg_products') }} p
left join {{ ref('stg_category_translation') }} t
    on p.category_pt = t.category_pt