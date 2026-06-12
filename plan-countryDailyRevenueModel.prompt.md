## Plan: Country Daily Revenue Model

Add a new playground reporting model at `models/playground/rpt_country_daily_revenue.sql` that aggregates `fct_orders` by `order_date` and `country`, joining to `dim_customers` on `customer_id`. Reuse the existing `safe_divide` macro for `avg_successful_order_value`, and create a new playground `schema.yml` entry with the required description and `not_null` tests.

**Steps**
1. Create `c:\Users\HARKEA\AI course\dbt-ai-course\models\playground\rpt_country_daily_revenue.sql` using `{{ ref('fct_orders') }}` and `{{ ref('dim_customers') }}` as the only model dependencies.
2. In the SQL, select from `fct_orders` as the base relation because it already defines `order_date`, `customer_id`, `order_amount`, and `is_successful_order`. Join `dim_customers` on `customer_id`. This step blocks step 3 because the aggregation expressions depend on the chosen aliases.
3. Aggregate to one row per `order_date` and `country`, with:
   - `successful_orders` as a conditional count where `is_successful_order` is true
   - `successful_revenue` as a conditional sum of `order_amount` where `is_successful_order` is true, otherwise 0
   - `avg_successful_order_value` using `{{ safe_divide(<successful_revenue expression>, <successful_orders expression>) }}` or equivalent inline aggregate expressions passed into the macro as strings
4. Create `c:\Users\HARKEA\AI course\dbt-ai-course\models\playground\schema.yml` if it does not already exist, using `version: 2` and a `models:` block consistent with the existing marts/intermediate schema files. This can run in parallel with step 3 once the final model name and column list are fixed.
5. Add a model entry for `rpt_country_daily_revenue` with a short business-oriented description and column-level tests:
   - `order_date`: `not_null`
   - `country`: `not_null`
   - `successful_revenue`: `not_null`
6. Verify the implementation with a focused dbt validation flow:
   - `dbt parse` to validate refs/Jinja/schema structure
   - `dbt build --select rpt_country_daily_revenue` or `dbt run --select rpt_country_daily_revenue` plus tests for the new model, depending on local setup
   - Inspect the built output to confirm grain is one row per `order_date` and `country`

**Relevant files**
- `c:\Users\HARKEA\AI course\dbt-ai-course\models\marts\fct_orders.sql` — source of `order_date`, `customer_id`, `order_amount`, and `is_successful_order`; reuse its order-level grain rather than recomputing success logic
- `c:\Users\HARKEA\AI course\dbt-ai-course\models\marts\dim_customers.sql` — source of `country` and the `customer_id` join key
- `c:\Users\HARKEA\AI course\dbt-ai-course\macros\safe_divide.sql` — existing safe divide implementation to reuse for average order value
- `c:\Users\HARKEA\AI course\dbt-ai-course\models\marts\rpt_customer_ltv.sql` — example of calling `safe_divide` in a model
- `c:\Users\HARKEA\AI course\dbt-ai-course\models\marts\schema.yml` — schema/test formatting reference for the new playground schema entry
- `c:\Users\HARKEA\AI course\dbt-ai-course\models\playground\example_generated_model.sql` — nearby playground example for aggregate SQL style
- `c:\Users\HARKEA\AI course\dbt-ai-course\models\playground\README.md` — confirms playground is the correct layer for this generated model

**Verification**
1. Run `dbt parse` from `c:\Users\HARKEA\AI course\dbt-ai-course` to catch Jinja/ref/schema errors.
2. Run `dbt build --select rpt_country_daily_revenue` to materialize the model and execute the new tests.
3. Query the built model and verify there are no duplicate `(order_date, country)` rows and that rows with zero successful orders produce `avg_successful_order_value = 0` via the macro behavior.
4. Spot-check that `successful_revenue` excludes unsuccessful orders and remains non-null for all output rows.

**Decisions**
- Use `fct_orders` as the base table because it already centralizes the success definition; do not duplicate that case expression in the new model.
- Use `dim_customers.country` as the country attribute, assuming the current dimension value is the intended reporting dimension.
- Keep the scope limited to the requested model and schema documentation/tests; no marts-layer migration or extra tests are included.

**Further Considerations**
1. If historical country changes matter, a slowly changing customer dimension would be needed; this plan assumes current `dim_customers.country` is acceptable.
2. If the team prefers all playground models documented in a shared schema file, append to that file rather than creating multiple schema files in the folder.