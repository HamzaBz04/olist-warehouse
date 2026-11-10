select *
from {{ ref('fact_sales') }}
where price <= 0