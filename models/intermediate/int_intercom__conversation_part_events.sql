with conversation_part_history as (
  select *
  from {{ ref('stg_intercom__conversation_part_history') }}
),

conversation_admin_events as (

  select
    conversation_id,
    {{ fivetran_utils.first_value("author_id","conversation_id","created_at","asc") }} as first_assigned_to_admin_id,
    {{ fivetran_utils.first_value("author_id","conversation_id","created_at","desc") }} as last_close_by_admin_id,
    {{ fivetran_utils.first_value("created_at","conversation_id","created_at","asc") }} as last_close_at,
    {{ fivetran_utils.first_value("created_at","conversation_id","created_at","desc") }} as first_close_at
  from conversation_part_history

  where part_type = 'close' and author_type = 'admin'

), 

conversation_contact_events as (

  select
    conversation_id,
    {{ fivetran_utils.first_value("author_id","conversation_id","created_at","asc") }} as first_contact_author_id,
    {{ fivetran_utils.first_value("author_id","conversation_id","created_at","desc") }} as last_contact_author_id
  from conversation_part_history

  where author_type in ('user','lead')

), 

final as (
    select distinct
        conversation_part_history.conversation_id,
        
        {% if target.type == 'bigquery' %}
          cast(conversation_admin_events.first_assigned_to_admin_id as INT64) as first_assigned_to_admin_id,
          cast(conversation_admin_events.last_close_by_admin_id as INT64) as last_close_by_admin_id,
          cast(conversation_contact_events.first_contact_author_id as string) as first_contact_author_id,
          cast(conversation_contact_events.last_contact_author_id as string) as last_contact_author_id,
        {% else %}
          cast(conversation_admin_events.first_assigned_to_admin_id as bigint) as first_assigned_to_admin_id,
          cast(conversation_admin_events.last_close_by_admin_id as bigint) as last_close_by_admin_id,
          cast(conversation_contact_events.first_contact_author_id as varchar(50)) as first_contact_author_id,
          cast(conversation_contact_events.last_contact_author_id as varchar(50)) as last_contact_author_id,
        {% endif %}

        conversation_admin_events.last_close_at,
        conversation_admin_events.first_close_at
    from conversation_part_history

    left join conversation_admin_events
        on conversation_admin_events.conversation_id = conversation_part_history.conversation_id

    left join conversation_contact_events
        on conversation_contact_events.conversation_id = conversation_part_history.conversation_id
)

select *
from final
