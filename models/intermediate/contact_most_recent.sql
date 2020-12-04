with contact_history as (
  select *
  from {{ ref('stg_intercom__contact_history') }}
),

recent_contact as (
    select
        *,
        row_number() over(partition by contact_id order by updated_at desc) as recent_contact_index
        
    from contact_history
)

select *
from recent_contact
where recent_contact_index = 1