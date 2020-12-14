--This model will only run if the using_contact_company variable within your dbt_project.yml file is set to True.
{{ config(enabled=var('using_contact_company', True)) }}

with conversation_metrics as (
  select *
  from {{ ref('intercom__conversation_metrics') }}
),

company_enhanced as (
  select *
  from {{ ref('intercom__company_enhanced') }}
),

contact_enhanced as (
  select *
  from {{ ref('intercom__contact_enhanced') }}
),

company_metrics as (
    select
        company_enhanced.company_id,
        sum(case when conversation_metrics.conversation_state = 'closed' then 1 else 0 end) as total_conversations_closed,
        round(avg(conversation_metrics.count_total_parts),2) as average_conversation_parts,
        avg(conversation_metrics.conversation_rating) as average_conversation_rating
    from conversation_metrics

    left join contact_enhanced
        on contact_enhanced.contact_id = conversation_metrics.first_contact_author_id

    left join company_enhanced
        on company_enhanced.company_id = contact_enhanced.company_id

    group by 1
),

median_metrics as (
    select
        company_enhanced.company_id,
        round({{ fivetran_utils.median("conversation_metrics.count_reopens", "company_enhanced.company_id") }}, 2) as median_conversations_reopened,
        round({{ fivetran_utils.median("conversation_metrics.time_to_first_response", "company_enhanced.company_id") }}, 2) as median_time_to_first_response_time,
        round({{ fivetran_utils.median("conversation_metrics.time_to_first_close", "company_enhanced.company_id") }}, 2) as median_time_to_first_close,
        round({{ fivetran_utils.median("conversation_metrics.time_to_last_close", "company_enhanced.company_id") }}, 2) as median_time_to_last_close
    from conversation_metrics

    left join contact_enhanced
        on contact_enhanced.contact_id = conversation_metrics.first_contact_author_id

    left join company_enhanced
        on company_enhanced.company_id = contact_enhanced.company_id
),

final as (
    select distinct
        company_enhanced.*,
        company_metrics.total_conversations_closed,
        company_metrics.average_conversation_parts,
        company_metrics.average_conversation_rating,
        median_metrics.median_conversations_reopened,
        median_metrics.median_time_to_first_response_time,
        median_metrics.median_time_to_last_close
    from company_enhanced

    left join company_metrics
        on company_metrics.company_id = company_enhanced.company_id

    left join median_metrics
        on median_metrics.company_id = company_enhanced.company_id
)

select * 
from final