with company_history as (
  select *
  from {{ ref('stg_intercom__company_history') }}
),

recent_company as (
    select
        *,
        row_number() over(partition by company_history_id order by updated_at desc) as recent_company_index
        
    from company_history
)

select *
from recent_company
where recent_company_index = 1