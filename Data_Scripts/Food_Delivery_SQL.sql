# EXECUTIVE SUMMARY PAGE
#Core KPIs

#     Restaurant Performance by Revenue & Orders
SELECT 
    restaurant_name,
    COUNT(order_id) AS total_orders,
    SUM(total) AS total_revenue
FROM
    deliver_history
GROUP BY restaurant_name
ORDER BY total_orders DESC , total_revenue DESC;
#     Restaurant-Subzone Performance 
SELECT 
    restaurant_name,
    subzone,
    SUM(total) AS total_revenue,
    COUNT(order_id) AS total_orders
FROM
    deliver_history
GROUP BY restaurant_name , subzone
ORDER BY total_revenue DESC , total_orders DESC;
#      Average Order Value by Restaurant
SELECT 
    restaurant_name,
    SUM(total) AS total_revenue,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(total), 2) AS avg_order_value
FROM
    deliver_history
GROUP BY restaurant_name
ORDER BY avg_order_value DESC;  #this also answers the average order value per restaurant
#      Monthly Revenue & Order Growth
with MonthlySales as (select
date_format(order_placed_at,'%Y-%m-01') as month_start,
sum(total) as curr_month_revenue,
count(order_id) as curr_order_count
from deliver_history
GROUP BY month_start)
select month_start,curr_month_revenue,curr_order_count,
LAG(curr_month_revenue) OVER (order by month_start) as prev_month_revenue,
round(
((curr_month_revenue-LAG(curr_month_revenue) OVER (Order by month_start))/
LAG(curr_month_revenue) OVER (Order by month_start))*100,2) as revenue_MoM_percent,
LAG(curr_order_count) OVER (ORDER BY month_start) AS prev_order_count,
round(
((curr_order_count-LAG(curr_order_count) OVER (Order by month_start))/
LAG(curr_order_count) OVER (Order by month_start))*100,2) as order_MoM_percent
from MonthlySales
Order By month_start ;   #gives the MoM 

# Performance Snapshot

#       Top Revenue Restaurant
SELECT 
    restaurant_name, SUM(total) AS total_revenue
FROM
    deliver_history
GROUP BY restaurant_name
ORDER BY total_revenue DESC
LIMIT 1;
#         Best Performing Subzone   
SELECT 
    subzone,
    SUM(total) AS total_revenue,
    COUNT(order_id) AS total_orders
FROM
    deliver_history
GROUP BY subzone
ORDER BY total_revenue DESC , total_orders DESC
LIMIT 1;

# Business Health

#          Cancellation Rate
SELECT 
    restaurant_name,
    COUNT(*) AS total_orders,
    COUNT(CASE
        WHEN cancellation_rejection_reason != 'unknown' THEN 1
    END) AS total_cancellations,
    ROUND(COUNT(CASE
                WHEN cancellation_rejection_reason != 'unknown' THEN 1
            END) * 100.0 / COUNT(*),
            2) AS cancellation_rate_pct,
    SUM(CASE
        WHEN cancellation_rejection_reason != 'unknown' THEN restaurant_compensation_cancellation
        ELSE 0
    END) AS total_compensation,
    SUM(CASE
        WHEN cancellation_rejection_reason != 'unknown' THEN restaurant_penalty_rejection
        ELSE 0
    END) AS total_penalty
FROM
    deliver_history
GROUP BY restaurant_name
ORDER BY cancellation_rate_pct DESC;
#            Average Customer Rating
SELECT 
    restaurant_name, AVG(rating) AS avg_rating
FROM
    deliver_history
GROUP BY restaurant_name
ORDER BY avg_rating DESC;
#              Order Status Performance
SELECT 
    order_status,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total), 2) AS total_revenue,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(kpt_duration_minutes), 2) AS avg_kpt,
    ROUND(AVG(rider_wait_time_minutes), 2) AS avg_rider_wait
FROM
    deliver_history
GROUP BY order_status
ORDER BY total_orders DESC;



# MARKETING REPORT PAGE
#Demand Analysis

#       Top Demand Subzones
SELECT 
    subzone,
    SUM(total) AS total_revenue,
    COUNT(order_id) AS count_order
FROM
    deliver_history
GROUP BY subzone
ORDER BY total_revenue DESC;

#        Strongest Restaurant Demand Areas
SELECT 
    restaurant_name, subzone, COUNT(order_id) AS count_order
FROM
    deliver_history
GROUP BY restaurant_name , subzone
ORDER BY count_order DESC;

#Discounts & Promotions

#        Discount Impact
SELECT 
    discount_flag,
    COUNT(order_id) AS total_orders,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_order_value
FROM
    vw_discount_flag
GROUP BY discount_flag;
#           Discounted vs Non-Discounted Orders
SELECT 
    restaurant_name,
    SUM(CASE
        WHEN total_discount > 0 THEN 1
        ELSE 0
    END) AS orders_with_discount,
    SUM(CASE
        WHEN total_discount = 0 THEN 1
        ELSE 0
    END) AS orders_without_discount,
    COUNT(order_id) AS total_orders
FROM
    vw_discount_flag
GROUP BY restaurant_name;
#            Revenue by Discount Presence
SELECT 
    subzone,
    COUNT(CASE
        WHEN total_discount > 0 THEN 1
    END) AS discounted_orders,
    COUNT(CASE
        WHEN total_discount = 0 THEN 1
    END) AS non_discounted_orders,
    SUM(total) AS revenue
FROM
    vw_discount_flag
GROUP BY subzone;

# Customer Analytics
#           Repeat Customer Distribution
SELECT 
    restaurant_name, customer_id, COUNT(*) AS total_orders
FROM
    deliver_history
GROUP BY restaurant_name , customer_id
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;

#            Customer Segmentation
WITH CustomerMetrics AS (
    SELECT 
        customer_id, 
        COUNT(order_id) as total_orders,
        SUM(total) as total_spent
    FROM deliver_history
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN total_orders >= 50 THEN '5. Elite (High Rollers)'
        WHEN total_orders >= 25 THEN '4. Loyal (Brand Advocates)'
        WHEN total_orders >= 10 THEN '3. Regulars (Repeat Buyers)'
        WHEN total_orders > 1  THEN '2. Emerging (Returning)'
        ELSE '1. One-Timer (New)' 
    END AS customer_segment,
    COUNT(customer_id) AS total_customers,
    SUM(total_spent) AS revenue_contribution,
    ROUND(AVG(total_spent / total_orders), 2) AS avg_ticket_size
FROM CustomerMetrics
GROUP BY customer_segment
ORDER BY customer_segment DESC;

#        Repeat Customer Rate
SELECT 
    COUNT(DISTINCT CASE
            WHEN order_count > 1 THEN customer_id
        END) * 100.0 / COUNT(DISTINCT customer_id) AS repeat_customer_rate_pct
FROM
    (SELECT 
        customer_id, COUNT(order_id) AS order_count
    FROM
        deliver_history
    GROUP BY customer_id) t;
    
    
# Time-Based Sales Patterns

#       Peak Days & Hours
SELECT 
    DAYNAME(order_placed_at) AS day_of_week,
    DAYOFWEEK(order_placed_at) AS day_num,
    CASE
        WHEN HOUR(order_placed_at) BETWEEN 6 AND 10 THEN '1. Breakfast'
        WHEN HOUR(order_placed_at) BETWEEN 11 AND 14 THEN '2. Lunch Rush'
        WHEN HOUR(order_placed_at) BETWEEN 15 AND 17 THEN '3. Afternoon Slump'
        WHEN HOUR(order_placed_at) BETWEEN 18 AND 21 THEN '4. Dinner Peak'
        ELSE '5. Late Night'
    END AS business_segment,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(total), 2) AS revenue,
    ROUND(AVG(kpt_duration_minutes), 2) AS avg_kitchen_time
FROM
    deliver_history
GROUP BY day_of_week , day_num , business_segment
ORDER BY day_num ASC , business_segment ASC;     
#          Revenue by Day of Month
SELECT 
    DAY(order_placed_at) AS day_of_month,
    SUM(total) AS daily_revenue
FROM
    deliver_history
GROUP BY day_of_month
ORDER BY day_of_month;
#           Revenue by Subzone per Month
SELECT 
    subzone,
    DATE_FORMAT(order_placed_at, '%Y-%m-01') AS month_start,
    SUM(total) AS revenue
FROM deliver_history    #use a BI heatmap
GROUP BY subzone, month_start
ORDER BY month_start, revenue DESC;


#OPERATIONS REPORT PAGE
#Distance & Delivery Analysis

#           Distance vs Cancellations
SELECT 
    *
FROM
    nw_rejection_reasons
ORDER BY Cancelled_by_Zomato DESC ,
 Merchant_device_issue DESC ,
 Cancelled_by_Customer DESC , 
 Kitchen_is_full DESC , 
 Items_out_of_stock DESC;
#           Average Delivery Distance
select
subzone,
restaurant_name,
avg(distance) as avg_distance
from deliver_history
group by subzone,restaurant_name
order by avg_distance desc;
#           Rider Wait Time Impact on Order Outcomes
SELECT 
    rwt_bucket,
    COUNT(CASE WHEN order_status = 'Delivered'        THEN 1 END) AS delivered,
    COUNT(CASE WHEN order_status = 'Returned'         THEN 1 END) AS returned,
    COUNT(CASE WHEN order_status = 'Rejected'         THEN 1 END) AS rejected,
    COUNT(CASE WHEN order_status = 'Return cancelled' THEN 1 END) AS return_cancelled,
    COUNT(CASE WHEN order_status = 'Picked up'        THEN 1 END) AS picked_up,
    COUNT(CASE WHEN order_status = 'Timed out'        THEN 1 END) AS timed_out,
    COUNT(order_id) AS total_orders
FROM vw_delivery_metrics
GROUP BY rwt_bucket
ORDER BY rwt_bucket ASC;

#Kitchen & Rider Efficiency

#            KPT vs Order Volume
SELECT 
    kpt_bucket, COUNT(order_id) AS order_volume
FROM
    vw_delivery_metrics
GROUP BY kpt_bucket
ORDER BY order_volume DESC;
#            RWT vs Order Volume
SELECT 
    rwt_bucket, COUNT(order_id) AS order_volume
FROM
    vw_delivery_metrics
GROUP BY rwt_bucket
ORDER BY order_volume DESC;

#            KPT vs Cancellations
select   
kpt_bucket,
            count(cancellation_rejection_reason) as count_rejection
            from vw_delivery_metrics
            where cancellation_rejection_reason='Cancelled by Customer'
            group by kpt_bucket order by count_rejection DESC;
#            RWT vs Cancellations          
 select 
 rwt_bucket,
         count(cancellation_rejection_reason) as count_rejection
         from vw_delivery_metrics
         where cancellation_rejection_reason='Cancelled by Customer'
         group by rwt_bucket order by count_rejection DESC;
         
# Order Tracking Accuracy

#           Kitchen Prep Impact
SELECT 
    kpt_bucket,
    COUNT(CASE
        WHEN order_ready_marked = 'Correctly' THEN 1
    END) AS marked_correctly,
    COUNT(CASE
        WHEN order_ready_marked = 'Incorrectly' THEN 1
    END) AS marked_incorrectly,
    COUNT(CASE
        WHEN customer_complaint_tag = 'Poor taste or quality' THEN 1
    END) AS poor_taste_or_quality,
    COUNT(CASE
        WHEN customer_complaint_tag = 'Non-refunded complaint' THEN 1
    END) AS non_refunded_complaint,
    COUNT(CASE
        WHEN customer_complaint_tag = 'Poor packaging or spillage' THEN 1
    END) AS poor_packaging,
    COUNT(CASE
        WHEN customer_complaint_tag = 'Item(s) missing or not delivered' THEN 1
    END) AS missing_items,
    COUNT(CASE
        WHEN customer_complaint_tag = 'Wrong item(s) delivered' THEN 1
    END) AS wrong_items,
    COUNT(CASE
        WHEN customer_complaint_tag IS NULL THEN 1
    END) AS no_complaint
FROM
    vw_delivery_metrics
GROUP BY kpt_bucket
ORDER BY marked_correctly DESC , marked_incorrectly DESC;

# Cancellation Analysis

#         Cancellation Reasons by Restaurant & Subzone
SELECT 
    subzone,
    restaurant_name,
    COUNT(CASE
        WHEN cancellation_rejection_reason = 'Cancelled by Zomato' THEN 1
    END) AS Cancelled_by_Zomato,
    COUNT(CASE
        WHEN cancellation_rejection_reason = 'Merchant device issue' THEN 1
    END) AS Merchant_device_issue,
    COUNT(CASE
        WHEN cancellation_rejection_reason = 'Cancelled by Customer' THEN 1
    END) AS Cancelled_by_Customer,
    COUNT(CASE
        WHEN cancellation_rejection_reason = 'Kitchen is full' THEN 1
    END) AS Kitchen_is_full,
    COUNT(CASE
        WHEN cancellation_rejection_reason = 'Items out of stock' THEN 1
    END) AS Items_out_of_stock
FROM
    deliver_history
GROUP BY subzone , restaurant_name
ORDER BY Cancelled_by_Zomato DESC , Merchant_device_issue DESC , Cancelled_by_Customer DESC , Kitchen_is_full DESC , Items_out_of_stock DESC;
#                Delay vs Ratings & Cancellations
SELECT 
    cancellation_rejection_reason,
    rating,
    COUNT(cancellation_rejection_reason) AS count_reject,
    COUNT(CASE
        WHEN order_ready_marked = 'Correctly' THEN 1
    END) AS marked_correctly,
    COUNT(CASE
        WHEN order_ready_marked = 'Incorrectly' THEN 1
    END) AS marked_incorrectly
FROM
    deliver_history
WHERE
    cancellation_rejection_reason IN ('Cancelled by Zomato' , 'Merchant device issue',
        'Cancelled by Customer',
        'Kitchen is full',
        'Items out of stock')
GROUP BY cancellation_rejection_reason , rating
ORDER BY count_reject DESC , marked_correctly DESC , marked_incorrectly DESC;

use food_delivery;
select * from deliver_history;

SELECT
    restaurant_name,
    subzone,
    
    kpt_bucket,
    rwt_bucket,
    
    cancellation_rejection_reason,
    
    COUNT(order_id) AS total_cancellations,
    
    ROUND(AVG(kpt_duration_minutes),2) AS avg_kpt_minutes,
    ROUND(AVG(rider_wait_time_minutes),2) AS avg_rwt_minutes,
    
    ROUND(AVG(distance),2) AS avg_distance,
    
    ROUND(AVG(rating),2) AS avg_rating,
    
    COUNT(CASE 
        WHEN customer_complaint_tag IS NOT NULL 
        THEN 1 
    END) AS complaint_count

FROM vw_delivery_metrics

WHERE cancellation_rejection_reason != 'unknown'

GROUP BY
    restaurant_name,
    subzone,
    kpt_bucket,
    rwt_bucket,
    cancellation_rejection_reason

ORDER BY
    total_cancellations DESC,
    avg_kpt_minutes DESC,
    avg_rwt_minutes DESC;
