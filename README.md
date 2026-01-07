<!--section="intercom_transformation_model"-->
# Intercom dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_intercom/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Intercom connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 42
- Connector documentation
  - [Intercom connector documentation](https://fivetran.com/docs/connectors/applications/intercom)
  - [Intercom ERD](https://fivetran.com/docs/connectors/applications/intercom#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_intercom)
  - [dbt Docs](https://fivetran.github.io/dbt_intercom/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_intercom/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_intercom/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to better understand the performance, responsiveness, and effectiveness of your team's conversations with customers via Intercom. It creates enriched models with metrics focused on conversation performance, admin performance, and customer engagement.

> NOTE: Intercom V2.0 does not support API exposure to company-defined business hours. We therefore calculate all `time_to` metrics in their entirety without subtracting business hours.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_intercom
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [intercom__admin_metrics](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__admin_metrics.sql) | Tracks individual admin performance by team including conversation volumes, customer satisfaction ratings, and response times to measure support efficiency at the admin-team level. <br></br>**Example Analytics Questions:**<ul><li>Which admins have the fastest response times and highest customer satisfaction scores by team?</li><li>How is conversation workload distributed across admins within each team?</li><li>Do specific admin-team combinations show better or worse performance metrics?</li></ul>|
| [intercom__article_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__article_enhanced.sql) | Provides insights into help center article performance with enriched data from collections, authors, and help centers to analyze content effectiveness and user engagement. <br></br>**Example Analytics Questions:**<ul><li>Which articles have the highest view counts and what are their user satisfaction reaction percentages?</li><li>How do article views and conversation generation vary by collection, author, or help center?</li><li>Which articles are generating the most user reactions and conversations?</li></ul>|
| [intercom__company_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__company_enhanced.sql) | Provides a complete view of each company with contact counts, conversation metrics, tag associations, and plan information to analyze customer engagement and account health. <br></br>**Example Analytics Questions:**<ul><li>Which companies have the most contacts and highest conversation volumes?</li><li>How do conversation metrics and response times vary by company plan or segment?</li><li>What tags are most commonly associated with high-value companies?</li></ul>|
| [intercom__company_metrics](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__company_metrics.sql) | Aggregates conversation metrics at the company level including total conversations, satisfaction ratings, and response times to understand company-level support needs and engagement patterns. <br></br>**Example Analytics Questions:**<ul><li>Which companies have the highest conversation volumes and what are their satisfaction scores?</li><li>How do response and resolution times vary across different companies or account tiers?</li><li>What companies show declining satisfaction ratings that may need proactive attention?</li></ul>|
| [intercom__contact_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__contact_enhanced.sql) | Consolidates contact profiles with company associations, conversation history, tag assignments, and engagement metrics to understand individual customer relationships and support needs. <br></br>**Example Analytics Questions:**<ul><li>Which contacts have the most conversations and longest average resolution times?</li><li>How do contact engagement patterns differ by company or role?</li><li>What tags are most frequently applied to contacts with high conversation volumes?</li></ul>|
| [intercom__conversation_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__conversation_enhanced.sql) | Tracks all customer conversations with participant details, response times, conversation state, and tag assignments to measure support efficiency and conversation resolution patterns. <br></br>**Example Analytics Questions:**<ul><li>What is the average response time and resolution time for conversations by team or assignee?</li><li>Which conversation tags are associated with longer resolution times?</li><li>How many conversations are currently open or waiting on customers versus closed?</li></ul>|
| [intercom__conversation_metrics](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__conversation_metrics.sql) | Aggregates conversation-level metrics including wait times, handling times, and assignment patterns to identify bottlenecks and measure overall support team performance. <br></br>**Example Analytics Questions:**<ul><li>What are the average first response time and total resolution time across all conversations?</li><li>How do conversation metrics vary by conversation source (chat, email, etc.) or priority?</li><li>Which time periods or days of the week have the longest wait times?</li></ul>|

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Intercom connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift** or **PostgreSQL** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/dbt).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_intercom/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.


<!--section-end-->

### Install the package
Include the following intercom package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/intercom
    version: [">=1.4.0", "<1.5.0"]
```
### Define database and schema variables

#### Option A: Single connection
By default, this package runs using your destination and the `intercom` schema. If this is not where your Intercom data is (for example, if your Intercom schema is named `intercom_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  intercom:
    intercom_database: your_database_name
    intercom_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Intercom connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `intercom_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  intercom:
    intercom_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Intercom connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Intercom source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `intercom`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Intercom sources, though the package will run successfully.

To properly incorporate all of your Intercom connections into your project's DAG:
1. Define each of your sources in a `.yml` file in your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_intercom.yml` [file](https://github.com/fivetran/dbt_intercom/blob/main/models/staging/src_intercom.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in intercom_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from intercom/models/staging/src_intercom.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Additional configurations](https://github.com/fivetran/dbt_intercom?tab=readme-ov-file#optional-step-4-additional-configurations)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `intercom` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  intercom:
    has_defined_sources: true
```
### (Optional) Additional configurations
<details open><summary>Expand/Collapse details</summary>

#### Adding passthrough metrics
You can add additional columns to the `intercom__article_enhanced`, `intercom__company_enhanced`, `intercom__contact_enhanced`, and `intercom__conversation_enhanced` tables using our pass-through column variables. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables in your root `dbt_project.yml`.

```yml
vars:
  intercom__company_history_pass_through_columns:
    - name: company_history_custom_field
      alias: new_name_for_this_field
      transform_sql:  "cast(new_name_for_this_field as int64)"
    - name:           "this_other_field"
      transform_sql:  "cast(this_other_field as string)"
    - name: custom_monthly_spend
    - name: custom_paid_subscriber
  # a similar pattern can be applied to the rest of the following variables.
  intercom__contact_history_pass_through_columns:
  intercom__conversation_history_pass_through_columns:
  intercom__article_history_pass_through_columns:
```
#### Disabling Models
This package assumes that you use Intercom's help center functionality (`article`, `collection_history`, `help_center_history`) and mapping tables (`company tag`, `contact tag`, `contact company`, `conversation tag`, `team`, `team admin`). If you do not use these tables, add the configuration below to your `dbt_project.yml`. By default, these variables are set to `True`:

```yml
# dbt_project.yml

...
vars:
  intercom__using_articles: False # This disables all help center functionality
  intercom__using_collection_history: False # Also requires articles to be enabled
  intercom__using_help_center_history: False # Also requires articles and collection_history to be enabled
  intercom__using_contact_company: False
  intercom__using_company_tags: False
  intercom__using_contact_tags: False
  intercom__using_conversation_tags: False
  intercom__using_team: False
```

#### Changing the build schema
By default this package will build the Intercom staging models within a schema titled (<target_schema> + `_stg_intercom`) and the Intercom final models with a schema titled (<target_schema> + `_intercom`) in your target database. If this is not where you would like your modeled Intercom data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
    intercom:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```
#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_intercom/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    intercom_<default_source_table_name>_identifier: your_table_name 
```

</details>

### Limitations
Intercom V2.0 does not support API exposure to company-defined business hours. We therefore calculate all `time_to` metrics in their entirety without subtracting business hours.

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]
```
<!--section="intercom_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/intercom/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_intercom/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).


<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_intercom/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
