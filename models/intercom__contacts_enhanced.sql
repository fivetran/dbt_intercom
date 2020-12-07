with contact_most_recent as (
  select *
  from {{ ref('stg_intercom__contact_history') }}
),

contact_company_history as (
  select *
  from {{ ref('stg_intercom__contact_company_history') }}
),

company_history as (
  select *
  from {{ ref('stg_intercom__company_history') }}
),

final as (
  select
    contact_most_recent.contact_id,
    contact_most_recent.name as contact_name,              
    contact_most_recent.role as contact_role,
    contact_most_recent.email as contact_email,
    contact_most_recent.last_contacted_at,
    contact_most_recent.last_email_opened_at,
    contact_most_recent.last_email_clicked_at,
    contact_most_recent.last_replied_at,
    contact_most_recent.is_unsubscribed_from_emails,
    company_history.company_history_id as company_id

  from contact_most_recent
  
  left join contact_company_history
    on contact_company_history.contact_id = contact_most_recent.contact_id

  left join company_history
    on company_history.company_history_id = contact_company_history.company_id
  
  where admin_id is null
)

select *
from final 