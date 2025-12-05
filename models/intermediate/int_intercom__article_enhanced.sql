--To disable this model, set the intercom__using_articles variable within your dbt_project.yml file to False.
{{ config(enabled=var('intercom__using_articles', True)) }}

with articles as (
    select *
    from {{ ref('stg_intercom__article_history') }}
    where coalesce(_fivetran_active, true)
),

collections as (
    select *
    from {{ ref('stg_intercom__collection_history') }}
    where coalesce(_fivetran_active, true)
),

-- Self-join to get parent collection details for nested sections
parent_collections as (
    select *
    from {{ ref('stg_intercom__collection_history') }}
    where coalesce(_fivetran_active, true)
),

admins as (
    select *
    from {{ ref('stg_intercom__admin') }}
),

help_centers as (
    select *
    from {{ ref('stg_intercom__help_center_history') }}
    where coalesce(_fivetran_active, true)
),

final as (
    select
        -- Source relation for multi-connection support
        articles.source_relation,
        
        -- Article identifiers
        articles.article_id,
        
        -- Article content
        articles.article_title,
        articles.article_description,
        articles.article_body,
        articles.article_url,
        articles.article_type,
        articles.article_state,
        articles.default_locale,
        articles.workspace_id,
        
        -- Article statistics
        articles.statistics_views,
        articles.statistics_conversations,
        articles.statistics_reactions,
        articles.statistics_happy_reaction_percentage,
        articles.statistics_neutral_reaction_percentage,
        articles.statistics_sad_reaction_percentage,
        
        -- Collection details (direct parent)
        articles.collection_id,
        collections.collection_name,
        collections.collection_description,
        collections.collection_url,
        collections.collection_icon,
        collections.display_order as collection_display_order,
        
        -- Parent collection details (for nested sections)
        collections.parent_collection_id,
        parent_collections.collection_name as parent_collection_name,
        parent_collections.collection_url as parent_collection_url,
        
        -- Author details
        articles.author_id,
        admins.name as author_name,
        admins.job_title as author_job_title,
        
        -- Help center details
        collections.help_center_id,
        help_centers.help_center_name,
        help_centers.help_center_identifier,
        help_centers.is_website_enabled as is_help_center_website_enabled,
        
        -- Timestamps
        articles.created_at as article_created_at,
        articles.updated_at as article_updated_at,
        
        -- Derived fields
        case 
            when articles.article_state = 'published' then true 
            else false 
        end as is_published,
        
        case 
            when collections.parent_collection_id is not null then true 
            else false 
        end as is_in_nested_section,
        
        -- Fivetran metadata
        articles._fivetran_active,
        articles._fivetran_start,
        articles._fivetran_end

    from articles

    left join collections
        on articles.collection_id = collections.collection_id
        and articles.source_relation = collections.source_relation

    left join parent_collections
        on collections.parent_collection_id = parent_collections.collection_id
        and collections.source_relation = parent_collections.source_relation

    left join admins
        on articles.author_id = admins.admin_id
        and articles.source_relation = admins.source_relation

    left join help_centers
        on collections.help_center_id = help_centers.help_center_id
        and collections.source_relation = help_centers.source_relation
)

select * 
from final

