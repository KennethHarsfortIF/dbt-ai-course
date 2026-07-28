# Prompt 5: Ask AI to Write Documentation

These are facilitator examples and reference prompts.
Learners should write their own prompt using the exercise brief, not copy these by default.

## Example Prompt A: Model Documentation Prompt

```text
You are helping a teammate understand a dbt model in this project.

Choose one model such as dim_customers, fct_orders, or rpt_saas_mrr.

Task:
1) Explain what the model is for in plain English.
2) Describe the most important columns and business meaning.
3) Point out any assumptions, limitations, or caveats.
4) Write documentation that could be reused in a README, schema description, or model notes.

Important:
- Keep the scope narrow: one model, one audience, one documentation goal.
- Do not assume the reader already knows the data model.
- Be clear and practical.

Return exactly:
1) A short overview of the model
2) A bullet list of key columns or logic
3) A short section on assumptions or caveats
4) A short explanation of why this documentation would help someone else
```

## Expected High-Quality Answer Example (Prompt A)

```text
Overview:
- The model summarizes customer-level information for reporting and analysis.

Key columns or logic:
- Customer_id is the main grain.
- Revenue and activity measures are aggregated for reporting use.

Assumptions or caveats:
- The model depends on upstream data being complete and correctly mapped.

Why it helps:
- A new teammate can quickly understand the purpose of the model without reading the SQL.
```

## Common Bad Answer Example (Prompt A)

```text
- Gives a generic description that could apply to any model.
- Writes a summary without explaining the purpose or key fields.
- Omits assumptions, limitations, or caveats.
- Does not make the documentation useful for another person.
```
