--To disable this model, set the intercom__using_articles variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_articles', True)) }}

with article_enhanced as (
    select *
    from {{ ref('int_intercom__article_enhanced') }}
)

select *
from article_enhanced

