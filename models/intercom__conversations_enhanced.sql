with conversation_most_recent as (
    select *
    from {{ ref('conversation_most_recent') }}
),

contact_history as (
    select *
    from {{ ref('stg_intercom__contact_history') }}
),

conversation_contact_most_recent as (
    select *
    from {{ ref('conversation_contact_most_recent') }}
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
        conversation_most_recent.conversation_id,
        conversation_most_recent.created_at as conversation_created_at,
        conversation_most_recent.updated_at as conversation_last_updated_at,
        conversation_most_recent.source_type as conversation_type,
        conversation_most_recent.source_delivered_as as conversation_initiated_type,
        conversation_most_recent.source_subject as conversation_subject,
        case when (conversation_most_recent.assignee_type is not null) then conversation_most_recent.assignee_type else 'unassigned' end as conversation_assignee_type,
        case when (conversation_most_recent.source_author_type != 'admin') then 'contact' else 'admin' end as conversation_author_type,
        conversation_part_events.first_assigned_to_admin_id,
        conversation_part_events.last_close_by_admin_id,
        conversation_part_events.first_contact_author_id,
        conversation_part_events.last_contact_author_id,
        conversation_most_recent.state as conversation_state,
        conversation_most_recent.is_read,
        conversation_most_recent.waiting_since,
        conversation_most_recent.snoozed_until,
        conversation_string_aggregates.conversation_admins as all_conversation_admins,
        conversation_string_aggregates.conversation_contacts as all_conversation_contacts,
        conversation_most_recent.conversation_rating_value as conversation_rating,
        conversation_most_recent.conversation_rating_remark as conversation_remark,
    from conversation_most_recent

    left join conversation_contact_most_recent 
        on conversation_contact_most_recent.conversation_id = conversation_most_recent.conversation_id

    left join contact_history
        on contact_history.contact_id = conversation_contact_most_recent.contact_id

    left join conversation_string_aggregates
        on conversation_string_aggregates.conversation_id = conversation_most_recent.conversation_id

    left join conversation_part_events
        on conversation_part_events.conversation_id = conversation_most_recent.conversation_id

)
select * 
from enriched