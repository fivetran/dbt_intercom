with contact_history as (
  select *
  from {{ ref('stg_intercom__contact_history') }}
),

--Create an index to determine the most recent contact.
contact_index as (
  select
    *,
    row_number() over (partition by contact_id order by updated_at desc) as latest_contact_index
  from contact_history
),

--Filter out previous contact records.
lastest_contact as (
  select
    *
  from contact_index
  where latest_contact_index = 1
),

--Inner join on latest_contact in order to get most recent contact record without bringing through latest_contact_index.
final as (
  select 
    contact_history.*
  from contact_history
  
  inner join lastest_contact
    on lastest_contact.contact_id = contact_history.contact_id
      and lastest_contact.updated_at = contact_history.updated_at
)

select * 
from final
