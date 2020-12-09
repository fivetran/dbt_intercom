with conversation_contact_history as (
  select *
  from {{ ref('stg_intercom__conversation_contact_history') }}
),

lastest_conversation_contact as (
    select
      *,
      row_number() over(partition by conversation_id order by conversation_updated_at desc) as lastest_conversation_contact_index
    from conversation_contact_history
)

select *
from lastest_conversation_contact
where lastest_conversation_contact_index = 1