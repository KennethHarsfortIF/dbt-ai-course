# Conversation Log - 2026-06-23

## User
I get a warning on the line `description: "{{ doc('fct_orders') }}"`.

## User
I get this warning:

`[InvalidConfig (dbt1005)]: doc macro reference 'fct_orders' not found for package 'ai_course_dbt'`

## Assistant
I investigated the warning by checking:
- `models/marts/schema.yml`
- `docs/fct_orders.md`
- `dbt_project.yml`

I found the docs block existed, but dbt was not discovering docs from the docs folder.

I updated `dbt_project.yml` to include:

```yaml
docs-paths: ["docs"]
```

Then I re-ran `dbt parse` and confirmed the `doc('fct_orders')` warning was resolved.

## Assistant
I also reported that separate parse errors remain for deprecated generic test argument format (`dbt1159`), which are unrelated to the docs warning.

## User
save this conversation in ai_prompts in a md format

## Assistant
Saved this conversation in markdown format under `ai_prompts/conversation_2026-06-23.md`.
