with conversation_part_history as (
  select *
  from {{ ref('stg_intercom__conversation_part_history') }}
),

admin_conversation_parts as (
    select
        conversation_id,
        {% if target.type == 'bigquery' %}
        cast(author_id as string) as author_id
        {% else %}
        cast(author_id as varchar(25)) as author_id
        {% endif %}
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
    select
        conversation_id,
        {% if target.type == 'bigquery' %}
        cast(author_id as string) as author_id
        {% else %}
        cast(author_id as varchar(25)) as author_id
        {% endif %}
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
    select
        admin_conversation_aggregates.conversation_id,
        admin_conversation_aggregates.conversation_admins,
        contact_conversation_aggregates.conversation_contacts
    from admin_conversation_aggregates

    left join contact_conversation_aggregates
        on contact_conversation_aggregates.conversation_id = admin_conversation_aggregates.conversation_id
)

select *
from final