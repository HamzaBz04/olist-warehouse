select
    review_id,
    order_id,
    cast(review_score as int)               as review_score,
    cast(review_answer_timestamp as timestamp) as answered_at
from (
    select
        *,
        row_number() over (
            partition by order_id
            order by review_answer_timestamp desc
        ) as rn
    from {{ source('bronze', 'order_reviews') }}
) as ranked
where rn = 1