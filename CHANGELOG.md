# dbt_intercom v0.9.0

[PR #47](https://github.com/fivetran/dbt_intercom/pull/47) includes the following updates:
## 🚨 Breaking Changes 🚨
- In [July 2023 the Intercom API upgraded from 2.9 to 2.10](https://fivetran.com/docs/applications/intercom/changelog#july2023) which resulted in the connector schema receiving updates. These updates have downstream impacts on the data models within this package. The following changes are a result of the Intercom API and connector upgrades:
  - Breaking changes within the dbt_intercom_source package. Please refer to the relevant [Intercom Source release notes](https://github.com/fivetran/dbt_intercom_source/releases/tag/v0.8.0) for more details around the source package breaking changes.
  - Removal of the `_fivetran_deleted` field within the following end models:
    - `intercom__company_enhanced`
    - `intercom__company_metrics`
    - `intercom__contact_enhanced`
  - Removal of the following intermediate models as filtering on the new `_fivetran_active` field achieves the same result:
    - `int_intercom__latest_contact`
    - `int_intercom__latest_conversation`
    - `int_intercom__latest_conversation_contact`
    - `int_intercom__latest_conversation_part`

## Feature Updates
- The `_fivetran_active`, `_fivetran_start`, and `_fivetran_end` fields have been added to all `*_history` staging models as well as the following end models to replace the deprecated `_fivetran_deleted` field:
  - `intercom__company_enhanced`
  - `intercom__company_metrics`
  - `intercom__contact_enhanced`

## Dependency Updates
- Removal of the dbt_expectations dependency. These removal was applied in the upstream dbt_intercom_source [PR #36](https://github.com/fivetran/dbt_intercom_source/pull/36)

# dbt_intercom v0.8.0
## 🎉 Feature Update 🎉
- Databricks compatibility! ([#44](https://github.com/fivetran/dbt_intercom/pull/44))

# dbt_intercom v0.7.0
## 🚨 Breaking Changes 🚨:
As discussed within [Issue #40](https://github.com/fivetran/dbt_intercom/issues/40) it became apparent that the `first_close_*` and `last_close_*` metrics in the `intercom__conversation_enhanced` and `intercom__conversation_metrics` models was not entirely accurate if an Intercom user is leveraging bots to help auto  close conversations. As such, the following changed/new fields have been applied in this release. ([#41](https://github.com/fivetran/dbt_intercom/pull/41/))

> **Note**: If you are leveraging any of the following metrics I highly encourage understanding the new description in case you need to adjust any downstream references or visualizations.

| model | field_name | previous_description | new_description |
|-------|------------|-----------------|-----------------|
|intercom__conversation_enhanced / intercom__conversation_metrics | first_close_at | The time of the first conversation part where part_type was 'close' indicating the conversation was closed. | The time of the first conversation part where part_type was 'close' by any author indicating the conversation was closed. |
|intercom__conversation_enhanced / intercom__conversation_metrics | last_close_at | The time of the last conversation part where part_type was 'close' indicating the conversation was closed. | The time of the last conversation part where part_type was 'close' by any author indicating the conversation was closed. |
|intercom__conversation_enhanced / intercom__conversation_metrics | first_admin_close_at | N/A this is a new field, but was the previous first_close_at value | The time of the first conversation part where part_type was 'close' by an admin indicating the conversation was closed. |
|intercom__conversation_enhanced / intercom__conversation_metrics | last_admin_close_at | N/A this is a new field, but was the previous last_close_at value | The time of the last conversation part where part_type was 'close' by an admin indicating the conversation was closed. |
|intercom__conversation_enhanced / intercom__conversation_metrics | first_close_by_author_id | N/A this is a new field | The author_id of the author (admin, bot, user, etc.) who was first closed to the conversation. |
|intercom__conversation_enhanced / intercom__conversation_metrics | last_close_by_author_id | N/A this is a new field | The author_id of the author (admin, bot, user, etc.) who was last closed to the conversation. |
| intercom__conversation_metrics | time_to_last_close_minutes | Previously leveraged last_close_at which only took into account admin close parts. | The time difference (not factoring in business hours) between the last_close_at and the first_contact_reply. |
| intercom__conversation_metrics | time_to_first_close_minutes | Previously leveraged first_close_at which only took into account admin close parts. | The time difference (not factoring in business hours) between the first_contact_reply_at and the first_close_at. |
| intercom__conversation_metrics | time_to_admin_first_close_minutes | N/A this is a new field. | The time difference (not factoring in business hours) between the first_contact_reply_at and the first_admin_close_at.|
| intercom__conversation_metrics | time_to_admin_last_close_minutes | N/A this is a new field. | The time difference (not factoring in business hours) between the first_contact_reply and the last_admin_close_at.| 

## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#42](https://github.com/fivetran/dbt_intercom/pull/42))
- Updated the pull request [templates](/.github). ([#42](https://github.com/fivetran/dbt_intercom/pull/42))

# dbt_intercom v0.6.1

## 🐛 Bug Fixes 🐛
- Adjusted the `first_admin_response_at` and `last_admin_response_at` logic within `int_intercom__conversation_part_aggregates` to take into account that admin replies may sometimes exist within assignment parts. This is differentiated from normal assignments by also checking to determine if the body of the part is populated. If it is, then it is safe to assume this is a true admin reply and should be counted as such. ([#38](https://github.com/fivetran/dbt_intercom/pull/38))

## ⭐ Features ⭐
- Passthrough columns variables can now be configured with an alias and a transform. Refer to [Passthrough Columns](https://github.com/fivetran/dbt_intercom_source#passthrough-columns) of the README for more information. ([#37](https://github.com/fivetran/dbt_intercom/pull/37))
- Custom columns from source table `conversation_history` can now be persisted through to downstream models `intercom__conversation_enhanced` and `intercom__conversation_metrics`. ([#37](https://github.com/fivetran/dbt_intercom/pull/37))


# dbt_intercom v0.6.0

## 🚨 Breaking Changes 🚨:
[PR #29](https://github.com/fivetran/dbt_intercom/pull/29) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_intercom v0.5.0
## 🚨 Breaking Changes 🚨
- In this PR ([#18](https://github.com/fivetran/dbt_intercom/pull/18)), we've added:
- Added dbt_expectations packages to the intercom source package to more easily setup more complex data validation tests.
- Added not null tests to the intercom source package for both author and assigned_to fields, conditional on author_type and assigned_to_type not being null.
## Features 
- 🎉 Postgres Compatibility 🎉 ([#25](https://github.com/fivetran/dbt_intercom/pull/25))
## Under the Hood
- We have added the below feature enhancements to this package in this PR ([#25](https://github.com/fivetran/dbt_intercom/pull/25)): 
- Added `{{ dbt_utils.type_timestamp() }}` casting to timestamp fields for safe casting across warehouses.
- Added varcar casts in `integration_tests/dbt_project.yml` for postgres db since string doesn't exist in postgres.
- Added numeric casts for `intercom__admin_metrics` and `intercom__company_metrics` and group bys to provide postgres compatibility.
- Removed extraneous `ignore nulls` logic in `int_intercom__conversation_part_events`, utilizing new tests in `intercom_source` package to capture data quality issues. 
- Created new `int_intercom__latest_conversation_part` model to segment out potential duplicate rows, refactored `int_intercom__conversation_part_aggregates` as a result.
## Contributors 
- [@matiasjofre](https://github.com/matiasjofre) ([#25](https://github.com/fivetran/dbt_intercom/pull/25))
# dbt_intercom v0.4.1

## Bug Fixes
- Adjusts the uniqueness tests on `intercom__admin_metrics` to run on a combination of `admin_id` and `team_id` if `intercom__using_team` is enabled. If `intercom__using_team` is disabled, `admin_id` is the sole column forming the model's primary key (https://github.com/fivetran/dbt_intercom/issues/21).
- Adds `team_id` to the `intercom__admin_metrics` model. Originally, this model only contained `team_name`. 

# dbt_intercom v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_intercom_source`. Additionally, the latest `dbt_intercom_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_intercom v0.1.0 -> v0.3.1
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
