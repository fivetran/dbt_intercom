with conversation_history as (
  select *
  from {{ ref('stg_intercom__conversation_history') }}
),

recent_conversation as (
    select
        *,
        row_number() over(partition by conversation_id order by updated_at desc) as recent_conversation_index
        
    from conversation_history
)

select *
from recent_conversation
where recent_conversation_index = 1