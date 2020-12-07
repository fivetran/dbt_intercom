with conversation_part_history as (
  select *
  from {{ ref('stg_intercom__conversation_part_history') }}
),

admin_conversation_parts as (
    select distinct
        conversation_id,
        author_id
    from conversation_part_history

    where author_type = 'admin'

),

admin_conversation_aggregates as (
    select 
        conversation_id,
        {{ fivetran_utils.string_agg('author_id', "', '" ) }} as conversation_admins
    from admin_conversation_parts
    group by 1
),

contact_conversation_parts as (
    select distinct
        conversation_id,
        author_id
    from conversation_part_history

    where author_type in ('user', 'lead') 

),

contact_conversation_aggregates as (
    select 
        conversation_id,
        {{ fivetran_utils.string_agg('author_id', "', '" ) }} as conversation_contacts
    from contact_conversation_parts
    group by 1
),

final as (
    select distinct
        conversation_part_history.conversation_id,
        admin_conversation_aggregates.conversation_admins,
        contact_conversation_aggregates.conversation_contacts

    from conversation_part_history

    left join admin_conversation_aggregates
        on admin_conversation_aggregates.conversation_id = conversation_part_history.conversation_id

    left join contact_conversation_aggregates
        on contact_conversation_aggregates.conversation_id = conversation_part_history.conversation_id
)

select *
from final