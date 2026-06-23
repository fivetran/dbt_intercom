--To disable this model, set the intercom__using_conversation_tags variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_conversation_tags', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='intercom_sources',
        single_source_name='intercom',
        single_table_name='conversation_tag_history'
    )
}}
