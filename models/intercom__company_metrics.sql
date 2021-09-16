--To disable this model, set the intercom__using_contact_company variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_contact_company', True)) }}

with conversation_metrics as (
    select *
    from {{ ref('intercom__conversation_metrics') }}
),

company_enhanced as (
    select *
    from {{ ref('intercom__company_enhanced') }}
),

contact_company_history as (
    select *
    from {{ var('contact_company_history') }}
),

contact_enhanced as (
    select *
    from {{ ref('intercom__contact_enhanced') }}
),

--Aggregates company specific metrics for companies where a contact from that company was attached to the conversation.
company_metrics as (
    select
        company_enhanced.company_id,
        sum(case when conversation_metrics.conversation_state = 'closed' then 1 else 0 end) as total_conversations_closed,
        round(avg(conversation_metrics.count_total_parts),2) as average_conversation_parts,
        avg(conversation_metrics.conversation_rating) as average_conversation_rating
    from conversation_metrics

    left join contact_enhanced
        on contact_enhanced.contact_id = conversation_metrics.first_contact_author_id

    left join contact_company_history
        on contact_company_history.contact_id = contact_enhanced.contact_id

    left join company_enhanced
        on company_enhanced.company_id = contact_company_history.company_id

    group by 1
),

--Generates the median values for companies where a contact from that company was attached to the conversation.
median_metrics as (
    select
        company_enhanced.company_id,
        round({{ fivetran_utils.percentile("conversation_metrics.count_reopens", "company_enhanced.company_id", "0.5") }}, 2) as median_conversations_reopened,
        round({{ fivetran_utils.percentile("conversation_metrics.time_to_first_response_minutes", "company_enhanced.company_id", "0.5") }}, 2) as median_time_to_first_response_time_minutes,
        round({{ fivetran_utils.percentile("conversation_metrics.time_to_first_close_minutes", "company_enhanced.company_id", "0.5") }}, 2) as median_time_to_first_close_minutes,
        round({{ fivetran_utils.percentile("conversation_metrics.time_to_last_close_minutes", "company_enhanced.company_id", "0.5") }}, 2) as median_time_to_last_close_minutes
    from conversation_metrics

    left join contact_enhanced
        on contact_enhanced.contact_id = conversation_metrics.first_contact_author_id

    left join contact_company_history
        on contact_company_history.contact_id = contact_enhanced.contact_id

    left join company_enhanced
        on company_enhanced.company_id = contact_company_history.company_id
),

--Joins the aggregate, and median CTEs to the company_enhanced model. Distinct is necessary to keep grain with median values and aggregates.
final as (
    select distinct
        company_enhanced.*,
        company_metrics.total_conversations_closed,
        company_metrics.average_conversation_parts,
        company_metrics.average_conversation_rating,
        median_metrics.median_conversations_reopened,
        median_metrics.median_time_to_first_response_time_minutes,
        median_metrics.median_time_to_last_close_minutes
    from company_enhanced

    left join company_metrics
        on company_metrics.company_id = company_enhanced.company_id

    left join median_metrics
        on median_metrics.company_id = company_enhanced.company_id
)

select * 
from final