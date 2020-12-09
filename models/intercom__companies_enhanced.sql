with company_history as (
  select *
  from {{ ref('stg_intercom__company_history') }}
),

enhanced as (
    select
        company_history.company_history_id as company_id,
        company_history.name as company_name,
        company_history.website,
        company_history.created_at,
        company_history.updated_at,
        company_history.industry,
        company_history.monthly_spend,
        company_history.user_count

        --The below script allows for pass through columns.

        {% if var('companies_enhanced_pass_through_columns') %}
        ,
        {{ var('companies_enhanced_pass_through_columns') | join (", ")}}

        {% endif %}

    from company_history
)

select * 
from enhanced