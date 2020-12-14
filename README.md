# Intercom ([docs](https://dbt-intercom.netlify.app/))

This package models [Intercom] data from [Fivetran's connector](https://fivetran.com/docs/applications/intercom). It uses data in the format described by [this ERD](https://docs.google.com/presentation/d/1K3HTGqNQ-neUNeTtjJq42RHBV68_4FuXFp8X81zJ5Xo/edit#slide=id.p).

The main focus of this package is to enable users to better understand and recognize their responsiveness and effectiveness in relation to 
customer conversations via Intercom. You can easily gain insights from multiple conversations
with customers to determine and discover how your admins are performing, customer sentiment from conversations via the Intercom ranking functionality, 
and gain valuable information through leveraging the contact and company models with conversations.

## Compatibility
> Please be aware the [dbt_intercom](https://github.com/fivetran/dbt_intercom) and [dbt_intercom_source](https://github.com/fivetran/dbt_intercom_source) packages will only work with the [Fivetran Intercom connector](https://fivetran.com/docs/applications/intercom/changelog) which was released in July 2020, or any version thereafter. If your Intercom connector was set up prior to the July 2020 release, you will need to set up a new Intercom connector in order for the Fivetran dbt Intercom packages to work.

## Models
This package contains transformation models, designed to work simultaneously with our [Intercom source package](https://github.com/fivetran/dbt_intercom_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [intercom__admin_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__admin_metrics.sql)                                               | Each record represents an individual admin (employee), enriched with admin specific conversation aggregates. For example, the admin's total conversations, average rating, and median response times. **Please note**, currently Intercom V2.0 does not support API exposure to company defined business hours. As such, all time_to metrics are calculated in their entirety without subtracting out business hours. A feature ticket has been logged with Intercom to provide API exposure for business hours in a later release. |
| [intercom__company_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__company_enhanced.sql)                                         | Each record represents a single company, enriched with data related to the company industry, monthly_spend, and user_count. This model can be joined to intercom__contact_enhanced via the company_id for additional enrichment. Additionally, if you passed in a `False` value for the `using_contact_company` variable then this model will not be created. For more details around this variable, refer to the configuration section within the [Intercom source package](https://github.com/fivetran/dbt_intercom_source). |
| [intercom__company_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__company_metrics.sql)                                           | Each record represents a single row from intercom__company_enanced, enriched with aggregates which determine the total conversation count, average satisfaction rating, median time to first response, and median time to last close with contacts associated to a single company. **Please note**, currently Intercom V2.0 does not support API exposure to company defined business hours. As such, all time_to metrics are calculated in their entirety without subtracting out business hours. A feature ticket has been logged with Intercom to provide API exposure for business hours in a later release. Additionally, if you passed in a `False` value for the `using_contact_company` variable then this model will not be created. For more details around this variable, refer to the configuration section within the [Intercom source package](https://github.com/fivetran/dbt_intercom_source). |
| [intercom__contact_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__contact_enhanced.sql)                                         | Each record represents a single contact, enriched with data identifying the contacts role, if they have unsubscribed from the email list, last contacted information, and which company they belong to. This model can be joined to intercom__conversation_enhanced via the first_contact_author_id or last_contact_author_id. |
| [intercom__conversation_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__conversation_enhanced.sql)                               | Each record represents a single conversation, enriched with data from the multiple conversation parts. The conversation parts provide relevant information such as who was assigned to the conversation, which contact the conversation was with, the current conversation state, who closed the conversation, and the final conversation ratings from the contact. |
| [intercom__conversation_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__conversation_metrics.sql)                                 | Each record represents a single row from intercom__conversation_enhanced, enriched with aggregates which determine time to first response, time to first close, and time to last close. **Please note**, currently Intercom V2.0 does not support API exposure to company defined business hours. As such, all time_to metrics are calculated in their entirety without subtracting out business hours. A feature ticket has been logged with Intercom to provide API exposure for business hours in a later release. |

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

## Configuration
By default, this package looks for your Intercom data in the `intercom` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). 
If this is not where your Intercom data is, add the below configuration to your `dbt_project.yml` file. Additionally, as this package only works with the [Fivetran Intercom connector](https://fivetran.com/docs/applications/intercom/changelog) which was released in July 2020, or any version thereafter. If your Intercom connector was set up prior to the July 2020 release, you will need to set up a new Intercom connector in order for the Fivetran dbt Intercom packages to work.

```yml
# dbt_project.yml

...
config-version: 2

vars:
    connector_database: your_database_name
    connector_schema: your_schema_name
```

This package allows users to add additional columns to the intercom__company_enhanced and/or intercom__contact_enhanced tables. 
Columns passed through must be present in the downstream source contact and/or company tables. See 
below for an example of how the passthrough columns should be configured within your `dbt_project.yml` file.

```yml
# dbt_project.yml

...
vars:
  intercom:
    company_pass_through_columns: [company_custom_field_1, company_custom_field_2]
    contact_pass_through_columns: [contact_custom_column]
  intercom_source:
    company_history_pass_through_columns: [company_custom_field_1, company_custom_field_2]
    contact_history_pass_through_columns: [contact_custom_column]
```

For additional configurations for the source models, such as the company and tag variables, visit the [Intercom source package](https://github.com/fivetran/dbt_intercom_source).

## Contributions and Future Considerations
Don't see a model or specific metric you would have liked to be included? Notice any bugs when installing 
and running the package? If so, we highly encourage and welcome contributions to this package! 
Please create issues or open PRs against `master`. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Database support
This package has been tested on BigQuery, Snowflake and Redshift.
Coming soon -- compatibility with Spark

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
