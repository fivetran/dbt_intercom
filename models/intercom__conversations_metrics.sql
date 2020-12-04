with conversation_part_aggregates as (
  select *
  from {{ ref('conversation_part_aggregates') }}
),

conversations_enhanced as(
  select *
  from {{ ref('intercom__conversations_enhanced') }}
),

final as (
  select 
    conversations_enhanced.*,
    conversation_part_aggregates.count_reopens,
    conversation_part_aggregates.count_total_parts,
    conversation_part_aggregates.first_response_at,
    round((timestamp_diff(first_response_at, conversation_part_aggregates.conversation_created_at, second)/60),2) as time_to_first_response,
    conversation_part_aggregates.first_close_at,
    round((timestamp_diff(first_close_at, conversation_part_aggregates.conversation_created_at, second)/60),2) as time_to_first_close,
    conversation_part_aggregates.last_close_at,
    round((timestamp_diff(last_close_at, conversation_part_aggregates.conversation_created_at, second)/60),2) as time_to_last_close,
    conversation_part_aggregates.last_close_by_author_id
  from conversation_part_aggregates

  left join conversations_enhanced
    on conversations_enhanced.conversation_id = conversation_part_aggregates.conversation_id
  
)

select *
from final