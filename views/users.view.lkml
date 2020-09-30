view: users {
  sql_table_name: "PUBLIC"."USERS"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: age_tier {
    type: tier
    tiers: [15, 25, 35, 50, 65]
    style: integer
    sql: ${age} ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: is_before_mtd {
    type: yesno
    sql:
      DAY( ${created_raw}) < DAY(CURRENT_TIMESTAMP())
      OR
      (DAY( ${created_raw}) = DAY(CURRENT_TIMESTAMP())
      AND HOUR( ${created_raw}) < HOUR( ${created_raw}))
      OR
      (DAY( ${created_raw}) = DAY( CURRENT_TIMESTAMP())
      AND HOUR( ${created_raw}) = HOUR( CURRENT_TIMESTAMP())
      AND MINUTE( ${created_raw}) < MINUTE( CURRENT_TIMESTAMP()))   ;;
  }

  dimension: is_new_user {
    type: yesno
    sql:  ${days_enrolled} <90 ;;
  }

  dimension: days_enrolled {
    hidden: yes
    type: duration_day
    sql_start: ${created_raw} ;;
    sql_end: CURRENT_TIMESTAMP() ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}."GENDER" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: city {
    group_label: "Location"
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: country {
    group_label: "Location"
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: user_location {
    group_label: "Location"
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: latitude {
    group_label: "Location"
    type: number
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    group_label: "Location"
    type: number
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: state {
    group_label: "Location"
    type: string
    sql: ${TABLE}."STATE" ;;
  }


  dimension: zip {
    group_label: "Location"
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}."TRAFFIC_SOURCE" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, events.count, order_items.count]
  }
}
