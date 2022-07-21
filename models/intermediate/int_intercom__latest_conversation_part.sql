with conversation_part_history as (
  select *
  from {{ var('conversation_part_history') }}
),

--Returns the most recent conversation record by creating a row number ordered by the conversation_updated_at date, then filtering to only return the #1 row per conversation.
latest_conversation_part as (
    select
      *,
      row_number() over(partition by conversation_part_id order by updated_at desc) as latest_conversation_part_index
    from conversation_part_history
)

select *
from latest_conversation_part
where latest_conversation_part_index = 1