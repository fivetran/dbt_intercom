with conversation_part_history as (
  select *
  from {{ ref('stg_intercom__conversation_part_history') }}
),

conversation_most_recent as (
  select *
  from {{ ref('conversation_most_recent') }}
),

conversation_part_close_events as (

  select distinct
    conversation_id,
    first_value(author_id) over (partition by conversation_id order by created_at desc) as last_close_by_author_id,
    first_value(created_at) over (partition by conversation_id order by created_at desc) as last_close_at,
    first_value(created_at) over (partition by conversation_id order by created_at asc) as first_close_at  
  from conversation_part_history
  where part_type = 'close'

), 

conversation_part_open_events as (
  select 
    conversation_id,
    conversation_part_id,
    created_at,
    part_type,
    lead(part_type, 1) over(partition by conversation_id order by created_at) as part_type_lead
  from conversation_part_history

),

metric_aggregations as (

  select 
    conversation_most_recent.conversation_id,
    conversation_most_recent.created_at as conversation_created_at,
    count(conversation_part_history.conversation_part_id) as count_total_parts,
    min(case when conversation_part_history.part_type = 'comment' and conversation_part_history.author_type = 'admin' then conversation_part_history.created_at else null end) as first_response_at,
    sum(case when conversation_part_open_events.part_type = 'close' and conversation_part_open_events.part_type_lead is not null then 1 else 0 end) as count_reopens
  from conversation_most_recent
  left join conversation_part_history
    on conversation_most_recent.conversation_id = conversation_part_history.conversation_id
  left join conversation_part_open_events
    on conversation_part_history.conversation_part_id = conversation_part_open_events.conversation_part_id
  group by 1, 2
  
),

final as (
  select
    metric_aggregations.conversation_id,
    metric_aggregations.conversation_created_at,
    metric_aggregations.count_reopens,
    metric_aggregations.count_total_parts,
    metric_aggregations.first_response_at,
    conversation_part_close_events.first_close_at,
    conversation_part_close_events.last_close_at,
    conversation_part_close_events.last_close_by_author_id
  from metric_aggregations
  left join conversation_part_close_events 
    on conversation_part_close_events.conversation_id = metric_aggregations.conversation_id
)

select * 
from final