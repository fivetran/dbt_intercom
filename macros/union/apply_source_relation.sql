{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'intercom') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('intercom_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("intercom_database", target.database) }}' || '.'|| '{{ var("intercom_schema", "intercom") }}' as source_relation
{% endif %}

{%- endmacro %}