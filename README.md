# Food-Delivery-Service

## Business Scenario

Zomato Delivery is a food delivery company operating in NCR Delhi, India, that partners with multiple restaurants across several subzones to fulfill customer orders. The platform records operational, transactional, and customer-related data, including order status, customer ratings, discounts, delivery times, cancellations, rider wait times, kitchen preparation times, and revenue metrics.
As the business scales across different restaurants and delivery zones, management requires better visibility into:
 * Revenue Performance
 * Customer Retention
 * Operational Efficiency
 * Delivery Reliability
 * Cancellation Behaviour
   
The company aims to use data analytics and business intelligence to identify operational bottlenecks, understand customer behaviour, improve delivery performance, and optimize decision-making across restaurants and subzones.

## Core Problem Statement

Despite operating across multiple restaurants and delivery subzones, the business lacks centralized visibility into customer behaviour, operational efficiency, revenue drivers, and delivery performance. High cancellation rates, delivery delays, inconsistent restaurant performance, and fluctuating customer demand may negatively affect profitability and customer satisfaction.
This project aims to leverage SQL and Power BI to transform operational delivery data into actionable business insights that support strategic and operational decision-making.

## Business Questions
### Revenue & Growth
   * Which restaurants and subzones generate the highest revenue?
   * How does revenue change over time?
   * Which locations underperform relative to demand?
### Customer & Marketing
   * Do discounts improve customer purchasing behaviour?
   *  What percentage of customers are repeat buyers?
   * Which customer segments contribute most to revenue?
   * During which days and times does demand peak?
### Operations & Delivery
   * How do rider wait times and kitchen prep times affect delivery outcomes?
   * What operational issues contribute most to cancellations?
   * Does delivery distance affect customer satisfaction or order completion?
### Customer Experience
   * Which operational inefficiencies are associated with low ratings and complaints?
   * Which restaurants maintain the strongest customer satisfaction?

## Tools & Skills Used
  * MySQL
  * Power BI
  * DAX
  * Data modeling
  * Data cleaning
  * KPI analysis
  * Customer segmentation
  * Operational analytics
  * Python
  * Pandas
  * CSV File Handling

## Data Preparation

### Data Validity Checks and Data Cleaning

The dataset used for this project was sourced from Kaggle and contained historical food-delivery transaction data for restaurants operating across multiple subzones in the NCR of Delhi, India. Before analysis could begin, the raw dataset required significant preprocessing to improve consistency, remove invalid records, standardize formatting, and prepare the data for SQL and Power BI analysis. Python and the Pandas library were used for the entire data cleaning and transformation workflow.

#### Objectives of the Cleaning Process
* Standardize column formatting for easier querying and modelling
* Correct inconsistent data types
* Remove invalid or corrupted records
* Handle missing values appropriately
* Prepare date and numeric fields for time-series and KPI analysis
* Ensure compatibility with MySQL and Power BI
* Improve overall dataset reliability for business reporting

#### Data Cleaning & Transformation Steps

##### Phase 1: Python and Pandas

Using Python and the Pandas library, the dataset was loaded, cleaned, validated, and standardized before it was imported into MySQL for querying and Power BI for visualization. The script handled data quality issues by renaming and standardizing column names, converting date and numeric fields into usable formats, filtering out invalid records such as negative monetary values and impossible ratings, handling missing values, and cleaning distance and time-related fields for operational analysis.
Additional validation checks were performed on restaurant IDs, order IDs, ratings, delivery distances, and kitchen preparation times to ensure consistency and reliability. The cleaned dataset was then exported as a new CSV file (cleaned_orders.csv), which became the final structured dataset used for SQL querying, KPI analysis, and dashboard development.

##### Data Quality & Transformation Architecture

The cleaning engine enforces quality across five distinct validation gates to prevent structural anomalies, data type mismatches, and logical inconsistencies from corrupting downstream production environments:

### 1. Structural Standardization
* **The Problem:** The original CSV headers contained irregular spacing, trailing blanks, mixed casing, and special characters (`/`), which break SQL schema mapping and BI engine matching.
* **The Fix:** Column headers are programmatically stripped of whitespace, forced to lowercase, and standardized using clean `snake_case` syntax.

### 2. Chronological & Geospatial Normalization
* **Date Parsing:** The `order_placed_at` timestamp is converted into a uniform `DATETIME` object using explicit day-first notation (`dayfirst=True`). Corrupted or unparseable strings are safely coerced to `NaT` (Not a Time) values to prevent script crashes.
* **Geospatial Regex Extraction:** The `distance` field contained non-numeric text suffixes and noise. A regular expression engine (`r'(\d+\.?\d*)'`) was deployed to only extract numeric floating-point values, followed by an operational safety filter rejecting impractical outliers (>100\text).

### 3. Dimensional Constraint Gates
* **Critical Drop:** Rows lacking foundational structural keys—specifically `restaurant_id`, `restaurant_name`, `subzone`, `order_id`, and `order_placed_at`—are dropped completely. These fields represent the core dimensions required for business analysis; metrics without them lack analytical context.
* **ID Validation:** Enforces boundary constraints on transactional keys, filtering out records where IDs are $\le 0$ or non-numeric.

### 4. Financial & Operational Boundary Safety
To maximize data retention for marketing metrics, a **Conditional Logic Gate** was implemented for numeric metrics:
* **Financial Integrity:** Fields tracking financial transactions (`bill_subtotal`, `packaging_charges`, `total`) are evaluated. Negative charges are rejected as logical impossibilities, but legitimate missing values (`NaN`) are explicitly retained to avoid losing important data and significantly manipulating the overall analysis.
* **Service Efficiency Metrics:** Kitchen Preparation Time (`kpt_duration_minutes`) and Rider Wait Time (`rider_wait_time_minutes`) are validated to ensure all recorded durations are in decimal but accurately reflect mm: ss.
* **Categorical Constraints:** Customer ratings are strictly bounded between 0.0 and 5.0. 

### 5. Textual Imputation
Missing values within text strings (`review`, `instructions`, `cancellation_rejection_reason`) are imputed with a uniform `'unknown'` flag. This preserves categorical grouping functionality in SQL and eliminates unexpected blank data cards in BI dashboard slicers.


## Pipeline Source Code

```python
import pandas as pd

# Define paths
SOURCE_PATH = 'C:/Users/kamva/OneDrive/Desktop/PORTFOLIO/FoodDelivery/order_history_kaggle_data.csv'
SAVE_PATH = "C:/Users/kamva/OneDrive/Desktop/PORTFOLIO/FoodDelivery/cleaned_orders.csv"

# 1. Ingest Raw Data (Handle delimiter issues)
df = pd.read_csv(SOURCE_PATH, sep=';', encoding='utf-8', on_bad_lines='skip')
print(f"Raw rows loaded: {len(df)}")

# 2. Column Name Standardization
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
    .str.replace("/", "_")
)

# 3. Datetime Normalization
df['order_placed_at'] = pd.to_datetime(df['order_placed_at'], errors='coerce', dayfirst=True)

# 4. Regex Geospatial Extraction
df['distance'] = df['distance'].astype(str).str.extract(r'(\d+\.?\d*)')[0]
df['distance'] = pd.to_numeric(df['distance'], errors='coerce')

# 5. Enforce Dimensional Constraints (Drop critical blanks)
critical_cols = ["restaurant_id", "restaurant_name", "subzone", "order_id", "order_placed_at"]
df = df.dropna(subset=critical_cols)

# 6. Validate Relational Transaction Keys
df["restaurant_id"] = pd.to_numeric(df["restaurant_id"], errors="coerce")
df["order_id"] = pd.to_numeric(df["order_id"], errors="coerce")
df = df[(df["restaurant_id"] > 0) & (df["order_id"] > 0)]

# 7. Financial Boundary Controls (Allow NaN, reject negatives)
money_cols = ["bill_subtotal", "packaging_charges", "total"]
for col in money_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")
    df = df[df[col].isna() | (df[col] >= 0)]

# 8. Rating Range Enforcement [0, 5]
df["rating"] = pd.to_numeric(df["rating"], errors="coerce")
df = df[df["rating"].isna() | ((df["rating"] >= 0) & (df["rating"] <= 5))]

# 9. Operational Duration Safety Checks
df["kpt_duration_minutes"] = pd.to_numeric(df["kpt_duration_minutes"], errors="coerce")
df["rider_wait_time_minutes"] = pd.to_numeric(df["rider_wait_time_minutes"], errors="coerce")
df = df[df["kpt_duration_minutes"].isna() | (df["kpt_duration_minutes"] >= 0)]
df = df[df["rider_wait_time_minutes"].isna() | (df["rider_wait_time_minutes"] >= 0)]

# 10. Categorical Text Imputation
text_cols = ["review", "instructions", "cancellation_rejection_reason"]
for col in text_cols:
    df[col] = df[col].fillna("unknown").str.strip()

# 11. Logistics Outlier Filtering
df = df[df["distance"].isna() | (df["distance"] < 100)]

# 12. Export Standardized, Clean Dataset
df.to_csv(
    SAVE_PATH,
    index=False,
    encoding="utf-8",
    lineterminator="\r\n",
    date_format="%Y-%m-%d %H:%M:%S"
)

# 13. Pipeline Validation Log / Self-Audit
reloaded = pd.read_csv(SAVE_PATH)
print(f"\n[PIPELINE SUCCESS] Final dataset size: {len(df)} rows | {df.shape[1]} columns")
print(f"Reloaded Verification Check: {len(reloaded)} rows successfully written.")
print(f"Remaining Missing Values: {df.isnull().sum().sum()}")

```

## Phase 2: Relational Database Modeling & Views (MySQL)

To establish a clean separation of concerns, optimize query performance, and simplify downstream Power BI data modeling, raw transactional records were abstracted into three specialized database views. 

These views encapsulate core business logic—such as operational bucketing, complex conditional aggregation, and multi-column financial calculations—directly within the database tier.

### 1. Logistics Rejection Matrix (`nw_rejection_reasons`)
This view isolates systemic supply chain friction by pivoting unstructured, textual cancellation logs into separate numeric indicator metrics, categorized by geospatial delivery distances.

* **Business Logic:** Uses conditional aggregation `COUNT(CASE WHEN...)` to group explicit breakdown types while preserving compatibility with database `ONLY_FULL_GROUP_BY` performance constraints.
* **Analytical Value:** Directly exposes patterns showing if order cancellation distributions shift dramatically across short vs. long delivery journeys (e.g., distinguishing between a restaurant operational issue like "Kitchen is full" and customer impatience on far deliveries).

```sql
CREATE VIEW `food_delivery`.`nw_rejection_reasons` AS
SELECT 
    (CASE
        WHEN (`food_delivery`.`deliver_history`.`distance` <= 5.00) THEN '<= 5km'
        WHEN (`food_delivery`.`deliver_history`.`distance` <= 10.00) THEN '<=10km'
        WHEN (`food_delivery`.`deliver_history`.`distance` > 10.00) THEN '>10km'
    END) AS `distance_range`,
    COUNT((CASE WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Cancelled by Zomato') THEN 1 END)) AS `Cancelled_by_Zomato`,
    COUNT((CASE WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Merchant device issue') THEN 1 END)) AS `Merchant_device_issue`,
    COUNT((CASE WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Cancelled by Customer') THEN 1 END)) AS `Cancelled_by_Customer`,
    COUNT((CASE WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Kitchen is full') THEN 1 END)) AS `Kitchen_is_full`,
    COUNT((CASE WHEN (`food_delivery`.`deliver_history`.`cancellation_rejection_reason` = 'Items out of stock') THEN 1 END)) AS `Items_out_of_stock`
FROM `food_delivery`.`deliver_history`
GROUP BY `distance_range`;
 ```

### 2. Operational Delivery Performance Metrics (vw_delivery_metrics)
A comprehensive core layer that extends the base fact table by calculating granular operational cycle buckets for every transaction.

* **Business Logic:** Features multi-tier CASE statements that programmatically segment continuous variables—Kitchen Preparation Time (kpt_duration_minutes) and Rider Wait Time (rider_wait_time_minutes)—into categorical performance groups.
* **Analytical Value:** Eliminates the need to write heavy conditional logic in Power BI columns. By bucketing service times (0-10, 11-20, 21-30+ minutes) at the database level, it provides instant, low-latency filter attributes for operations dashboards tracking order-ready accuracy and customer complaints.

```sql
CREATE VIEW `food_delivery`.`vw_delivery_metrics` AS
SELECT 
    `restaurant_id`, `restaurant_name`, `subzone`, `city`, `order_id`, 
    `order_placed_at`, `order_status`, `delivery`, `distance`, `items_in_order`, 
    `instructions`, `discount_construct`, `bill_subtotal`, `packaging_charges`, 
    `restaurant_discount_promo`, `restaurant_discount_flat_offs`, `gold_discount`, 
    `brand_pack_discount`, `total`, `rating`, `review`, `cancellation_rejection_reason`, 
    `restaurant_compensation_cancellation`, `restaurant_penalty_rejection`, 
    `kpt_duration_minutes`, `rider_wait_time_minutes`, `order_ready_marked`, 
    `customer_complaint_tag`, `customer_id`,
    (CASE
        WHEN (`kpt_duration_minutes` <= 10) THEN '0-10'
        WHEN (`kpt_duration_minutes` <= 20) THEN '11-20'
        WHEN (`kpt_duration_minutes` <= 30) THEN '21-30'
        ELSE '30+'
    END) AS `kpt_bucket`,
    (CASE
        WHEN (`rider_wait_time_minutes` <= 5) THEN '0-5'
        WHEN (`rider_wait_time_minutes` <= 10) THEN '6-10'
        ELSE '10+'
    END) AS `rwt_bucket`
FROM `food_delivery`.`deliver_history`;
```

### 3. Promotional Strategy & Margin Analysis (vw_discount_flag)
A specialized marketing intelligence view designed to isolate gross transaction revenues from multi-channel promotional adjustments.

* **Business Logic:** Implements defensive database engineering via COALESCE() to eliminate arithmetic errors caused by NULL values when consolidating multiple overlapping discount programs (restaurant_discount_promo, restaurant_discount_flat_offs, gold_discount, and brand_pack_discount).
* **Analytical Value:** Creates a binary flag (Discount Applied vs. No Discount) along with a calculated absolute metric for total_discount. This lets analysts evaluate promotional health by directly testing whether discount strategies successfully increase total order margins or simply drain restaurant profits.

```sql
CREATE VIEW `food_delivery`.`vw_discount_flag` AS
SELECT 
    `order_id`, `restaurant_name`, `subzone`, `total`,
    (CASE
        WHEN ((((COALESCE(`restaurant_discount_promo`, 0) 
               + COALESCE(`restaurant_discount_flat_offs`, 0)) 
               + COALESCE(`gold_discount`, 0)) 
               + COALESCE(`brand_pack_discount`, 0)) > 0) 
        THEN 'Discount Applied'
        ELSE 'No Discount'
    END) AS `discount_flag`,
    (((COALESCE(`restaurant_discount_promo`, 0) 
     + COALESCE(`restaurant_discount_flat_offs`, 0)) 
     + COALESCE(`gold_discount`, 0)) 
     + COALESCE(`brand_pack_discount`, 0)) AS `total_discount`
FROM `food_delivery`.`deliver_history`;
```


