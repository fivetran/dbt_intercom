with conversation_most_recent as (
    select *
    from {{ ref('conversation_most_recent') }}
),

conversation_part_history as (
    select *
    from {{ ref('stg_intercom__conversation_part_history') }}
),

conversation_contact_history as (
    select *
    from {{ ref('stg_intercom__conversation_contact_history') }}
),

contact_most_recent as (
    select *
    from {{ ref('contact_most_recent') }}
),

admin_table as (
    select *
    from {{ ref('stg_intercom__admin') }}
),

enriched as (
    select
        conversation_most_recent.conversation_id,
        conversation_most_recent.created_at as conversation_created_at,
        conversation_most_recent.updated_at as conversation_last_updated_at,
        case when (conversation_most_recent.source_author_type != 'admin') then 'Customer' else 'Team' end as conversation_author_type,
        case when (conversation_most_recent.source_author_type != 'admin') then customer.name else employee.name end as conversation_author,
        conversation_most_recent.assignee_id as conversation_assignee_id,
        conversation_most_recent.assignee_type as conversation_assignee_type,
        case when (employee.name is null) then 'Unassigned' else employee.name end as conversation_latest_assignee,
        conversation_most_recent.source_delivered_as as conversation_initiated_type,
        conversation_most_recent.source_type as conversation_type,
        conversation_most_recent.source_subject as conversation_subject,
        --tag.name as conversation_tag,
        conversation_most_recent.state as conversation_state,
        conversation_most_recent.is_open,
        conversation_most_recent.is_read,
        conversation_most_recent.waiting_since,
        conversation_most_recent.snoozed_until,
        conversation_most_recent.conversation_rating_value as conversation_rating,
        conversation_most_recent.conversation_rating_remark as conversation_remark,

    from conversation_most_recent

    left join admin_table as employee
        on employee.admin_id = conversation_most_recent.assignee_id

    left join contact_most_recent as customer
        on customer.contact_id = conversation_most_recent.source_author_id

    -- left join conversation_tag_history
    --     on conversation_tag_history.conversation_id = conversation_most_recent.id

    -- left join tag   
    --     on tag.id = conversation_tag_history.tag_id


)
select * 
from enriched