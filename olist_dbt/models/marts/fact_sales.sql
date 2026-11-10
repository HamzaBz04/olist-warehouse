select
    row_number() over (order by i.order_id, i.item_sequence) as sales_key,
    c.customer_key,
    p.product_key,
    s.seller_key,
    cast(to_char(o.purchased_at, 'YYYYMMDD') as int) as date_key,
    i.order_id,
    o.order_status,
    i.price,
    i.freight_value,
    i.price + i.freight_value as total_item_value,
    extract(day from (o.delivered_at - o.estimated_delivery_at)) as delivery_delay_days
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders') }} o
    on i.order_id = o.order_id
join {{ ref('stg_customers') }} sc
    on o.customer_id = sc.customer_id
join {{ ref('dim_customer') }} c
    on sc.customer_unique_id = c.customer_unique_id
join {{ ref('dim_product') }} p
    on i.product_id = p.product_id
join {{ ref('dim_seller') }} s
    on i.seller_id = s.seller_id