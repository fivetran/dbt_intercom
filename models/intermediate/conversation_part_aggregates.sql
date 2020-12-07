with conversation_part_history as (
  select *
  from {{ ref('stg_intercom__conversation_part_history') }}
),

conversation_most_recent as (
  select *
  from {{ ref('conversation_most_recent') }}
),

conversation_part_events as (
  select *
  from {{ ref('conversation_part_events') }}
),

metric_aggregations as (

  select 
    conversation_most_recent.conversation_id,
    conversation_most_recent.created_at as conversation_created_at,
    count(conversation_part_history.conversation_part_id) as count_total_parts,
    min(case when conversation_part_history.part_type = 'comment' and (conversation_part_history.author_type = 'lead' or conversation_part_history.author_type = 'user') then conversation_part_history.created_at else null end) as first_contact_reply_at,
    min(case when conversation_part_history.part_type like '%assignment%' then conversation_part_history.created_at else null end) as first_assignment_at,
    min(case when conversation_part_history.part_type = 'comment' and conversation_part_history.author_type = 'admin' then conversation_part_history.created_at else null end) as first_admin_response_at,
    min(case when conversation_part_history.part_type = 'open' then conversation_part_history.created_at else null end) as first_reopen_at,
    max(case when conversation_part_history.part_type like '%assignment%' then conversation_part_history.created_at else null end) as last_assignment_at,
    max(case when conversation_part_history.part_type = 'comment' and (conversation_part_history.author_type = 'lead' or conversation_part_history.author_type = 'user') then conversation_part_history.created_at else null end) as last_contact_reply_at,
    max(case when conversation_part_history.part_type = 'comment' and conversation_part_history.author_type = 'admin' then conversation_part_history.created_at else null end) as last_admin_response_at,
    max(case when conversation_part_history.part_type = 'open' then conversation_part_history.created_at else null end) as last_reopen_at,
    sum(case when conversation_part_history.part_type like '%assignment%' then 1 else 0 end) as count_assignments,
    sum(case when conversation_part_history.part_type = 'open' then 1 else 0 end) as count_reopens
  from conversation_most_recent

  left join conversation_part_history
    on conversation_most_recent.conversation_id = conversation_part_history.conversation_id

  group by 1, 2
  
),

final as (
  select
    -- metric_aggregations.conversation_id,
    -- metric_aggregations.conversation_created_at,
    -- metric_aggregations.count_reopens,
    -- metric_aggregations.count_total_parts,
    -- metric_aggregations.first_response_at,
    metric_aggregations.*,
    --conversation_part_events.first_assigned_to_author_id,
    conversation_part_events.first_close_at,
    conversation_part_events.last_close_at,
    --conversation_part_events.last_close_by_author_id
  from metric_aggregations

  left join conversation_part_events 
    on conversation_part_events.conversation_id = metric_aggregations.conversation_id
)

select * 
from final