select *
from {{ ref('fact_sales') }}
where abs(total_item_value - (price + freight_value)) > 0.01