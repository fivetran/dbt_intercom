with conversation_part_history as (
  
  select *
  from {{ ref('stg_intercom__conversation_part_history') }}
),

conversation_events as (

  select distinct
    conversation_id,
    -- Admin close events: Captures the first and last admin-authored close events for each conversation
    -- The window function uses a custom ordering: admin close events (0) are prioritized over others (1),
    -- then ordered by created_at. This ensures first_value() returns only admin close events if they exist.
    first_value(case when part_type = 'close' and author_type = 'admin' then author_id end)
      over (partition by conversation_id order by case when part_type = 'close' and author_type = 'admin' then 0 else 1 end,
        created_at asc rows between unbounded preceding and unbounded following) as first_close_by_admin_id,
    first_value(case when part_type = 'close' and author_type = 'admin' then author_id end)
      over (partition by conversation_id order by case when part_type = 'close' and author_type = 'admin' then 0 else 1 end,
        created_at desc rows between unbounded preceding and unbounded following) as last_close_by_admin_id,
    first_value(case when part_type = 'close' and author_type = 'admin' then created_at end)
      over (partition by conversation_id order by case when part_type = 'close' and author_type = 'admin' then 0 else 1 end,
        created_at asc rows between unbounded preceding and unbounded following) as first_admin_close_at,
    first_value(case when part_type = 'close' and author_type = 'admin' then created_at end)
      over (partition by conversation_id order by case when part_type = 'close' and author_type = 'admin' then 0 else 1 end,
        created_at desc rows between unbounded preceding and unbounded following) as last_admin_close_at,           
    -- All close events: Captures the first and last close events regardless of author type
    -- Similar window function logic: close events (0) are prioritized, then ordered by created_at
    -- This includes closes by admins, users, or any other author type
    first_value(case when part_type = 'close' then author_id end) 
      over (partition by conversation_id order by case when part_type = 'close' then 0 else 1 end,
      created_at asc rows between unbounded preceding and unbounded following) as first_close_by_author_id,
    first_value(case when part_type = 'close' then author_id end)
      over (partition by conversation_id order by case when part_type = 'close' then 0 else 1 end,
      created_at desc rows between unbounded preceding and unbounded following) as last_close_by_author_id,
    first_value(case when part_type = 'close' then created_at end)
      over (partition by conversation_id order by case when part_type = 'close' then 0 else 1 end,
      created_at asc rows between unbounded preceding and unbounded following) as first_close_at,
    first_value(case when part_type = 'close' then created_at end)
      over (partition by conversation_id order by case when part_type = 'close' then 0 else 1 end,
      created_at desc rows between unbounded preceding and unbounded following) as last_close_at,   
    -- Contact author events: Captures the first and last events authored by contacts (users or leads)
    -- Window function prioritizes contact-authored events (0) over others (1), then orders by created_at
    -- This identifies which contacts initiated and last participated in the conversation
    first_value(case when author_type in ('user','lead') then author_id end)
      over (partition by conversation_id order by case when author_type in ('user','lead') then 0 else 1 end,
      created_at asc rows between unbounded preceding and unbounded following) as first_contact_author_id,
    first_value(case when author_type in ('user','lead') then author_id end)
      over (partition by conversation_id order by case when author_type in ('user','lead') then 0 else 1 end,
      created_at desc rows between unbounded preceding and unbounded following) as last_contact_author_id,
    -- Team assignment events: Captures the first and last team assignments for each conversation
    -- Window function prioritizes team assignments (0) over others (1), then orders by created_at
    -- This tracks conversation ownership and routing through different teams
    first_value(case when assigned_to_type = 'team' then assigned_to_id end)
      over (partition by conversation_id order by case when assigned_to_type = 'team' then 0 else 1 end,
      created_at asc rows between unbounded preceding and unbounded following) as first_team_id,
    first_value(case when assigned_to_type = 'team' then assigned_to_id end)
      over (partition by conversation_id order by case when assigned_to_type = 'team' then 0 else 1 end,
      created_at desc rows between unbounded preceding and unbounded following) as last_team_id  
    from conversation_part_history
),

final as (
    select
        conversation_id,
        cast(first_close_by_admin_id as {{ dbt.type_string() }}) as first_close_by_admin_id,
        cast(last_close_by_admin_id as {{ dbt.type_string() }}) as last_close_by_admin_id,
        cast(first_close_by_author_id as {{ dbt.type_string() }}) as first_close_by_author_id,
        cast(last_close_by_author_id as {{ dbt.type_string() }}) as last_close_by_author_id,
        cast(first_contact_author_id as {{ dbt.type_string() }}) as first_contact_author_id,
        cast(last_contact_author_id as {{ dbt.type_string() }}) as last_contact_author_id,
        cast(first_team_id as {{ dbt.type_string() }}) as first_team_id,
        cast(last_team_id as {{ dbt.type_string() }}) as last_team_id,
        first_admin_close_at,
        last_admin_close_at,
        first_close_at,
        last_close_at
    from conversation_events
)

select *
from final