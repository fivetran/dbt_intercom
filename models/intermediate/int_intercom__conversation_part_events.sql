with conversation_part_history as (
  select *
  from {{ var('conversation_part_history') }}
),

--Obtains the first and last values for conversations where the part type was close and part was authored by an admin.
conversation_admin_events as (
  select
    conversation_id,
    first_value(author_id ignore nulls) over (partition by conversation_id order by created_at asc, conversation_id rows unbounded preceding) as first_close_by_admin_id,
    first_value(author_id ignore nulls) over (partition by conversation_id order by created_at desc, conversation_id rows unbounded preceding) as last_close_by_admin_id,
    first_value(created_at ignore nulls) over (partition by conversation_id order by created_at asc, conversation_id rows unbounded preceding) as first_close_at,
    first_value(created_at ignore nulls) over (partition by conversation_id order by created_at desc, conversation_id rows unbounded preceding) as last_close_at
  from conversation_part_history

  where part_type = 'close' and author_type = 'admin'

), 

--Obtains the first and last values for conversations where the part type was authored by a contact (which is either a user or lead).
conversation_contact_events as (
  select
    conversation_id,
    first_value(author_id ignore nulls) over (partition by conversation_id order by created_at asc, conversation_id rows unbounded preceding) as first_contact_author_id,
    first_value(author_id ignore nulls) over (partition by conversation_id order by created_at desc, conversation_id rows unbounded preceding) as last_contact_author_id
  from conversation_part_history

  where author_type in ('user','lead')

), 

--Obtains the first and last values for conversations where the part type was authored by a team
conversation_team_events as (
  select
    conversation_id,
    first_value(author_id ignore nulls) over (partition by conversation_id order by created_at asc, conversation_id rows unbounded preceding) as first_team_id,
    first_value(author_id ignore nulls) over (partition by conversation_id order by created_at desc, conversation_id rows unbounded preceding) as last_team_id
  from conversation_part_history

  where author_type = 'team'
),

--Joins the above two CTEs with conversation part history. Distinct was necessary to ensure only one first/last value was returned for each individual conversation.
final as (
    select distinct
        conversation_part_history.conversation_id,
        cast(conversation_admin_events.first_close_by_admin_id as {{ dbt_utils.type_string() }}) as first_close_by_admin_id,
        cast(conversation_admin_events.last_close_by_admin_id as {{ dbt_utils.type_string() }}) as last_close_by_admin_id,
        cast(conversation_contact_events.first_contact_author_id as {{ dbt_utils.type_string() }}) as first_contact_author_id,
        cast(conversation_contact_events.last_contact_author_id as {{ dbt_utils.type_string() }}) as last_contact_author_id,
        cast(conversation_team_events.first_team_id as {{ dbt_utils.type_string() }}) as first_team_id,
        cast(conversation_team_events.last_team_id as {{ dbt_utils.type_string() }}) as last_team_id,
        conversation_admin_events.first_close_at,
        conversation_admin_events.last_close_at
    from conversation_part_history

    left join conversation_admin_events
        on conversation_admin_events.conversation_id = conversation_part_history.conversation_id

    left join conversation_contact_events
        on conversation_contact_events.conversation_id = conversation_part_history.conversation_id

    left join conversation_team_events
        on conversation_team_events.conversation_id = conversation_part_history.conversation_id
)

select *
from final
