{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)) }}

{# This test is to check if the conversations has the same number of transactions 
as the source conversation history table. #}

with conversation_source_count as (

    select count(distinct conversation_id) as stg_count
    from {{ target.schema }}_intercom_dev.stg_intercom__conversation_history
    where coalesce(_fivetran_active, true)
),

conversation_end_count as (

    select count(distinct conversation_id) as end_count
    from {{ target.schema }}_intercom_dev.intercom__conversation_enhanced
),

final as (
    select *
    from conversation_source_count
    join conversation_end_count
        on stg_count != end_count
)

select *
from final