connection: "snowlooker"

# include all the views
include: "/views/**/*.view"

datagroup: advanced_lookml_exercise_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: advanced_lookml_exercise_default_datagroup

# explore: distribution_centers {}
#
# explore: etl_jobs {}

# explore: events {
#   join: users {
#     type: left_outer
#     sql_on: ${events.user_id} = ${users.id} ;;
#     relationship: many_to_one
#   }
# }

# explore: inventory_items {
#   join: products {
#     type: left_outer
#     sql_on: ${inventory_items.product_id} = ${products.id} ;;
#     relationship: many_to_one
#   }
#
#   join: distribution_centers {
#     type: left_outer
#     sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
#     relationship: many_to_one
#   }
# }

explore: order_items {

  join: order_facts {
    view_label: "Orders"
    type: left_outer
    sql_on: ${order_items.order_id} = ${order_facts.order_id} ;;
    relationship: many_to_many
  }
  join: inventory_items {
    type: full_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: one_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    view_label: "Users"
    type: left_outer
    sql_on: ${users.id} = ${user_order_facts.user_id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}


explore: users {}
