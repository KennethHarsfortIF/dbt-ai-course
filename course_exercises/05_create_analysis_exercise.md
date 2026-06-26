# Exercise 5: Create Analysis Prompt

## Objective

Use AI to create a stakeholder-facing analysis query.

## Task

Ask AI to create a new file in `analyses/` that answers one business question using existing dbt models.

Possible directions:

- Which customer segments drive the most completed revenue by country?
- Which SaaS regions have the highest active MRR and subscription counts?
- Which customers or accounts look like outliers worth investigating?

Your prompt should require:

1. A clear business question
2. The exact output grain
3. The models to use with `ref()`
4. Sorting or filtering that makes the result useful
5. A short interpretation or assumptions section

## Submission Checklist

1. Query runs as a dbt analysis
2. Grain and business question are explicit
3. Output is easy to explain to a stakeholder