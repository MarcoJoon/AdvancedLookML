
# If necessary, uncomment the line below to include explore_source.
include:"/models/advanced_lookml_exercise.model.lkml"
view: user_order_facts {
  derived_table: {
    explore_source: order_items {
      column: user_id {field: order_items.user_id}
      column: lifetime_orders {field: order_items.order_count}
      column: lifetime_value {field: order_items.total_sale_price}
      column: first_order {field: order_items.first_order}
      column: last_order {field: order_items.last_order}
      }
    persist_for: "24 hours"
 }

  dimension: user_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

### Lifetime Orders
  dimension: lifetime_orders {
    group_label: "Lifetime Order Facts"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: lifetime_order_tier {
    group_label: "Lifetime Order Facts"
    type: tier
    tiers: [1,2,5,9]
    sql: ${lifetime_orders} ;;
    style: integer
  }

  dimension_group: first_order {
    group_label: "Lifetime Order Facts"
    type: time
    timeframes: [time, raw, week, month]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: last_order {
    group_label: "Lifetime Order Facts"
    type: time
    timeframes: [time, raw, week, month]
    sql: ${TABLE}.last_order ;;
  }

  dimension: days_as_a_customer {
    group_label: "Lifetime Order Facts"
    type: number
    sql: DATEDIFF(DAY,${first_order_raw},${last_order_raw}) ;;
  }

  dimension: days_since_last_order {
    group_label: "Lifetime Order Facts"
    type: number
    sql: DATEDIFF(DAY, ${last_order_raw}, CURRENT_TIMESTAMP());;
  }

 dimension: is_active_user {
    group_label: "Lifetime Order Facts"
    type: yesno
    sql: ${days_since_last_order}<90 ;;
  }

  dimension: is_repeat_customer {
    group_label: "Lifetime Order Facts"
    type: yesno
    sql: ${lifetime_orders}>1 ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${lifetime_orders} ;;
  }



### Lifetime Value
  dimension: total_lifetime_value {
    group_label: "Lifetime Order Facts"
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_value ;;
  }

  dimension: lifetime_value_tier {
    group_label: "Lifetime Order Facts"
    type: tier
    tiers: [5,20,50,100,500,1000]
    sql: ${total_lifetime_value} ;;
    style: integer
    value_format: "$#,##0"
  }

  measure: average_lifetime_value  {
    type: average
    value_format_name: usd
    sql: ${total_lifetime_value} ;;
  }
}

# view: user_order_facts {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }
