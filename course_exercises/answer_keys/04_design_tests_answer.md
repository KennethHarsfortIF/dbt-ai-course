# Answer Key 4: Design Tests

Strong answers should:

1. Pick one clear model and one clear risk instead of trying to review the whole project
2. Target a concrete risk area such as invalid status values, missing relationships, duplicate business keys, or non-negative monetary fields
3. Add `schema.yml` tests that match the current dbt syntax used in this repo
4. Include one singular SQL test in `tests/` with a clear failure condition tied to the chosen risk
5. Explain the business impact of each test that is added

Good beginner-friendly choices:

- `stg_subscriptions`: protect the `status` domain and key integrity
- `fct_orders`: protect revenue logic or payment-grain assumptions
- `rpt_saas_mrr`: protect reporting dimensions such as `region` and `status`

Common mistakes:

- Trying to cover too many models or risks in one prompt
- Giving generic advice without actual YAML or SQL
- Recommending packages or macros that are not installed
- Adding tests that do not match the chosen model risk