[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 
# Intercom ([docs](https://dbt-intercom.netlify.app/))
> NOTE: Our Intercom [model](https://github.com/fivetran/dbt_intercom) and [source](https://github.com/fivetran/dbt_intercom_source) dbt packages only work with connectors that were [created in July 2020](https://fivetran.com/docs/applications/intercom/changelog) or later. If you created your connector before July 2020, you must set up a new Intercom connector to use these dbt packages.

This package models Intercom data from [Fivetran's connector](https://fivetran.com/docs/applications/intercom). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/intercom#schemainformation).

This packages enables you to better understand the performance, responsiveness, and effectiveness of your team's conversations with customers via Intercom. It achieves this by:
- Creating an enhanced conversations table to enable large-scale reporting on all current and closed conversations
- Enriching conversation data with relevant contacts data
- Aggregating your team's performance data across all conversations
- Providing aggregate rating and timeliness metrics for customer conversations to enable company-level conversation performance reporting

## Models
This package contains transformation models, designed to work simultaneously with our [Intercom source package](https://github.com/fivetran/dbt_intercom_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [intercom__admin_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__admin_metrics.sql)                                               | Each record represents an individual admin (employee) and a unique team they are assigned on, enriched with admin-specific conversation data like total conversations, average rating, and median response times. |
| [intercom__company_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__company_enhanced.sql)                                         | Each record represents a single company, enriched with data related to the company industry, monthly spend, and user count. |
| [intercom__company_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__company_metrics.sql)                                           | Each record represents a single row from `intercom__company_enhanced`, enriched with data like total conversation count, average satisfaction rating, median time to first response, and median time to last close with contacts associated to a single company. |
| [intercom__contact_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__contact_enhanced.sql)                                         | Each record represents a single contact, enriched with data like the contact's role, company, last contacted information, and email list subscription status. |
| [intercom__conversation_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__conversation_enhanced.sql)                               | Each record represents a single conversation, enriched with conversation part data like who was assigned to the conversation, which contact the conversation was with, the current conversation state, who closed the conversation, and the final conversation ratings from the contact. |
| [intercom__conversation_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__conversation_metrics.sql)                                 | Each record represents a single row from `intercom__conversation_enhanced`, enriched with data like time to first response, time to first close, and time to last close. |

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

Include in your `packages.yml`

```yaml
packages:
  - package: fivetran/intercom
    version: [">=0.4.0", "<0.5.0"]
```

## Configuration
By default, this package looks for your Intercom data in the `intercom` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). 
If this is not where your Intercom data is, add the configuration below to your `dbt_project.yml` file.

```yml
# dbt_project.yml

...
config-version: 2

vars:
    intercom_database: your_database_name
    intercom_schema: your_schema_name
```

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

### Changing the Build Schema
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

## Limitations
Intercom V2.0 does not support API exposure to company-defined business hours. We therefore calculate all `time_to` metrics in their entirety without subtracting business hours.

## Database support
This package has been tested on BigQuery, Snowflake, and Redshift.

## Contributions
Additional contributions to this package are very welcome! Please create issues or open PRs against `main`. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Have questions, feedback, or need help? Book a time during our office hours [here](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn how to orchestrate dbt transformations with Fivetran [here](https://fivetran.com/docs/transformations/dbt)
- Learn more about Fivetran overall [in our docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
