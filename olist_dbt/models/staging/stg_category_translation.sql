select
    product_category_name         as category_pt,
    product_category_name_english as category_en
from {{ source('bronze', 'product_category_name_translation') }}