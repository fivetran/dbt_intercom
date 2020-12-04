with intercom__conversations_metrics as (
  select *
  from {{ ref('intercom__conversations_metrics') }}
  where conversation_assignee_type = 'admin'
),

admin_table as (
    select *
    from {{ ref('stg_intercom__admin') }}
),

final as (
    select distinct 
        admin_table.admin_id, 
        admin_table.name as admin_name,
        admin_table.job_title,
        round(percentile_cont(intercom__conversations_metrics.time_to_first_response, 0.5) over(partition by admin_table.admin_id),2) as median_time_to_first_response_time,
        round(percentile_cont(intercom__conversations_metrics.time_to_last_close, 0.5) over(partition by admin_table.admin_id),2) as median_time_to_last_close

    from admin_table
    
    left join intercom__conversations_metrics
        on intercom__conversations_metrics.conversation_assignee_id = admin_table.admin_id
)

select * 
from final


