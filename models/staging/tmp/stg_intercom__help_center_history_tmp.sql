--To disable this model, set the intercom__using_help_center_history variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_articles', True) and var('intercom__using_collection_history', True) and var('intercom__using_help_center_history', True)) }}

{{
    intercom.intercom_union_connections(
        connection_dictionary='intercom_sources',
        single_source_name='intercom',
        single_table_name='help_center_history'
    )
}}
