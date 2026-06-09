# Answer Key 2: Explain Code

Strong explanations should explicitly state:

1. `rpt_customer_ltv` is customer-grain and computes average revenue per order
2. It depends on `dim_customers`
3. `int_account_subscriptions` enriches subscriptions with account and plan data
4. `mrr_usd` is zeroed for non-active statuses by design
5. Edge cases around null dates and trial/cancelled handling
