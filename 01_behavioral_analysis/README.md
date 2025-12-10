# 📈 01. E-commerce User Behavior and Correlation Analysis

This folder focuses on the **Behavioral Analysis** segment of the main e-commerce project, specifically examining the statistical relationship between **User Engagement** and the final **Purchase Outcome** using Google Analytics 4 (GA4) data. The primary goal is to quantitatively measure user interaction and determine its impact on conversion via Correlation Coefficient analysis.

## 🎯 Project Objectives 

* To calculate key user engagement metrics for every unique session: **`session_engaged`** status and **`engagement_time_msec`** (total active time).
* To quantify the relationship between these behavioral metrics and the in-session **`purchase`** event using the **Correlation Coefficient**, identifying which behaviors have the strongest link to conversion.

## 🛠️ Technologies Used and Data Source

* **Database:** BigQuery
* **Querying:** **SQL (Advanced Aggregation, CASE Statements, Statistical Functions)**
* **Data Source:** Google Analytics 4 (GA4) Raw Event Data
* **Key Events Included:** `session_start`, `view_item`, `add_to_cart`, `purchase`, etc.

## 🚀 Key Query Steps (`correlation_calculation.sql`)

1.  **Data Preparation:** Raw data for the critical e-commerce events was filtered and grouped by unique session (`user_pseudo_id` + `session_id`).
2.  **Behavioral Quantification:** Three core values were calculated for each session:
    * `Is_Engaged_Session` (Binary: Engaged Status)
    * `Total_Engagement_Time_MS` (Total Active Time, Numerical)
    * `Has_Purchased` (Purchase Occurred, Binary)
3.  **Correlation Modeling:** The quantified metrics were used to calculate the **Pearson Correlation Coefficient** (`r`), implemented via BigQuery/SQL statistical functions, measuring the relationship between the purchase event and both the engagement status and active time.

---

## 💻 SQL Script

The SQL script executing the full behavioral quantification and correlation analysis is available here:

* **Correlation Query:** [`correlation_calculation.sql`](correlation_calculation.sql)

---

## 📈 Outcome and Deliverables

This analysis moves beyond general reporting by providing **quantitative evidence** of how specific user activities influence purchase probability. This offers **actionable insights** for UX/Product development teams, enabling them to prioritize features that drive high-correlation behaviors (e.g., maximizing active time on key conversion pages), thereby leading to data-backed UX improvements and maximized conversion rates.
