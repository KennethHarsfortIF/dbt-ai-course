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

```powershell
cd "dbt-ai-course"
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

## Suggested Teaching Flow

1. Start with `dbt seed`, `dbt run`, `dbt test`
2. Ask AI to create a new model in `models/marts/`
3. Ask AI to explain an existing model and test coverage
4. Ask AI to propose improvements, then implement and re-test

## AI Prompt Pack

Use the templates in:

- `ai_prompts/01_create_model.md`
- `ai_prompts/02_explain_code.md`
- `ai_prompts/03_suggest_improvements.md`
- `ai_prompts/context_pack.md`

## Classroom Exercises

Use these ready-made exercises and answer keys:

- `course_exercises/01_create_model_exercise.md`
- `course_exercises/02_explain_code_exercise.md`
- `course_exercises/03_improve_model_exercise.md`
- `course_exercises/answer_keys/01_create_model_answer.md`
- `course_exercises/answer_keys/02_explain_code_answer.md`
- `course_exercises/answer_keys/03_improve_model_answer.md`

## Domain 2: SaaS Subscriptions

Additional seeds and models are included so learners can reuse prompting skills across domains.

Seeds:

- `raw_accounts`
- `raw_plans`
- `raw_subscriptions`

Marts:

- `rpt_saas_mrr`

## Environment Note

If your class runs on Python 3.14, keep the `mashumaro==3.17` pin in `requirements.txt`.

## Notes

- This project intentionally uses clear naming and small models for teaching.
- The `models/playground/` folder is where students can create new models from prompts.