<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_intercom/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>


# Intercom Transformation dbt Package ([Docs](https://fivetran.github.io/dbt_intercom/))
# 📣 What does this dbt package do?
- Produces modeled tables that leverage Intercom data from [Fivetran's connector](https://fivetran.com/docs/applications/intercom) in the format described by [this ERD](https://fivetran.com/docs/applications/intercom#schemainformation) and builds off the output of our [Intercom source package](https://github.com/fivetran/dbt_intercom_source).

- Enables you to better understand the performance, responsiveness, and effectiveness of your team's conversations with customers via Intercom. It achieves this by:
  - Creating an enhanced conversations table to enable large-scale reporting on all current and closed conversations
  - Enriching conversation data with relevant contacts data
  - Aggregating your team's performance data across all conversations
  - Providing aggregate rating and timeliness metrics for customer conversations to enable company-level conversation performance reporting

The following table provides a detailed list of all models materialized within this package by default. 

| **Model**                | **Description**                                                                                                                            |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [intercom__admin_metrics](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__admin_metrics.sql)                                               | Each record represents an individual admin (employee) and a unique team they are assigned on, enriched with admin-specific conversation data like total conversations, average rating, and median response times by specific team. |
| [intercom__company_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__company_enhanced.sql)                                         | Each record represents a single company, enriched with data related to the company industry, monthly spend, and user count. |
| [intercom__company_metrics](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__company_metrics.sql)                                           | Each record represents a single row from `intercom__company_enhanced`, enriched with data like total conversation count, average satisfaction rating, median time to first response, and median time to last close with contacts associated to a single company. |
| [intercom__contact_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__contact_enhanced.sql)                                         | Each record represents a single contact, enriched with data like the contact's role, company, last contacted information, and email list subscription status. |
| [intercom__conversation_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__conversation_enhanced.sql)                               | Each record represents a single conversation, enriched with conversation part data like who was assigned to the conversation, which contact the conversation was with, the current conversation state, who closed the conversation, and the final conversation ratings from the contact. |
| [intercom__conversation_metrics](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__conversation_metrics.sql)                                 | Each record represents a single row from `intercom__conversation_enhanced`, enriched with data like time to first response, time to first close, and time to last close. |

# 🎯 How do I use the dbt package?

## Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Intercom connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift** or **PostgreSQL** destination.

## Step 2: Install the package
Include the following intercom package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/intercom
    version: [">=0.6.0", "<0.7.0"]
```
## Step 3: Define database and schema variables
By default, this package runs using your destination and the `intercom` schema. If this is not where your Intercom data is (for example, if your Intercom schema is named `intercom_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    intercom_database: your_database_name
    intercom_schema: your_schema_name
```
## (Optional) Step 4: Additional configurations

<details><summary>Expand for configurations</summary>

### Adding passthrough metrics
If you'd like, you can also add additional columns to the `intercom__company_enhanced` and/or `intercom__contact_enhanced` tables. 
Any columns you pass must be present in the downstream source contact and/or company tables. See 
below for an example of how to configure the passthrough columns in your `dbt_project.yml` file.

```yml
# dbt_project.yml

...
vars:
  intercom__company_history_pass_through_columns: [company_custom_field_1, company_custom_field_2]
  intercom__contact_history_pass_through_columns: [contact_custom_column]
```
This package assumes that you use Intercom's `company tag`, `contact tag`, `contact company`, and `conversation tag`, `team` and `team admin` mapping tables. If you do not use these tables, add the configuration below to your `dbt_project.yml`. By default, these variables are set to `True`:

```yml
# dbt_project.yml

...
vars:
  intercom__using_contact_company: False
  intercom__using_company_tags: False
  intercom__using_contact_tags: False
  intercom__using_conversation_tags: False
  intercom__using_team: False
```

### Changing the build schema
By default this package will build the Intercom staging models within a schema titled (<target_schema> + `_stg_intercom`) and the Intercom final models with a schema titled (<target_schema> + `_intercom`) in your target database. If this is not where you would like your modeled Intercom data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
  intercom:
    +schema: my_new_schema_name # leave blank for just the target_schema
  intercom_source:
    +schema: my_new_schema_name # leave blank for just the target_schema
```
### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_intercom/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    intercom_<default_source_table_name>_identifier: your_table_name 
```

</details>

## Limitations
Intercom V2.0 does not support API exposure to company-defined business hours. We therefore calculate all `time_to` metrics in their entirety without subtracting business hours.

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/intercom_source
      version: [">=0.6.0", "<0.7.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: calogica/dbt_expectations
      version: [">=0.8.0", "<0.9.0"]
```
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/intercom/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_intercom/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_intercom/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [on Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com.
