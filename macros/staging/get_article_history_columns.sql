{% macro get_article_history_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": "boolean"},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "author_id", "datatype": dbt.type_string()},
    {"name": "body", "datatype": dbt.type_string()},
    {"name": "collection_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "default_locale", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "parent_type", "datatype": dbt.type_string()},
    {"name": "section_id", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "statistics_conversations", "datatype": dbt.type_int()},
    {"name": "statistics_happy_reaction_percentage", "datatype": dbt.type_float()},
    {"name": "statistics_neutral_reaction_percentage", "datatype": dbt.type_float()},
    {"name": "statistics_reactions", "datatype": dbt.type_int()},
    {"name": "statistics_sad_reaction_percentage", "datatype": dbt.type_float()},
    {"name": "statistics_type", "datatype": dbt.type_string()},
    {"name": "statistics_views", "datatype": dbt.type_int()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "url", "datatype": dbt.type_string()},
    {"name": "workspace_id", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('intercom__article_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}