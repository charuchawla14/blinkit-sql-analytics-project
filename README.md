# 🛒 Blinkit Business Analytics | End-to-End Retail & Delivery Analytics Project

## 📌 Executive Summary

This project analyzes 1,061+ orders across a Blinkit-style quick-commerce business to uncover customer, product, and delivery performance patterns using **SQL (MySQL)** and **Power BI**.

**Headline Findings:**
- **Repeat customers (94.2% of the base) generate 99.47% of total revenue** — retention, not acquisition, is the dominant growth lever
- **69.84% of orders are delivered on time**, but a data quality investigation revealed **46.7% of "On Time" orders also log a delay reason** — an internal inconsistency documented rather than papered over
- **Delivery delay rate does NOT increase with distance** — Under-2km orders (33.07% delayed) actually delay *more* than 2–5km orders (28.49%), challenging the assumption that distance drives delays
- **Premium customers receive a slightly lower on-time rate (68.69%) than Inactive customers (70.59%)** — delivery is not currently segment-prioritized, a gap worth flagging for a retention-focused business

➡️ **Recommendation**: Given revenue is overwhelmingly retention-driven, and Premium customers currently get no delivery-priority advantage, introducing SLA prioritization for high-value segments could directly protect the 99.47% revenue base this business depends on.

---

## 🎯 Business Objectives

- Which customer segments generate the highest revenue, and is that revenue concentrated or spread out?
- What products and categories drive growth, and where is margin being left on the table?
- How reliable is delivery performance, and what actually predicts a delay?
- Is delivery experience consistent across customer segments — and does it match business priorities?
- What data quality issues exist in the source data, and how should they be handled honestly?

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| SQL (MySQL) | Data cleaning, transformation, business analysis |
| Power BI | Dashboard development |
| DAX | KPI & measure creation |
| Excel/CSV | Data source |
| GitHub | Project documentation |

---

## 📂 Dataset Overview

Five interconnected tables: `customers`, `orders`, `order_items`, `products`, `delivery_performance`.

**Relationship flow:** `customers → orders → order_items → products` and `orders → delivery_performance`

---

## 🧹 Data Cleaning & Assumptions

Real datasets are messy — here's what was found and how it was handled, rather than silently fixed:

**1. Negative delivery times**
336 rows in `delivery_performance` had impossible negative `delivery_time_minutes` values. These were corrected using `ABS()` under the assumption that they represented a sign error rather than a meaningful negative duration (e.g., early delivery). This assumption is documented here rather than hidden.

**2. Delay-reason data limitation**
The `reasons_if_delayed` column contains only two distinct values across the entire dataset: **"Traffic"** or blank. No other cause (weather, partner availability, stock issues) is ever logged, which limits true root-cause analysis for delays.

**3. Status/reason inconsistency (preserved, not corrected)**
346 of 741 "On Time" orders (**46.7%**) also list "Traffic" as a delay reason — logically inconsistent, since a delay reason shouldn't exist on an on-time order. Rather than guessing which field was wrong and silently editing it, this was preserved as-is and is flagged here as a genuine data limitation. This pattern, combined with only one reason value ever appearing, suggests the dataset may be synthetically generated rather than reflective of live operational logging.

---

## 📊 SQL Business Analysis

### Customer Analytics
- Top high-value customers by total spend
- Customer Lifetime Value (CLV) estimation
- Repeat vs. one-time customer revenue concentration
- On-time delivery rate by customer segment

### Sales Analytics
- Category-wise revenue performance
- Payment method distribution
- Orders above average order value (subquery-based)

### Product Analytics
- Top revenue-generating products
- Category margin vs. order volume (profitability opportunity analysis)

### Delivery Analytics
- Overall on-time vs. delayed percentage
- Delay rate by distance band
- Delay rate by hour of day
- Delivery reason data-quality cross-tab

---

## 💡 Key Insights Generated (with real numbers)

### Customer Insights
- **Repeat customers are 94.2% of the customer base and generate 99.47% of total revenue** (₹28.87M of ₹29.03M), while one-time customers (5.8% of base) contribute just 0.53% — revenue is almost entirely retention-driven, not acquisition-driven.
- On-time delivery rate is nearly flat across segments (68.49%–70.59%), with **Premium customers (68.69%) receiving a lower on-time rate than Inactive customers (70.59%)** — delivery prioritization is not currently segment-aware.

### Delivery & Data Quality Insights
- **69.84% of all orders (741 of 1,061) were delivered on time**; 20.92% were slightly delayed and 9.24% significantly delayed.
- **Delay rate does not scale with distance** — Under-2km orders delayed at 33.07% vs. 28.49% for 2–5km orders, suggesting delays stem from factors other than distance (e.g., order prep time or partner allocation), not distance itself.
- **Delay rate is stable across all 24 hours of the day** (27%–35% range, no clear peak), pointing to a systemic operational pattern rather than a rush-hour traffic problem.
- **Only one delay reason ("Traffic") is ever logged**, and it appears on 46.7% of on-time orders too — a documented data limitation that constrains how far root-cause analysis can go on this dataset.

### Product & Sales Insights
- Revenue is concentrated in a small number of top categories and products (e.g., Dairy & Breakfast ~₹146.8K vs. Pharmacy ~₹145.3K — closely matched top two categories worth deeper margin comparison).
- Orders above the average order value disproportionately reflect high-value/premium purchasing behavior.
- Digital payment methods make up a majority of transactions (see dashboard for exact split).

---

## 📊 Power BI Dashboard

Three interactive dashboard pages:

### 1️⃣ Executive Overview
Total Revenue, Total Orders, Total Customers, AOV, Units Sold, Avg. Delivery Time — with Revenue by Category, Top Products, Revenue by Segment, Payment Method Distribution.

![Executive Overview](screenshots/executive_overview.png)

### 2️⃣ Customer Analytics
Total/Repeat Customers, Avg. CLV, Highest Spending Customer — with Segment Revenue, CLV Analysis, Revenue by Area.

![Customer Analytics](screenshots/customer_analytics.png)

### 3️⃣ Delivery & Product Analytics
Total Deliveries, On-Time Rate, Avg. Delivery Time, Delay Rate by Distance/Hour — with Delivery Status Analysis, Product Revenue by Category.

![Delivery Analytics](screenshots/delivery_product_analytics.png)

---

## 🏗️ Project Structure

```
Blinkit-Business-Analytics/
│
├── datasets/
│   ├── customers.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── products.csv
│   └── delivery_performance.csv
│
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_table_creation.sql
│   ├── 03_data_import.sql
│   ├── 04_business_analysis.sql
│   └── 05_delivery_and_data_quality_analysis.sql
│
├── dashboard/
│   └── blinkit_dashboard.pbix
│
├── screenshots/
│   ├── executive_overview.png
│   ├── customer_analytics.png
│   └── delivery_product_analytics.png
│
└── README.md
```

---

## 🚀 Business Impact

This project demonstrates how a retail/quick-commerce business could use its own transactional data to:

- Recognize that retention, not acquisition, drives nearly all revenue — and protect it accordingly
- Identify that delivery delays aren't explained by distance, redirecting root-cause investigation elsewhere
- Catch a real data-logging inconsistency before it distorts decision-making
- Spot a mismatch between customer value (Premium tier) and delivery service quality

---

## 👨‍💻 Skills Demonstrated

- SQL: joins, aggregate functions, `GROUP BY`, window functions (`OVER()`), `CASE WHEN` logic, subqueries, date/time functions
- Data cleaning & documented assumption-making (not silent data alteration)
- Business KPI development and quantified insight-writing
- Power BI dashboard design across multiple linked pages
- Data storytelling — connecting SQL output to business recommendations

