# Answer Key 1: Create Model

Strong answers should:

1. Use `ref('fct_orders')`
2. Join to `dim_customers` (or equivalent source for country)
3. Filter successful orders via `is_successful_order`
4. Define clear grain: `order_date, country`
5. Add `not_null` tests for grain columns

Common mistakes:

- Missing country source
- Incorrect grain from mixed aggregations
- No schema/test updates
