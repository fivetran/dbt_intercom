with contact_history as (
  select *
  from {{ ref('stg_intercom__contact_history') }}
),

--take latest contact history to get the last update for the contact.
lastest_contact as (
  select
    *,
    row_number() over (partition by contact_id order by updated_at desc) as latest_contact_index
  from contact_history
)

select
    *
from lastest_contact
where latest_contact_index = 1
