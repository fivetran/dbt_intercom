with contact_history as (
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

--If you use contact tags this will be included, if not it will be ignored.
{% if var('using_contact_tags', True) %}
contact_tags as (
  select *
  from {{ ref('stg_intercom__contact_tag_history') }}
),
 

tags as (
  select *
  from {{ ref('stg_intercom__tag') }}
),

--Aggregates the tags associated with a single contact into an array.
contact_tags_aggregate as (
  select
    contact_history.contact_id,
    {{ fivetran_utils.string_agg('tags.name', "', '" ) }} as all_contact_tags
  from contact_history

  left join contact_tags
      on contact_tags.contact_id = contact_history.contact_id
    
    left join tags
      on tags.tag_id = contact_tags.tag_id

  group by 1  
),
{% endif %}  

--Joins the contact table with tags (if used) as well as the contact company (if used).
final as (
  select
    contact_history.contact_id,
    contact_history.name as contact_name,
        
    --If you use contact tags this will be included, if not it will be ignored.
    {% if var('using_contact_tags', True) %}
    contact_tags_aggregate.all_contact_tags,  
    {% endif %}

    contact_history.role as contact_role,
    contact_history.email as contact_email,
    contact_history.last_contacted_at,
    contact_history.last_email_opened_at,
    contact_history.last_email_clicked_at,
    contact_history.last_replied_at,
    contact_history.is_unsubscribed_from_emails,
    company_history.company_history_id as company_id

    --The below script allows for pass through columns.
    {% if var('contact_pass_through_columns') %}
    ,
    {{ var('contact_pass_through_columns') | join (", ")}}

    {% endif %}

  from contact_history
  
  left join contact_company_history
    on contact_company_history.contact_id = contact_history.contact_id

  left join company_history
    on company_history.company_history_id = contact_company_history.company_id

  {% if var('using_contact_tags', True) %}
  left join contact_tags_aggregate
      on contact_tags_aggregate.contact_id = contact_history.contact_id
  {% endif %}
)

select *
from final 