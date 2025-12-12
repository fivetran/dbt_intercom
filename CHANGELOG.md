# dbt_intercom v1.4.0
[PR #74](https://github.com/fivetran/dbt_intercom/pull/74) includes the following updates:

## Schema/Data Change
**4 total changes • 0 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| `stg_intercom__article_history`<br>`stg_intercom__article_history_tmp` | New models | | | Staging models for the `article_history` source |
| `stg_intercom__collection_history`<br>`stg_intercom__collection_history_tmp` | New models | | | Staging models for the `collection_history` source |
| `stg_intercom__help_center_history`<br>`stg_intercom__help_center_history_tmp` | New models | | | Staging models for the `help_center_history` source |
| `intercom__article_enhanced` | New model | | | Help center articles enhanced with metadata including author details, collection hierarchy, and performance statistics |

## Feature Update
- Adds `intercom__article_history_pass_through_columns` variable to support custom fields in `intercom__article_enhanced` model
- Adds `intercom__using_articles` variable to enable/disable help center article models (defaults to `True`)
- Adds `intercom__using_collection_history` variable to enable/disable collection models (requires `intercom__using_articles` to be `True`)
- Adds `intercom__using_help_center_history` variable to enable/disable help center models (requires both `intercom__using_articles` and `intercom__using_collection_history` to be `True`)
  - See the [README](https://github.com/fivetran/dbt_intercom#optional-step-4-additional-configurations) for configuration details

## Under the Hood
- Adds column definition macros and integration test seed files for the new sources.
- Adds consistency test for `intercom__article_enhanced`.

## Contributors
- [@jhiza](https://github.com/jhiza) ([#73](https://github.com/fivetran/dbt_intercom/pull/73))

# dbt_intercom v1.3.0
[PR #71](https://github.com/fivetran/dbt_intercom/pull/71) includes the following updates:

## Feature
- Increases the required dbt version upper limit to v3.0.0.

# dbt_intercom v1.2.0
[PR #70](https://github.com/fivetran/dbt_intercom/pull/70) introduces the following updates:

## Schema/Data Changes
**3 total changes • 2 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| All models | New column | | `source_relation` | Identifies the source connection when using multiple Intercom connections |
| `stg_intercom__tag` | New data type | `name` categorized as timestamp | `name` categorized as string | Modifies name to its proper string format, [per the Intercom docs](https://developers.intercom.com/docs/references/rest-api/api.intercom.io/tags/tag). |
| `stg_intercom__team` </br> `stg_intercom__team_admin` | New data type | `team_id` categorized as integer | `team_id` categorized as string | Modifies team_id to its proper string format, [per the Intercom docs](https://developers.intercom.com/docs/references/rest-api/api.intercom.io/teams/team). |

## Feature Update
- **Union Data Functionality**: This release supports running the package on multiple Intercom source connections. See the [README](https://github.com/fivetran/dbt_intercom/tree/main?tab=readme-ov-file#step-3-define-database-and-schema-variables) for details on how to leverage this feature.

## Tests Update
- Removes uniqueness tests. The new unioning feature requires combination-of-column tests to consider the new `source_relation` column in addition to the existing primary key, but this is not supported across dbt versions.
- These tests will be reintroduced once a version-agnostic solution is available.

## Under the Hood
- New consistency tests introduced on all end models to validate that the above changes do not impact end model values. 

# dbt_intercom v1.1.0
[PR #69](https://github.com/fivetran/dbt_intercom/pull/69) includes the following updates:

## Bug Fixes
- **Performance optimization**: Refactored `int_intercom__conversation_part_events` for customers with large `intercom__conversation_part_history` source tables:
  - Consolidated redundant CTEs and eliminated unnecessary joins to reduce compute load and memory usage for larger source tables.
  - Implemented single window function pass instead of multiple subqueries. 
  - Replicate IGNORE NULLS logic with `first_value()` window functions using custom ordering (`case when condition then 0 else 1 end`) to prioritize relevant events and naturally skip null values.
- **Data accuracy fix**: Corrected the `last_close_by_author_id` window function logic that was incorrectly using ascending order instead of descending order, causing it to return the same value as `first_close_by_author_id`. The fix ensures proper chronological ordering to capture the actual last close event author.

## Under the Hood
- Created consistency and integrity tests for `intercom__conversation_enhanced` to validate that the above changes do not impact end model values. 

# dbt_intercom v1.1.0-a2
[PR #68](https://github.com/fivetran/dbt_intercom/pull/68) is a pre-release that includes the following updates:

## Bug Fixes
- Consolidated CTEs and joins to reduce the compute load of `int_intercom__conversation_part_events` for customers with large `intercom__conversation_part_history` source tables. 
- Corrected `last_close_by_author_id` logic that was incorrectly referencing` first_close_by_author_id` values.

## Under the Hood
- Created consistency test for `intercom__conversation_enhanced` to validate that the above changes do not impact end model values. 

# dbt_intercom v1.1.0-a1
[PR #67](https://github.com/fivetran/dbt_intercom/pull/67) is a pre-release that includes the following updates:

## Schema Updates (`--full-refresh` encouraged after upgrading)

| Data Model                                                                                                                                               | Change Type | Old Behavior                     | New Behavior                                             | Notes                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `int_intercom__conversation_part_events`             | Updated materialization  |  Ephemeral |   Table    |  Reduces compute load of `intercom__conversation_enhanced` to prevent timeout run issues.  |
| `int_intercom__conversation_string_aggregates`                                | Updated materialization | Ephemeral  |  Table   |    Reduces compute load of `intercom__conversation_enhanced` to prevent timeout run issues.  |
| `int_intercom__conversation_part_aggregates`                                | Updated materialization | Ephemeral  |  Table   |    Reduces compute load of `intercom__conversation_metrics` to prevent timeout run issues.  |

# dbt_intercom v1.0.0

[PR #66](https://github.com/fivetran/dbt_intercom/pull/66) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/intercom_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/intercom_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/intercom_source` package will also need to be removed or updated to reference this package.
  - Update any intercom_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_intercom/blob/main/README.md) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Removed all `accepted_values` tests.
  - Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_intercom.yml`.

## Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

# dbt_intercom v0.10.0

[PR #63](https://github.com/fivetran/dbt_intercom/pull/63) includes the following updates:

## Breaking Change for dbt Core < 1.9.6

> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([Intercom Source v0.9.0](https://github.com/fivetran/dbt_intercom_source/releases/tag/v0.9.0)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `intercom` in file
`models/src_intercom.yml`. The `freshness` top-level property should be moved
into the `config` of `intercom`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running Intercom freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `intercom` package. Pin your dependency on v0.9.2 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `intercom` source and apply freshness via the previous release top-level property route. This will require you to copy and paste the entirety of the previous release `src_intercom.yml` file and add an `overrides: intercom_source` property.

## Under the Hood
- Updates to ensure integration tests use latest version of dbt.

# dbt_intercom v0.9.2

## Documentation
- Added Quickstart model counts to README. ([#55](https://github.com/fivetran/dbt_intercom/pull/55))
- Corrected references to connectors and connections in the README. ([#55](https://github.com/fivetran/dbt_intercom/pull/55))

## Under the Hood
- Updated the `quickstart.yml` file to allow for automated Quickstart data model deployments. ([PR #51](https://github.com/fivetran/dbt_intercom/pull/51))
- Prepends `materialized` configs in the package's `dbt_project.yml` file with `+` to improve compatibility with the newer versions of dbt-core starting with v1.10.0. ([PR #57](https://github.com/fivetran/dbt_intercom/pull/57))
- Updates the package maintainer pull request template. ([PR #58](https://github.com/fivetran/dbt_intercom/pull/58))

## Contributors
- [@b-per](https://github.com/b-per) ([PR #57](https://github.com/fivetran/dbt_intercom/pull/57))

# dbt_intercom v0.9.1

[PR #50](https://github.com/fivetran/dbt_intercom/pull/50) includes the following updates:
## Bug Fixes
- Removed the reference and join to the `latest_conversation_contact` cte within the [intercom__conversation_enhanced](https://github.com/fivetran/dbt_intercom/blob/main/models/intercom__conversation_enhanced.sql) model as it was not being leveraged.

## Under the Hood
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Updated the maintainer PR template to resemble the most up to date format.

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
