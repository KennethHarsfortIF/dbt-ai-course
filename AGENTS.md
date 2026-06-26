# AGENTS.md

## dbt model conventions

- For dbt models in this repository, keep source CTEs in the form `select * from source`.
- Put ranking, deduplication, and other derived logic in later CTEs.
- When using window functions for deduplication, use a deterministic tiebreaker so row selection is stable across runs.
- Preserve this pattern unless a task explicitly asks for source-column projection in the source CTE.

## Documentation conventions

- Use `docs/business_glossary.md` as the source of truth for metric and status definitions.
- Use `docs/mart_model_contracts.md` for mart grain, key columns, join rules, and edge-case behavior.
- If a model or review changes business logic, update the relevant doc in the same change.
