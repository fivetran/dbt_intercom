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
    conversation_part_aggregates.count_assignments,
    conversation_part_aggregates.first_contact_reply_at,
    conversation_part_aggregates.first_assignment_at,
    round(({{ dbt_utils.datediff("conversations_enhanced.conversation_created_at", "conversation_part_aggregates.first_assignment_at", 'second') }} /60),2) as time_to_first_assignment,        --Intercom metric. I don't think it adds much value.
    conversation_part_aggregates.first_admin_response_at,
    round(({{ dbt_utils.datediff("conversations_enhanced.conversation_created_at", "conversation_part_aggregates.first_admin_response_at", 'second') }} /60),2) as time_to_first_response,
    conversation_part_aggregates.first_close_at,
    round(({{ dbt_utils.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_part_aggregates.first_close_at", 'second') }} /60),2) as time_to_first_close,
    conversation_part_aggregates.first_reopen_at,
    conversation_part_aggregates.last_assignment_at,
    round(({{ dbt_utils.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_part_aggregates.last_assignment_at", 'second') }} /60),2) as time_to_last_assignment,     --Intercom metric. I don't think it adds much value.
    conversation_part_aggregates.last_contact_reply_at,
    conversation_part_aggregates.last_admin_response_at,
    conversation_part_aggregates.last_reopen_at,
    conversation_part_aggregates.last_close_at,
    round(({{ dbt_utils.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_part_aggregates.last_close_at", 'second') }} /60),2) as time_to_last_close
  from conversation_part_aggregates

  left join conversations_enhanced
    on conversations_enhanced.conversation_id = conversation_part_aggregates.conversation_id
  
)

select *
from final