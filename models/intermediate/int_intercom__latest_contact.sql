with contact_history as (
  select *
  from {{ ref('stg_intercom__contact_history') }}
),

--Returns the most recent contact record by creating a row number ordered by the contact_updated_at date, then filtering to only return the #1 row per contact.
latest_contact as (
    select
      *,
      row_number() over(partition by contact_id order by updated_at desc) as latest_contact_index --This field will continue through to the final model, however it will have minimal impact on the end-user experience.
    from contact_history
)

select *
from latest_contact
where latest_contact_index = 1
