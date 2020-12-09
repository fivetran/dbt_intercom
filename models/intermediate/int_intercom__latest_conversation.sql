with conversation_history as (
  select *
  from {{ ref('stg_intercom__conversation_history') }}
),

latest_conversation as (
    select
      *,
      row_number() over(partition by conversation_id order by updated_at desc) as latest_conversation_index
    from conversation_history
)

select *
from latest_conversation
where latest_conversation_index = 1