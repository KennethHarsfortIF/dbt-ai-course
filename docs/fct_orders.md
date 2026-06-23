{% docs fct_orders %}
Fact table at order-payment join grain.

This model combines cleaned orders from stg_orders with payment attributes from stg_payments using a left join on order_id.

Grain and behavior:
- One row per joined order-payment record, not strictly one row per order.
- Orders with no payments are retained with null payment fields.
- Orders with multiple payment records produce multiple rows.

The is_successful_order flag is true only when order_status = 'completed' and payment_status = 'paid'. All other cases return false, including rows where payment_status is null.

Important modeling note:
If the payment grain changes (for example to multiple events per order), this join can duplicate order rows and inflate downstream counts or sums unless payments are deduplicated or aggregated before joining.
{% enddocs %}
