# Exercise 1: Create Model Prompt

## Objective

Use AI to create a new dbt model.

## Task

Ask AI to create `models/playground/rpt_country_order_performance.sql` using `fct_orders`.

Requirements:

- Grain: one row per `order_date` and `country`
- Metrics: successful orders, successful revenue, average successful order value
- Add docs/tests in a schema file update

## Submission Checklist

1. SQL compiles and runs in dbt
2. Model has clear grain
3. Tests pass
