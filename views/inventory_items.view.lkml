view: inventory_items {
  sql_table_name: "PUBLIC"."INVENTORY_ITEMS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: product_brand {
    type: string
    sql: ${TABLE}."PRODUCT_BRAND" ;;
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}."PRODUCT_CATEGORY" ;;
  }

  dimension: product_department {
    type: string
    sql: ${TABLE}."PRODUCT_DEPARTMENT" ;;
  }

  dimension: product_distribution_center_id {
    type: number
    sql: ${TABLE}."PRODUCT_DISTRIBUTION_CENTER_ID" ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}."PRODUCT_NAME" ;;
  }

  dimension: product_retail_price {
    type: number
    sql: ${TABLE}."PRODUCT_RETAIL_PRICE" ;;
  }

  dimension: product_sku {
    type: string
    sql: ${TABLE}."PRODUCT_SKU" ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."SOLD_AT" ;;
  }

  dimension: days_in_inventory {
    description: "days between created and sold date"
    type: number
    sql: DATEDIFF('day', ${created_raw}, coalesce(${sold_raw},CURRENT_DATE)) ;;
  }

  dimension: days_in_inventory_tier {
    type: tier
    sql: ${days_in_inventory} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: days_since_arrival {
    description: "days since created - useful when filtering on sold yesno for items still in inventory"
    type: number
    sql: DATEDIFF('day', ${created_date}, CURRENT_DATE) ;;
  }


  dimension: is_sold {
    type: yesno
    sql: ${sold_raw} is not null ;;
  }

  measure: count {
    type: count
    drill_fields: [id, product_name, products.id, products.name, order_items.count]
  }

  measure: sold_percent {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${sold_count}/NULLIF(${count},0) ;;
  }

  measure: sold_count {
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: inventory_day_average{
    type: average_distinct
    sql: ${product_id} ;;
  }

  measure: total_cost{
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
 }

  measure:average_cost  {
    type: average
    sql: ${cost} ;;
    value_format_name: usd
  }

  set: detail {
    fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
  }
}
