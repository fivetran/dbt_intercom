# [Intercom] (Waiting until package approved to create docs) 

This package models [Intercom] data from [Fivetran's connector](https://fivetran.com/docs/applications/intercom). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/intercom#schemainformation).

The main focus of this package is to enable users to better understand and recognize their responsiveness as well as effectiveness to 
customer conversations via Intercom. You can easily gain insights from multiple conversations
with customers to determine how your admins are performing, determine customer sentiment from conversations via the Intercom ranking functionality, 
and discover valuable information through the customer and company enhanced models to determine which users or leads are conversing with your admins 
and what companies they belond to.
...
## Compatibility
> Please be aware the [dbt_intercom](https://github.com/fivetran/dbt_intercom) package will only work with Intercom V2.0 or greater. 

## Models

This package contains transformation models, designed to work simultaneously with our [Intercom source package](https://github.com/fivetran/dbt_intercom_source). A depenedency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [intercom__admin_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__admin_metrics.sql)                    | Each record represents an individual admin, enriched with data about their total conversations, average rating, and   median response times. |
| [intercom__companies_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__companies_enhanced.sql)          | Each record represents a single company, enriched with data related to the company industry, monthly_spend, and user_count. |
| [intercom__contacts_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__contacts_enhanced.sql)            | Each record represents a single contact, enriched with data identifying the contacts role, if they are unsubscribed from the email list, last contacted information, and which company they belong to. |
| [intercom__conversations_enhanced](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__conversations_enhanced.sql)  | Each record represents a single conversation, enriched with data from the multiple conversation parts that make up the conversation. The conversation parts provide relevant information regarding who was assigned the conversation, who the conversation was with, the current conversation state, who closed the conversation, and the final conversation ratings from the customer. |
| [intercom__conversations_metrics](https://github.com/fivetran/dbt_intercom/blob/master/models/intercom__conversations_metrics.sql)    | Each record represents a single row from intercom__conversations_enhanced, enriched with aggregates which determine time to first response, time to first close, and time to last close. Please note, currently Intercom V2.0 does not support API exposure to company defined business hours. As such, all time_to metrics are calculated in their entirety without business hours being subtracted out. A feature ticket has been logged with Intercom to provide API exposure for business hours in a later release. |

## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

## Configuration
By default, this package looks for your Intercom data in the `intercom` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). 
If this is not where your Intercom data is, add the below configuration to your `dbt_project.yml` file. Additionally, as this package only works with Intercom V2.0 it is important to know your Fivetran Intercom 
connector must be on the most recent version. [If you are unsure what version of the connector your are on, feel free to reach out to your customer success manager for more information]

```yml
# dbt_project.yml

...
config-version: 2

vars:
    connector_database: your_database_name
    connector_schema: your_schema_name s
```

This package allows users to add additional columns to the companies and/or contacts enhanced tables. 
Columns passed through must be present in the downstream source contact table and/or company table. See 
below for an example of how the passthrough columns should be configured within your `dbt_project.yml` file.

```yml
# dbt_project.yml

...
vars:
  intercom:
    companies_enhanced_pass_through_columns: [company_custom_field_1, company_custom_field_2]
    contacts_enhanced_pass_through_columns: [contact_custom_column]
  intercom_source:
    company_history_pass_through_columns: [company_custom_field_1, company_custom_field_2]
    contact_history_pass_through_columns: [contact_custom_column]
```

For additional configurations for the source models, visit the [Intercom source package](https://github.com/fivetran/dbt_intercom_source).

## Contributions and Future Considerations
Don't see a model or specific metric you would have liked to be included? Notice any bugs when installing 
and running the package? If so, we highly encourange and welcome contributions to this package are very welcome! 
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
