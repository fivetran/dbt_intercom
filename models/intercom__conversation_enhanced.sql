with latest_conversation as (
    select *
    from {{ ref('latest_conversation') }}
),

contact_history as (
    select *
    from {{ ref('stg_intercom__contact_history') }}
),

latest_conversation_contact as (
    select *
    from {{ ref('latest_conversation_contact') }}
),

conversation_string_aggregates as (
    select *
    from {{ ref('conversation_string_aggregates') }}
),

conversation_part_events as (
    select *
    from {{ ref('conversation_part_events') }}
),

enriched as (
    select
        latest_conversation.conversation_id,
        latest_conversation.created_at as conversation_created_at,
        latest_conversation.updated_at as conversation_last_updated_at,
        latest_conversation.source_type as conversation_type,
        latest_conversation.source_delivered_as as conversation_initiated_type,
        latest_conversation.source_subject as conversation_subject,
        case when (latest_conversation.assignee_type is not null) then latest_conversation.assignee_type else 'unassigned' end as conversation_assignee_type,
        case when (latest_conversation.source_author_type != 'admin') then 'contact' else 'admin' end as conversation_author_type,
        conversation_part_events.first_assigned_to_admin_id,
        conversation_part_events.last_close_by_admin_id,
        conversation_part_events.first_contact_author_id,
        conversation_part_events.last_contact_author_id,
        latest_conversation.state as conversation_state,
        latest_conversation.is_read,
        latest_conversation.waiting_since,
        latest_conversation.snoozed_until,
        conversation_string_aggregates.conversation_admins as all_conversation_admins,
        conversation_string_aggregates.conversation_contacts as all_conversation_contacts,
        latest_conversation.conversation_rating_value as conversation_rating,
        latest_conversation.conversation_rating_remark as conversation_remark
    from latest_conversation

    left join latest_conversation_contact 
        on latest_conversation_contact.conversation_id = latest_conversation.conversation_id

    left join contact_history
        on contact_history.contact_id = latest_conversation_contact.contact_id

    left join conversation_string_aggregates
        on conversation_string_aggregates.conversation_id = latest_conversation.conversation_id

    left join conversation_part_events
        on conversation_part_events.conversation_id = latest_conversation.conversation_id

)
select * 
from enriched