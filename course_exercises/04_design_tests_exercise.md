# Exercise 4: Design Tests Prompt

## Objective

Practice identifying what could go wrong in a dbt model and asking AI to help protect against it.

## Your Starting Point

Look at `stg_subscriptions` and its `status` column. Think about what depends on that column being correct downstream. That is your problem area.

From there, figure out what question you want AI to help you answer about protecting that data — and write a prompt that reflects your own understanding of the risk, not a generic request for more tests.

## Submission Checklist

1. New tests use dbt syntax already used in this project
2. At least one schema test and one singular test are added for the chosen risk
3. `dbt test` passes for the new coverage, or failures are explained clearly