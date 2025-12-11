--To disable this model, set the intercom__using_articles variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_articles', True)) }}

with base as (

    select * 
    from {{ ref('stg_intercom__collection_history_tmp') }}

),

fields as (

    select
    /*
    The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
    that are expected/needed (staging_columns from dbt_intercom/models/tmp/) and compares it with columns 
    in the source (source_columns from dbt_intercom/macros/).
    For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
    */

        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_intercom__collection_history_tmp')),
                staging_columns=get_collection_history_columns()
            )
        }}
        {{ intercom.apply_source_relation() }}

    from base
),

final as (

    select
        source_relation,
        cast(id as {{ dbt.type_string() }}) as collection_id,
        cast(help_center_id as {{ dbt.type_string() }}) as help_center_id,
        cast(parent_id as {{ dbt.type_string() }}) as parent_collection_id,
        name as collection_name,
        description as collection_description,
        url as collection_url,
        icon as collection_icon,
        type as collection_type,
        default_locale,
        workspace_id,
        display_order,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        _fivetran_active,
        cast(_fivetran_start as {{ dbt.type_timestamp() }}) as _fivetran_start,
        cast(_fivetran_end as {{ dbt.type_timestamp() }}) as _fivetran_end,
        cast(_fivetran_synced as {{ dbt.type_timestamp() }}) as _fivetran_synced

        --The below script allows for pass through columns.
        {{ fivetran_utils.fill_pass_through_columns('intercom__collection_history_pass_through_columns') }}
    from fields
)

select * 
from final
where coalesce(_fivetran_active, true)

