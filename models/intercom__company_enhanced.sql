--This model will only run if the using_contact_company variable within your dbt_project.yml file is set to True.
{{ config(enabled=var('using_contact_company', True)) }}

with company_history as (
  select *
  from {{ ref('stg_intercom__company_history') }}
),

--If you use company tags this will be included, if not it will be ignored.
{% if var('using_company_tags', True) %}
company_tags as (
  select *
  from {{ ref('stg_intercom__company_tag_history') }}
),

tags as (
  select *
  from {{ ref('stg_intercom__tag') }}
),

company_tags_aggregate as (
  select
    company_history.company_history_id,
    {{ fivetran_utils.string_agg('tags.name', "', '" ) }} as all_company_tags
  from company_history

  left join company_tags
      on company_tags.company_id = company_history.company_history_id
    
    left join tags
      on tags.tag_id = company_tags.tag_id

  group by 1    
),
{% endif %}

enhanced as (
    select
        company_history.company_history_id as company_id,
        company_history.name as company_name,
        company_history.created_at,

        --If you use company tags this will be included, if not it will be ignored.
        {% if var('using_company_tags', True) %}
        company_tags_aggregate.all_company_tags,
        {% endif %}

        company_history.website,       
        company_history.industry,
        company_history.monthly_spend,
        company_history.user_count,
        company_history.session_count,
        company_history.updated_at

        --The below script allows for pass through columns.
        {% if var('company_pass_through_columns') %}
        ,
        {{ var('company_pass_through_columns') | join (", ")}}

        {% endif %}

    from company_history

    --If you use company tags this will be included, if not it will be ignored.
    {% if var('using_company_tags', True) %}
    left join company_tags_aggregate
      on company_tags_aggregate.company_history_id = company_history.company_history_id
    {% endif %}
)

select * 
from enhanced