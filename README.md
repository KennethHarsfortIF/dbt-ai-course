# dbt AI Course Example Project

This repository is a self-contained dbt example that is designed for AI-assisted learning.

It supports these prompt-driven workflows:

1. Create `xxx` model
2. Document `xxx` code / explain what `xxx` does
3. Suggest improvements for `xxx`

## Why this project works well for AI courses

- Uses `dbt-duckdb` for local, lightweight setup (no external warehouse needed)
- Includes realistic seed data and layered models (`staging`, `intermediate`, `marts`)
- Includes tests and docs so AI can reason about quality and lineage
- Includes reusable prompt templates in `ai_prompts/`
- Includes two business domains (ecommerce + SaaS subscriptions) for transfer learning

## Project Structure

```text
dbt-ai-course/
  ai_prompts/
  analyses/
  macros/
  models/
    staging/
    intermediate/
    marts/
  seeds/
  tests/
  dbt_project.yml
  profiles.yml
```

## Quick Start (PowerShell)

For a dedicated setup walkthrough, see [getting started.md](getting%20started.md).

```powershell
# If you are in the folder that contains this checkout:
cd "dbt-ai-course"

# If you are already inside dbt-ai-course, skip the cd line above.

python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Optional: choose where DuckDB file is stored
$env:DBT_DUCKDB_PATH = "ai_course.duckdb"

dbt debug --profiles-dir .
dbt seed --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
dbt docs generate --profiles-dir .
```

If you are already inside the project folder, use the project-local environment directly:

```powershell
.\.venv\Scripts\Activate.ps1
dbt seed --profiles-dir .
```

Do not use any other `.venv` for this project. Use the `.venv` created inside the `dbt-ai-course` folder.

## Query DuckDB in CLI

After installing requirements and activating the project `.venv`, you can query the local DuckDB file directly:

```powershell
duckdb "ai_course.duckdb"
```

Inside the DuckDB prompt:

```sql
SHOW TABLES;
SELECT * FROM main.dim_customers LIMIT 5;
.quit
```

Example join query (orders with customer attributes):

```sql
SELECT
  o.order_id,
  o.order_date,
  o.order_amount,
  c.email,
  c.value_tier
FROM main.fct_orders o
LEFT JOIN main.dim_customers c
  ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC
LIMIT 10;
```

## Suggested Teaching Flow

1. Start with `dbt seed`, `dbt run`, `dbt test`
2. Ask AI to create a new model in `models/marts/`
3. Ask AI to explain an existing model and test coverage
4. Ask AI to propose improvements, then implement and re-test

## Documentation Notes

Useful model-level documentation for the order fact model is available in:

- [docs/fct_orders.md](docs/fct_orders.md)
- [docs/fct_orders_model_notes.md](docs/fct_orders_model_notes.md)

## AI Prompt Pack

Use the templates in:

- `ai_prompts/01_create_model.md`
- `ai_prompts/02_explain_code.md`
- `ai_prompts/03_suggest_improvements.md`
- `ai_prompts/04_extract_data.md`
- `ai_prompts/05_documentation.md`
- `ai_prompts/context_pack.md`

## Classroom Exercises

Use these ready-made exercises and answer keys:

- `course_exercises/01_create_model_exercise.md`
- `course_exercises/02_explain_code_exercise.md`
- `course_exercises/03_improve_model_exercise.md`
- `course_exercises/04_extract_data_exercise.md`
- `course_exercises/05_documentation_exercise.md`
- `course_exercises/answer_keys/01_create_model_answer.md`
- `course_exercises/answer_keys/02_explain_code_answer.md`
- `course_exercises/answer_keys/03_improve_model_answer.md`
- `course_exercises/answer_keys/04_extract_data_answer.md`
- `course_exercises/answer_keys/05_documentation_answer.md`

Exercises 4 and 5 are designed as learner-authored prompting tasks so participants must write the AI prompt themselves from the exercise brief.

## Domain 2: SaaS Subscriptions

Additional seeds and models are included so learners can reuse prompting skills across domains.

Seeds:

- `raw_accounts`
- `raw_plans`
- `raw_subscriptions`

Marts:

- `rpt_saas_mrr`

## Environment Note

The verified setup for this project is the project-local `.venv` inside the `dbt-ai-course` folder.

## Notes

- This project intentionally uses clear naming and small models for teaching.
- The `models/playground/` folder is where students can create new models from prompts.