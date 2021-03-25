with latest_conversation as (
    select *
    from {{ ref('int_intercom__latest_conversation') }}
),

latest_conversation_contact as (
    select *
    from {{ ref('int_intercom__latest_conversation_contact') }}
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
    from {{ ref('stg_intercom__conversation_tag_history') }}
),

tags as (
    select *
    from {{ ref('stg_intercom__tag') }}
),

--Aggregates the tags associated with a single conversation into an array.
conversation_tags_aggregate as (
    select
        latest_conversation.conversation_id,
        {{ fivetran_utils.string_agg('tags.name', "', '" ) }} as all_conversation_tags
    from latest_conversation

    left join conversation_tags
        on conversation_tags.conversation_id = latest_conversation.conversation_id
        
    left join tags
        on tags.tag_id = conversation_tags.tag_id

    group by 1    
),
{% endif %}  

--Enriches the latest conversation model with data from conversation_part_events, conversation_string_aggregates, and conversation_tags_aggregate
enriched as ( 
    select
        latest_conversation.conversation_id,
        latest_conversation.created_at as conversation_created_at,
        latest_conversation.updated_at as conversation_last_updated_at,
        conversation_part_events.first_close_at,
        conversation_part_events.last_close_at,
        latest_conversation.source_type as conversation_type,
        latest_conversation.source_delivered_as as conversation_initiated_type,

        --If you use conversation tags this will be included, if not it will be ignored.
        {% if var('intercom__using_conversation_tags', True) %}
        conversation_tags_aggregate.all_conversation_tags,
        {% endif %} 

        latest_conversation.source_subject as conversation_subject,
        case when (latest_conversation.assignee_type is not null) then latest_conversation.assignee_type else 'unassigned' end as conversation_assignee_type,
        latest_conversation.source_author_type as conversation_author_type,
        conversation_part_events.first_close_by_admin_id,
        conversation_part_events.last_close_by_admin_id,
        conversation_part_events.first_contact_author_id,
        conversation_part_events.last_contact_author_id,
        latest_conversation.state as conversation_state,
        latest_conversation.is_read,
        latest_conversation.waiting_since,
        latest_conversation.snoozed_until,
        latest_conversation.sla_name,
        latest_conversation.sla_status,
        conversation_string_aggregates.conversation_admins as all_conversation_admins,
        conversation_string_aggregates.conversation_contacts as all_conversation_contacts,

        {% if var('intercom__using_contact_company', True) %}
        contact_enhanced.all_contact_company_names,
        {% endif %}

        latest_conversation.conversation_rating_value as conversation_rating,
        latest_conversation.conversation_rating_remark as conversation_remark
    from latest_conversation

    left join latest_conversation_contact 
        on latest_conversation_contact.conversation_id = latest_conversation.conversation_id

    left join conversation_string_aggregates
        on conversation_string_aggregates.conversation_id = latest_conversation.conversation_id

    left join conversation_part_events
        on conversation_part_events.conversation_id = latest_conversation.conversation_id
    
    {% if var('intercom__using_contact_company', True) %}
    left join contact_enhanced
        on contact_enhanced.contact_id = conversation_part_events.first_contact_author_id
    {% endif %}

    --If you use conversation tags this will be included, if not it will be ignored.
    {% if var('intercom__using_conversation_tags', True) %}
    left join conversation_tags_aggregate
      on conversation_tags_aggregate.conversation_id = latest_conversation.conversation_id
    {% endif %} 

)
select * 
from enriched