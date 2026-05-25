CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `food_delivery`.`vw_discount_flag` AS
    SELECT 
        `food_delivery`.`deliver_history`.`order_id` AS `order_id`,
        `food_delivery`.`deliver_history`.`restaurant_name` AS `restaurant_name`,
        `food_delivery`.`deliver_history`.`subzone` AS `subzone`,
        `food_delivery`.`deliver_history`.`total` AS `total`,
        (CASE
            WHEN
                ((((COALESCE(`food_delivery`.`deliver_history`.`restaurant_discount_promo`,
                        0) + COALESCE(`food_delivery`.`deliver_history`.`restaurant_discount_flat_offs`,
                        0)) + COALESCE(`food_delivery`.`deliver_history`.`gold_discount`,
                        0)) + COALESCE(`food_delivery`.`deliver_history`.`brand_pack_discount`,
                        0)) > 0)
            THEN
                'Discount Applied'
            ELSE 'No Discount'
        END) AS `discount_flag`,
        (((COALESCE(`food_delivery`.`deliver_history`.`restaurant_discount_promo`,
                0) + COALESCE(`food_delivery`.`deliver_history`.`restaurant_discount_flat_offs`,
                0)) + COALESCE(`food_delivery`.`deliver_history`.`gold_discount`,
                0)) + COALESCE(`food_delivery`.`deliver_history`.`brand_pack_discount`,
                0)) AS `total_discount`
    FROM
        `food_delivery`.`deliver_history`