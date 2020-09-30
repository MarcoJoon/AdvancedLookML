view: order_items {
  sql_table_name: "PUBLIC"."ORDER_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    #hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: unique_user_count {
    type: count_distinct
    hidden: yes
    sql: user_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  measure: order_count {
    view_label: "Orders"
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id} ;;
  }

  measure: count {
    type: count_distinct
    drill_fields: [detail*]
    sql: ${id} ;;
  }

### Time Values
  dimension_group: created {
    type: time
    timeframes: [ raw, time, date, week, month,month_num , quarter, year]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [ raw, time, date, week, month]
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [time,date, week, month, raw]
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}."RETURNED_AT" ;;
  }



#finance metrics
  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension: gross_margin{
    type: number
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  measure: total_sale_price{
    group_label: "Sales Parameters"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
  }

  measure: total_gross_margin {
    group_label: "Sales Parameters"
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
  }

  measure: average_sale_price{
    group_label: "Sales Parameters"
    type: average
    value_format_name: usd
    sql: ${sale_price};;
  }

  measure: average_gross_margin {
    group_label: "Sales Parameters"
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
  }

  measure: cumulative_total_sales{
    group_label: "Sales Parameters"
    type: running_total
    value_format_name: usd
    sql: ${total_sale_price};;
  }

  measure: total_gross_revenue {
    group_label: "Sales Parameters"
    type: sum
    value_format_name: usd
    sql: ${sale_price};;
    filters: {
      field: is_returned
      value: "no"
    }
  }

  measure: total_gross_margin_percentage{
    type:  number
    value_format_name: percent_2
    sql: 1.0* ${total_gross_margin} / NULLIF(${total_gross_revenue},0) ;;
  }

  ######returned information
  dimension: is_returned {
    type: yesno
    sql: ${returned_raw} is NOT NULL ;;
  }

  measure: returned_count {
    type: count_distinct
    sql: ${id} ;;
    filters: [is_returned: "yes"]
  }

  measure: return_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0* ${returned_count} / NULLIF(${order_count},0) ;;
  }

  measure: customers_with_returns {
    type:  count_distinct
    sql: ${user_id} ;;
    filters: [is_returned: "yes"]
  }

  measure: customers_with_returns_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0* ${customers_with_returns} / NULLIF(${users.count},0) ;;
  }

  measure: average_spend_per_user {
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / NULLIF(${users.count},0) ;;
    drill_fields: [detail*]
  }

### Aggregations for user order facts

  measure: first_order {
    type: date_raw
    sql: MIN(${created_raw}) ;;
  }

  measure: last_order {
    type: date_raw
    sql: MAX(${created_raw}) ;;
  }



  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.first_name,
      users.last_name,
      users.id,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
