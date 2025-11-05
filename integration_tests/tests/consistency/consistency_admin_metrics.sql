{{ config(
    tags="fivetran_validations",
    enabled=(var('fivetran_validation_tests_enabled', false))
) }}

{% set exclude_cols = ['source_relation'] + var('consistency_test_exclude_metrics', []) %}

-- this test ensures the intercom__admin_metrics end model matches the prior version
with prod as (
    select {{ dbt_utils.star(from=ref('intercom__admin_metrics'), except=exclude_cols) }}
    from {{ target.schema }}_intercom_prod.intercom__admin_metrics
),

dev as (
    select {{ dbt_utils.star(from=ref('intercom__admin_metrics'), except=exclude_cols) }}
    from {{ target.schema }}_intercom_dev.intercom__admin_metrics
),

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final
