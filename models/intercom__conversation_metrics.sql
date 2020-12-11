with conversation_part_aggregates as (
  select *
  from {{ ref('int_intercom__conversation_part_aggregates') }}
),

dim_conversation as(
  select *
  from {{ ref('intercom__conversation_enhanced') }}
),

final as (
  select 
    dim_conversation.*,
    conversation_part_aggregates.count_reopens,
    conversation_part_aggregates.count_total_parts,
    conversation_part_aggregates.count_assignments,
    conversation_part_aggregates.first_contact_reply_at,
    conversation_part_aggregates.first_assignment_at,
    round(({{ dbt_utils.datediff("dim_conversation.conversation_created_at", "conversation_part_aggregates.first_assignment_at", 'second') }} /60),2) as time_to_first_assignment,
    conversation_part_aggregates.first_admin_response_at,
    round(({{ dbt_utils.datediff("dim_conversation.conversation_created_at", "conversation_part_aggregates.first_admin_response_at", 'second') }} /60),2) as time_to_first_response,
    round(({{ dbt_utils.datediff("conversation_part_aggregates.first_contact_reply_at", "dim_conversation.first_close_at", 'second') }} /60),2) as time_to_first_close,
    conversation_part_aggregates.first_reopen_at,
    conversation_part_aggregates.last_assignment_at,
    round(({{ dbt_utils.datediff("conversation_part_aggregates.first_contact_reply_at", "conversation_part_aggregates.last_assignment_at", 'second') }} /60),2) as time_to_last_assignment,
    conversation_part_aggregates.last_contact_reply_at,
    conversation_part_aggregates.last_admin_response_at,
    conversation_part_aggregates.last_reopen_at,
    round(({{ dbt_utils.datediff("conversation_part_aggregates.first_contact_reply_at", "dim_conversation.last_close_at", 'second') }} /60),2) as time_to_last_close
  from conversation_part_aggregates

  left join dim_conversation
    on dim_conversation.conversation_id = conversation_part_aggregates.conversation_id
  
)

select *
from final