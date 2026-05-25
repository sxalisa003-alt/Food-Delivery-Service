CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `food_delivery`.`vw_delivery_metrics` AS
    SELECT 
        `food_delivery`.`deliver_history`.`restaurant_id` AS `restaurant_id`,
        `food_delivery`.`deliver_history`.`restaurant_name` AS `restaurant_name`,
        `food_delivery`.`deliver_history`.`subzone` AS `subzone`,
        `food_delivery`.`deliver_history`.`city` AS `city`,
        `food_delivery`.`deliver_history`.`order_id` AS `order_id`,
        `food_delivery`.`deliver_history`.`order_placed_at` AS `order_placed_at`,
        `food_delivery`.`deliver_history`.`order_status` AS `order_status`,
        `food_delivery`.`deliver_history`.`delivery` AS `delivery`,
        `food_delivery`.`deliver_history`.`distance` AS `distance`,
        `food_delivery`.`deliver_history`.`items_in_order` AS `items_in_order`,
        `food_delivery`.`deliver_history`.`instructions` AS `instructions`,
        `food_delivery`.`deliver_history`.`discount_construct` AS `discount_construct`,
        `food_delivery`.`deliver_history`.`bill_subtotal` AS `bill_subtotal`,
        `food_delivery`.`deliver_history`.`packaging_charges` AS `packaging_charges`,
        `food_delivery`.`deliver_history`.`restaurant_discount_promo` AS `restaurant_discount_promo`,
        `food_delivery`.`deliver_history`.`restaurant_discount_flat_offs` AS `restaurant_discount_flat_offs`,
        `food_delivery`.`deliver_history`.`gold_discount` AS `gold_discount`,
        `food_delivery`.`deliver_history`.`brand_pack_discount` AS `brand_pack_discount`,
        `food_delivery`.`deliver_history`.`total` AS `total`,
        `food_delivery`.`deliver_history`.`rating` AS `rating`,
        `food_delivery`.`deliver_history`.`review` AS `review`,
        `food_delivery`.`deliver_history`.`cancellation_rejection_reason` AS `cancellation_rejection_reason`,
        `food_delivery`.`deliver_history`.`restaurant_compensation_cancellation` AS `restaurant_compensation_cancellation`,
        `food_delivery`.`deliver_history`.`restaurant_penalty_rejection` AS `restaurant_penalty_rejection`,
        `food_delivery`.`deliver_history`.`kpt_duration_minutes` AS `kpt_duration_minutes`,
        `food_delivery`.`deliver_history`.`rider_wait_time_minutes` AS `rider_wait_time_minutes`,
        `food_delivery`.`deliver_history`.`order_ready_marked` AS `order_ready_marked`,
        `food_delivery`.`deliver_history`.`customer_complaint_tag` AS `customer_complaint_tag`,
        `food_delivery`.`deliver_history`.`customer_id` AS `customer_id`,
        (CASE
            WHEN (`food_delivery`.`deliver_history`.`kpt_duration_minutes` <= 10) THEN '0-10'
            WHEN (`food_delivery`.`deliver_history`.`kpt_duration_minutes` <= 20) THEN '11-20'
            WHEN (`food_delivery`.`deliver_history`.`kpt_duration_minutes` <= 30) THEN '21-30'
            ELSE '30+'
        END) AS `kpt_bucket`,
        (CASE
            WHEN (`food_delivery`.`deliver_history`.`rider_wait_time_minutes` <= 5) THEN '0-5'
            WHEN (`food_delivery`.`deliver_history`.`rider_wait_time_minutes` <= 10) THEN '6-10'
            ELSE '10+'
        END) AS `rwt_bucket`
    FROM
        `food_delivery`.`deliver_history`