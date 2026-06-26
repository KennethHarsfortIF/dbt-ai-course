# Mart Model Contracts

This document captures the intended grain, key columns, and behavior of the mart models.

## dim_customers

- Grain: one row per customer.
- Key: `customer_id`.
- Purpose: customer dimension enriched with order activity and a simple value segmentation.
- Notes:
  - `value_tier` is derived from `completed_revenue`.
  - `total_orders` counts all orders.
  - `completed_revenue` only counts completed orders.

## fct_orders

- Grain: one row per order.
- Key: `order_id`.
- Purpose: order fact model joined with payment status.
- Notes:
  - Source orders and payments should be staged in source CTEs before deduplication or derived logic.
  - Payment records should be reduced to a single deterministic row per order before joining.
  - `is_successful_order` should reflect completed orders with at least one paid payment record.

## rpt_customer_ltv

- Grain: one row per customer.
- Key: `customer_id`.
- Purpose: customer-level reporting model for revenue and segmentation analysis.
- Notes:
  - Any average revenue metric must clearly state its denominator.
  - If the denominator changes, rename the metric so the semantics stay explicit.

## rpt_saas_mrr

- Grain: one row per `region` and `status` combination.
- Key: (`region`, `status`).
- Purpose: SaaS MRR summary by region and subscription status.
- Notes:
  - `mrr_usd` is zero for non-active subscriptions in the intermediate layer.
  - Aggregates should make it clear whether they include active-only or all subscriptions.

## Maintenance rule

- When a mart changes grain, join logic, or business meaning, update this document in the same change.
