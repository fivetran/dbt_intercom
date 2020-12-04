with contact_most_recent as (
  select *
  from {{ ref('contact_most_recent') }}
),

contact_company_history as (
  select *
  from {{ ref('stg_intercom__contact_company_history') }}
),

company_most_recent as (
  select *
  from {{ ref('company_most_recent') }}
),

tags as(
    select * 
    from {{ ref('stg_intercom__tag') }}
),

contact_tag_history as(
    select * 
    from {{ ref('stg_intercom__contact_tag_history') }}
),

company_tag_history as(
    select * 
    from {{ ref('stg_intercom__company_tag_history') }}
),

final as (
  select
    contact_most_recent.contact_id,
    contact_most_recent.name as contact_name,
    contact_tags.name as contact_tag, --need to determine how to better use tags with m2m relation
    contact_most_recent.role as contact_role,
    contact_most_recent.email as contact_email,
    contact_most_recent.last_contacted_at,
    contact_most_recent.last_email_clicked_at,
    contact_most_recent.last_email_opened_at,
    contact_most_recent.last_replied_at,
    contact_most_recent.is_unsubscribed_from_emails,
    company_most_recent.name as contact_company,
    company_tags.name as company_tag, --need to determine how to better use tags with m2m relation
    company_most_recent.user_count as company_size

  from contact_most_recent

  left join contact_tag_history
    on contact_tag_history.contact_id = contact_most_recent.contact_id
  
  left join contact_company_history
    on contact_company_history.contact_id = contact_most_recent.contact_id

  left join company_most_recent
    on company_most_recent.company_id = contact_company_history.company_id

  left join company_tag_history
    on company_tag_history.company_id = company_most_recent.company_id

  left join tags as company_tags
    on company_tags.tag_id = company_tag_history.tag_id

  left join tags as contact_tags
    on contact_tags.tag_id = contact_tag_history.tag_id
  
  where admin_id is null
)

select *
from final 