# Business Glossary

This document defines the terms used by the marts layer.

## Ecommerce

- `total_orders`: Count of all orders for a customer, regardless of status.
- `completed_revenue`: Sum of `order_amount` for orders with `order_status = 'completed'`.
- `value_tier`: Revenue segment derived from `completed_revenue`.
  - `high_value`: `completed_revenue >= 300`
  - `medium_value`: `completed_revenue >= 100` and `< 300`
  - `low_value`: `completed_revenue < 100`
- `is_successful_order`: True when an order is completed and has at least one paid payment record.
- `order_status`: Lifecycle status of an order from the staging layer.
- `payment_status`: Lifecycle status of a payment from the staging layer.
- `avg_revenue_per_order`: Average revenue per order. If used as currently modeled, the denominator is `total_orders`.

## SaaS

- `mrr_usd`: Monthly recurring revenue for a subscription. In the intermediate layer, active subscriptions contribute their plan price and non-active subscriptions contribute `0`.
- `total_mrr_usd`: Sum of `mrr_usd` for the reporting group.
- `avg_mrr_usd`: Average of `mrr_usd` for the reporting group.
- `subscriptions`: Count of subscription records in the reporting group.
- `region`: Account region from the account dimension.
- `status`: Subscription lifecycle status from the staging layer.

## Notes

- If a metric definition changes, update this glossary in the same change.
- If a new mart introduces a new business term, add it here before or alongside the model change.
