with dates as (
    select generate_series(
        '2016-01-01'::date,
        '2019-12-31'::date,
        interval '1 day'
    )::date as full_date
)
select
    cast(to_char(full_date, 'YYYYMMDD') as int) as date_key,
    full_date,
    extract(year from full_date)::int    as year,
    extract(month from full_date)::int   as month,
    to_char(full_date, 'Month')          as month_name,
    extract(quarter from full_date)::int as quarter,
    extract(isodow from full_date) in (6, 7) as is_weekend
from dates