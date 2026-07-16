--percentile calculation specific to DuckDB
{% macro duckdb__percentile(percentile_field, partition_field, percent) %}

    quantile_cont({{ percentile_field }}, {{ percent }})
    /* have to group by partition field */

{% endmacro %}
