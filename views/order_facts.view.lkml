include: "/models/advanced_lookml_exercise.model.lkml"
view: order_facts {
  derived_table: {
    explore_source: order_items {
      column: order_id {}
      column: items_in_order {field: order_items.count}
      column: order_amount {field: order_items.total_gross_revenue}
      column: order_cost {field: inventory_items.cost}
      column: user_id {}
      column: created_at {field: order_items.created_raw }
      derived_column: order_sequence_order{
        sql: RANK() OVER (PARTITION BY user_id ORDER BY created_at);;
      }
   }
persist_for: "24 hours"
    }
dimension: order_id {
  hidden: yes
  primary_key: yes
  type: number
  sql: ${TABLE}.order_id ;;
  }

dimension: items_in_order {
  type: number
  sql: ${TABLE}.items_in_order ;;
  }

dimension: order_amount {
  type: number
  value_format_name: usd
  sql: ${TABLE}.order_amount ;;
  }

dimension: order_cost {
  type: number
  value_format_name: usd
  sql: ${TABLE}.order_cost ;;
  }

dimension: user_id {
  type: number
  sql: ${TABLE}.user_id ;;
  }

dimension: order_sequence_order {
  type: number
  sql: ${TABLE}.order_sequence_order ;;
  }
dimension: is_first_purchase {
  type: yesno
  sql: ${order_sequence_order} = 1 ;;
  }
}
