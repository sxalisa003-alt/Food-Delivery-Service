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
1. Loading the Dataset
The raw CSV dataset was imported using Pandas:


