with conversation_metrics as (
  select *
  from {{ ref('intercom__conversation_metrics') }}
  where conversation_assignee_type = 'admin'
),

admin_table as (
    select *
    from {{ ref('stg_intercom__admin') }}
),

team_admin as (
    select *
    from {{ ref('stg_intercom__team_admin') }}
),

team as (
    select *
    from {{ ref('stg_intercom__team') }}
),

--Aggregates admin specific metrics. The admin in question is the one who last closed the conversations.
admin_metrics as (
    select
        last_close_by_admin_id,
        sum(case when conversation_metrics.conversation_state = 'closed' then 1 else 0 end) as total_conversations_closed,
        round(avg(conversation_metrics.count_total_parts),2) as average_conversation_parts,
        avg(conversation_metrics.conversation_rating) as average_conversation_rating
    from conversation_metrics

    group by 1
),

--Generates the median values for admins who last closed conversations.
median_metrics as (
    select
        last_close_by_admin_id,
        round({{ fivetran_utils.percentile("conversation_metrics.count_reopens", "last_close_by_admin_id", "0.5") }}, 2) as median_conversations_reopened,
        round({{ fivetran_utils.percentile("conversation_metrics.count_assignments", "last_close_by_admin_id", "0.5") }}, 2) as median_conversation_assignments,
        round({{ fivetran_utils.percentile("conversation_metrics.time_to_first_response_minutes", "last_close_by_admin_id", "0.5") }}, 2) as median_time_to_first_response_time_minutes,
        round({{ fivetran_utils.percentile("conversation_metrics.time_to_first_close_minutes", "last_close_by_admin_id", "0.5") }}, 2) as median_time_to_first_close_minutes,
        round({{ fivetran_utils.percentile("conversation_metrics.time_to_last_close_minutes", "last_close_by_admin_id", "0.5") }}, 2) as median_time_to_last_close_minutes
    from conversation_metrics
),

--Joins the aggregate, and median CTEs to the admin table with team enrichment. Distinct is necessary to keep grain with median values and aggregates.
final as (
    select distinct
        admin_table.admin_id,
        admin_table.name as admin_name,
        team.name as team_name,
        admin_table.job_title,
        admin_metrics.total_conversations_closed,
        admin_metrics.average_conversation_parts,
        admin_metrics.average_conversation_rating,
        median_metrics.median_conversations_reopened,
        median_metrics.median_conversation_assignments,
        median_metrics.median_time_to_first_response_time_minutes,
        median_metrics.median_time_to_last_close_minutes
    from admin_table

    left join admin_metrics
        on admin_metrics.last_close_by_admin_id = admin_table.admin_id

    left join median_metrics
        on median_metrics.last_close_by_admin_id = admin_table.admin_id
    
    left join team_admin
        on team_admin.admin_id = admin_table.admin_id

    left join team
        on team.team_id = team_admin.team_id
)

select * 
from final