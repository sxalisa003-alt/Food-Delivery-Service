CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `food_delivery`.`nw_rejection_reasons` AS
    SELECT 
        (CASE
            WHEN (`food_delivery`.`deliver_history`.`distance` <= 5.00) THEN '<= 5km'
            WHEN (`food_delivery`.`deliver_history`.`distance` <= 10.00) THEN '<=10km'
            WHEN (`food_delivery`.`deliver_history`.`distance` > 10.00) THEN '>10km'
        END) AS `distance_range`,
        COUNT((CASE
            WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Cancelled by Zomato') THEN 1
        END)) AS `Cancelled_by_Zomato`,
        COUNT((CASE
            WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Merchant device issue') THEN 1
        END)) AS `Merchant_device_issue`,
        COUNT((CASE
            WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Cancelled by Customer') THEN 1
        END)) AS `Cancelled_by_Customer`,
        COUNT((CASE
            WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Kitchen is full') THEN 1
        END)) AS `Kitchen_is_full`,
        COUNT((CASE
            WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Items out of stock') THEN 1
        END)) AS `Items_out_of_stock`
    FROM
        `food_delivery`.`deliver_history`
    GROUP BY `distance_range`