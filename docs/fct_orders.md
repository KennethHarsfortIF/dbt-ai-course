# fct_orders

## Overview

This model is a simple order fact table for reporting. It brings together each order with its payment details so analysts can understand order value, payment state, and whether an order appears to have been completed successfully.

## Key columns and logic

- order_id: The unique identifier for the order.
- customer_id: The customer linked to the order.
- order_date: The date the order was placed.
- order_status: The current status of the order, such as completed.
- order_amount: The value of the order.
- payment_method: The payment method used for the order, when a payment record exists.
- payment_status: The payment status, such as paid or pending.
- processed_at: The timestamp when the payment was processed.
- is_successful_order: A simple flag that is true only when the order is completed and the payment is marked as paid.

## Assumptions and caveats

- This is a lightweight reporting model, not a full finance or accounting model.
- The model uses a left join from orders to payments, so orders without a matching payment row will still appear with null payment fields and a false success flag.
- If a single order has multiple payment rows, this model can return more than one row for that order.
