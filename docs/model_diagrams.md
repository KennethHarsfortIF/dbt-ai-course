# dbt Model Diagrams

Legend: V = verified from dbt tests and/or SQL join logic. A = assumed business-grain relationship (not enforced by tests/constraints).

### How to Read the ER Diagrams

- Each box is a table/model.
- `PK` means primary key (expected unique row identifier).
- `FK` means foreign key (column used to connect to another table).
- Relationship symbols:
  - `||` = exactly one
  - `o|` = zero or one
  - `|{` = one or many
  - `o{` = zero or many
- Example: `dim_customers ||--o{ fct_orders` means one customer can have zero or many orders.
- Edge labels show the join column (for example, `customer_id`) and whether the relationship is `V` (verified) or `A` (assumed).

## Table Relationships — Layer 1: Raw Seeds

```mermaid
erDiagram
  raw_customers {
    int    customer_id PK
    string first_name
    string last_name
    string email
    date   signup_date
    string country
    string segment
  }
  raw_orders {
    int    order_id PK
    int    customer_id FK
    date   order_date
    string order_status
    float  order_amount
  }
  raw_payments {
    int       payment_id PK
    int       order_id FK
    string    payment_method
    string    payment_status
    timestamp processed_at
  }
  raw_accounts {
    int    account_id PK
    string account_name
    string region
    date   created_date
  }
  raw_plans {
    int    plan_id PK
    string plan_name
    string billing_cycle
    float  price_usd
  }
  raw_subscriptions {
    int    subscription_id PK
    int    account_id FK
    int    plan_id FK
    date   start_date
    date   end_date
    string status
  }

  raw_customers ||--o{ raw_orders : "customer_id [A]"
  raw_orders    ||--o{ raw_payments : "order_id [A]"
  raw_accounts  ||--o{ raw_subscriptions : "account_id [A]"
  raw_plans     ||--o{ raw_subscriptions : "plan_id [A]"
```

---

## Table Relationships — Layer 2: Staging

```mermaid
erDiagram
  stg_customers {
    int    customer_id PK
    string email
    string first_name
    string last_name
    date   signup_date
    string country
    string segment
  }
  stg_orders {
    int    order_id PK
    int    customer_id FK
    date   order_date
    string order_status
    float  order_amount
  }
  stg_payments {
    int       payment_id PK
    int       order_id FK
    string    payment_method
    string    payment_status
    timestamp processed_at
  }
  stg_accounts {
    int    account_id PK
    string account_name
    string region
    date   created_date
  }
  stg_plans {
    int    plan_id PK
    string plan_name
    string billing_cycle
    float  price_usd
  }
  stg_subscriptions {
    int    subscription_id PK
    int    account_id FK
    int    plan_id FK
    date   start_date
    date   end_date
    string status
  }

  stg_customers ||--o{ stg_orders : "customer_id [V: relationships test]"
  stg_orders    ||--o{ stg_payments : "order_id [V: relationships test]"
  stg_accounts  ||--o{ stg_subscriptions : "account_id [V: relationships test]"
  stg_plans     ||--o{ stg_subscriptions : "plan_id [V: relationships test]"
```

---

## Table Relationships — Layer 3: Intermediate

No direct join relationship exists between the two intermediate tables; each is built independently from staging models.

Build hints from docs/SQL:
- int_customer_orders grain is one row per customer_id [V: unique test on customer_id].
- int_account_subscriptions grain is one row per subscription_id [V: unique test on subscription_id].

```mermaid
erDiagram
  int_customer_orders {
    int    customer_id PK
    string email
    string country
    string segment
    int    total_orders
    float  completed_revenue
    date   last_order_date
  }
  int_account_subscriptions {
    int    subscription_id PK
    int    account_id FK
    string account_name
    string region
    int    plan_id FK
    string plan_name
    float  price_usd
    string status
    date   start_date
    date   end_date
    float  mrr_usd
  }

```

---

## Table Relationships — Layer 4: Marts & Reports

```mermaid
erDiagram
  dim_customers {
    int    customer_id PK
    string email
    string country
    string segment
    int    total_orders
    float  completed_revenue
    date   last_order_date
    string value_tier
  }
  fct_orders {
    int       order_id PK
    int       customer_id FK
    date      order_date
    string    order_status
    float     order_amount
    string    payment_method
    string    payment_status
    timestamp processed_at
    boolean   is_successful_order
  }
  rpt_customer_ltv {
    int    customer_id PK
    string email
    string country
    string segment
    string value_tier
    int    total_orders
    float  completed_revenue
    float  avg_revenue_per_order
  }
  rpt_saas_mrr {
    string region PK
    string status PK
    int    subscriptions
    float  total_mrr_usd
    float  avg_mrr_usd
  }
  example_generated_model {
    date  order_date PK
    int   order_count
    float successful_revenue
  }

  dim_customers   ||--o{ fct_orders            : "customer_id [A: semantic join key]"
  dim_customers   ||--|| rpt_customer_ltv       : "customer_id [V: ref + unique test]"
  example_generated_model ||--o{ fct_orders      : "order_date [V: SQL aggregation]"
```

---



## Model Layer Overview

Shows how models are organised across layers without the raw seeds.

```mermaid
flowchart LR
  subgraph S[Staging]
    stg_accounts
    stg_customers
    stg_orders
    stg_payments
    stg_plans
    stg_subscriptions
  end

  subgraph I[Intermediate]
    int_customer_orders
    int_account_subscriptions
  end

  subgraph M[Marts]
    dim_customers
    fct_orders
    rpt_customer_ltv
    rpt_saas_mrr
  end

  subgraph P[Playground]
    example_generated_model
  end

  stg_customers --> int_customer_orders
  stg_orders --> int_customer_orders

  stg_accounts --> int_account_subscriptions
  stg_plans --> int_account_subscriptions
  stg_subscriptions --> int_account_subscriptions

  int_customer_orders --> dim_customers
  dim_customers --> rpt_customer_ltv

  stg_orders --> fct_orders
  stg_payments --> fct_orders

  int_account_subscriptions --> rpt_saas_mrr
  fct_orders --> example_generated_model
```

---

## Full Lineage (Seeds → Marts)

End-to-end lineage from raw seed files through every model layer.

```mermaid
flowchart LR
  subgraph R[Raw Seeds]
    raw_accounts
    raw_customers
    raw_orders
    raw_payments
    raw_plans
    raw_subscriptions
  end

  subgraph S[Staging Models]
    stg_accounts
    stg_customers
    stg_orders
    stg_payments
    stg_plans
    stg_subscriptions
  end

  subgraph I[Intermediate Models]
    int_customer_orders
    int_account_subscriptions
  end

  subgraph M[Marts and Reports]
    dim_customers
    fct_orders
    rpt_customer_ltv
    rpt_saas_mrr
  end

  subgraph P[Playground]
    example_generated_model
  end

  raw_accounts --> stg_accounts
  raw_customers --> stg_customers
  raw_orders --> stg_orders
  raw_payments --> stg_payments
  raw_plans --> stg_plans
  raw_subscriptions --> stg_subscriptions

  stg_customers --> int_customer_orders
  stg_orders --> int_customer_orders

  stg_subscriptions --> int_account_subscriptions
  stg_plans --> int_account_subscriptions
  stg_accounts --> int_account_subscriptions

  int_customer_orders --> dim_customers
  dim_customers --> rpt_customer_ltv

  stg_orders --> fct_orders
  stg_payments --> fct_orders

  int_account_subscriptions --> rpt_saas_mrr
  fct_orders --> example_generated_model
```
