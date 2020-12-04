with intercom__conversations_metrics as (
  select *
  from {{ ref('intercom__conversations_metrics') }}
  where conversation_assignee_type = 'admin'
),

admin_table as (
    select *
    from {{ ref('stg_intercom__admin') }}
),

admin_metrics as (
    select
        admin_table.admin_id,
        admin_table.name as admin_name,
        admin_table.job_title,
        sum(case when intercom__conversations_metrics.conversation_state = 'closed' then 1 else 0 end) as total_conversations_closed,
        round(avg(intercom__conversations_metrics.count_total_parts),2) as average_conversation_parts,
        avg(intercom__conversations_metrics.conversation_rating) as average_conversation_rating

    from admin_table
    
    left join intercom__conversations_metrics
        on intercom__conversations_metrics.conversation_assignee_id = admin_table.admin_id

    group by 1,2,3
),

final as (
    select distinct
        admin_metrics.*,
        round({{ fivetran_utils.get_median("intercom__conversations_metrics.count_reopens", "admin_metrics.admin_id") }}, 2) as median_conversations_reopened,
        round({{ fivetran_utils.get_median("intercom__conversations_metrics.time_to_first_response", "admin_metrics.admin_id") }}, 2) as median_time_to_first_response_time,
        round({{ fivetran_utils.get_median("intercom__conversations_metrics.time_to_last_close", "admin_metrics.admin_id") }}, 2) as median_time_to_last_close

    from admin_metrics

    left join intercom__conversations_metrics
        on intercom__conversations_metrics.conversation_assignee_id = admin_metrics.admin_id
)

select * 
from final


