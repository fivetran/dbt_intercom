with latest_conversation as (
    select *
    from {{ var('conversation_history') }}
    where coalesce(_fivetran_active, true)
),

conversation_string_aggregates as (
    select *
    from {{ ref('int_intercom__conversation_string_aggregates') }}
),

conversation_part_events as (
    select *
    from {{ ref('int_intercom__conversation_part_events') }}
),

--If you use the contact company table this will be included, if not it will be ignored.
{% if var('intercom__using_contact_company', True) %}
contact_enhanced as (
    select *
    from {{ ref('intercom__contact_enhanced') }}
),
{% endif %} 

--If you use conversation tags this will be included, if not it will be ignored.
{% if var('intercom__using_conversation_tags', True) %}
conversation_tags as (
    select *
    from {{ var('conversation_tag_history') }}
),

tags as (
    select *
    from {{ var('tag') }}
),

--Aggregates the tags associated with a single conversation into an array.
conversation_tags_aggregate as (
    select
        latest_conversation.conversation_id,
        {{ fivetran_utils.string_agg('distinct tags.name', "', '" ) }} as all_conversation_tags
    from latest_conversation

    left join conversation_tags
        on conversation_tags.conversation_id = latest_conversation.conversation_id
        
    left join tags
        on tags.tag_id = conversation_tags.tag_id

    group by 1    
),
{% endif %}  

--If you use the team table this will be included, if not it will be ignored.
{% if var('intercom__using_team', True) %}
team as (
    select *
    from {{ var('team') }}
),
{% endif %}

contact_history_with_channel AS (
    SELECT 
        contact_history.id as contact_id,
        conversation_contact_history.conversation_id,
        contact_history.name,
        contact_history.email,
        contact_history.external_id as user_id,
        CASE
            WHEN contact_history.browser IS NOT NULL THEN 'Chat'
            WHEN contact_history.email IS NOT NULL THEN 'Email'
            WHEN contact_history.android_device IS NOT NULL THEN 'Android Apps'
            WHEN contact_history.ios_device IS NOT NULL THEN 'iOS Apps'
            ELSE 'Other'
        END AS conversation_channel
    FROM {{ var('contact_history') }} as contact_history
    LEFT JOIN {{ var('conversation_contact_history') }} as conversation_contact_history
    on contact_history.id=conversation_contact_history.contact_id
  ),

latest_conversation_enriched as (
    select 
        latest_conversation.conversation_id,
        latest_conversation.ai_agent_participated,
        latest_conversation.created_at as conversation_created_at,
        latest_conversation.updated_at as conversation_last_updated_at,
        latest_conversation.source_type as conversation_type,
        latest_conversation.source_delivered_as as conversation_initiated_type,
        latest_conversation.source_subject as conversation_subject,
        latest_conversation.assignee_id,
        case when (latest_conversation.assignee_type is not null) then latest_conversation.assignee_type else 'unassigned' end as conversation_assignee_type,
        latest_conversation.source_author_type as conversation_author_type,
        latest_conversation.state as conversation_state,
        ch.conversation_channel,
        ch.user_id,
        latest_conversation.is_read,
        latest_conversation.waiting_since,
        latest_conversation.snoozed_until,
        latest_conversation.sla_name,
        latest_conversation.sla_status,
        latest_conversation.conversation_rating_value as conversation_rating,
        latest_conversation.conversation_rating_remark as conversation_remark,
        latest_conversation.ai_agent_resolution_state

        {{ fivetran_utils.fill_pass_through_columns('intercom__conversation_history_pass_through_columns') }}

    from latest_conversation
    left join contact_history_with_channel as ch
    on latest_conversation.conversation_id = ch.conversation_id

),

--Enriches the latest conversation model with data from conversation_part_events, conversation_string_aggregates, and conversation_tags_aggregate
enriched_final as ( 
    select
        latest_conversation_enriched.*,

        conversation_part_events.first_close_at,
        conversation_part_events.last_close_at,
        conversation_part_events.first_admin_close_at,
        conversation_part_events.last_admin_close_at,

        --If you use conversation tags this will be included, if not it will be ignored.
        {% if var('intercom__using_conversation_tags', True) %}
        conversation_tags_aggregate.all_conversation_tags,
        {% endif %} 

        conversation_part_events.first_close_by_admin_id,
        conversation_part_events.last_close_by_admin_id,
        conversation_part_events.first_close_by_author_id,
        conversation_part_events.last_close_by_author_id,
        conversation_part_events.first_contact_author_id,
        conversation_part_events.last_contact_author_id,
        conversation_part_events.first_team_id,
        conversation_part_events.last_team_id,

        {% if var('intercom__using_team', True) %}
        first_team.name as first_team_name,
        last_team.name as last_team_name,
        {% endif %}

        {% if var('intercom__using_contact_company', True) %}
        contact_enhanced.all_contact_company_names,
        {% endif %}

        conversation_string_aggregates.conversation_admins as all_conversation_admins,
        conversation_string_aggregates.conversation_contacts as all_conversation_contacts

    from latest_conversation_enriched

    left join conversation_string_aggregates
        on conversation_string_aggregates.conversation_id = latest_conversation_enriched.conversation_id

    left join conversation_part_events
        on conversation_part_events.conversation_id = latest_conversation_enriched.conversation_id
    
    {% if var('intercom__using_contact_company', True) %}
    left join contact_enhanced
        on contact_enhanced.contact_id = conversation_part_events.first_contact_author_id
    {% endif %}

    --If you use conversation tags this will be included, if not it will be ignored.
    {% if var('intercom__using_conversation_tags', True) %}
    left join conversation_tags_aggregate
        on conversation_tags_aggregate.conversation_id = latest_conversation_enriched.conversation_id
    {% endif %} 

    {% if var('intercom__using_team', True) %}
    left join team as first_team
        on cast(first_team.team_id as {{ dbt.type_string() }}) = conversation_part_events.first_team_id

    left join team as last_team
        on cast(last_team.team_id as {{ dbt.type_string() }}) = conversation_part_events.last_team_id
    {% endif %}

)
select * 
from enriched_final