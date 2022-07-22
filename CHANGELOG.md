# dbt_intercom v0.4.2
## Features 
- 🎉 Postgres Compatibility 🎉 ([#25](https://github.com/fivetran/dbt_intercom/pull/25))
## Under the Hood
- We have added the below feature enhancements to this package in this PR ([#25](https://github.com/fivetran/dbt_intercom/pull/25)): 
- Added `{{ dbt_utils.type_timestamp() }}` casting to timestamp fields for safe casting across warehouses.
- Added varcar casts in `integration_tests/dbt_project.yml` for postgres db since string doesn't exist in postgres.
- Added numeric casts for `intercom__admin_metrics` and `intercom__company_metrics` and group bys to provide postgres compatibility.
- Removed extraneous `ignore nulls` logic in `int_intercom__conversation_part_events`, utilizing new tests in `intercom_source` package to capture data quality issues. 
- Created new `int_intercom__latest_conversation_part` model to segment out potential duplicate rows, refactored `int_intercom__conversation_part_aggregates` as a result.

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
