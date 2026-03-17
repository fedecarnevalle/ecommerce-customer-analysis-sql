# thelook eCommerce | Customer Analysis
**Tools:** SQL, BigQuery  
**Dataset:** thelook_ecommerce | Public Dataset `bigquery-public-data.thelook_ecommerce`  
**Period:** Full history | RFM and LTV use full history, Cohort uses last 16 months dynamically  
**Source:** [BigQuery Public Datasets - thelook eCommerce](https://console.cloud.google.com/marketplace/details/bigquery-public-data/thelook-ecommerce)

## Overview
SQL analysis of thelook_ecommerce public data exploring customer behavior through three complementary frameworks: RFM segmentation to classify customers by value, cohort retention to track loyalty over time, and LTV to quantify revenue per segment. Together they provide a complete picture of customer engagement and actionable retention opportunities.

**What is RFM?** RFM segments customers based on three dimensions: how recently they purchased (Recency), how often they purchase (Frequency), and how much they spend (Monetary). Each dimension is scored 1-5 and combined to classify customers into Champions, Loyal, At Risk and Lost.

## Business Questions
- How are customers distributed across value segments?
- What % of new customers return in subsequent months?
- What is the revenue value of each customer segment over time?

## Key Findings

- **RFM:** 70% of customers fall in mid-tier segments — 39.6% At Risk and 29.6% Loyal. Only 12% qualify as Champions ($187.8 avg spend). At Risk segment (1,792 customers, avg $74) is the highest priority for re-engagement

- **Cohort retention:** Less than 10% of new customers return the following month across older cohorts. However month-1 retention shows a clear upward trend in recent cohorts — from ~3-4% in late 2024 to 14.1% in January 2026

- **LTV:** Champions average 8.4 active months generating $119.3/month. At Risk and Lost segments are predominantly one-time buyers (0.0-0.1 avg active months), making conversion to repeat buyers the highest-impact retention opportunity

## Conclusions

1. **Re-engage At Risk first:** 1,792 customers averaging $74 spend — largest segment with recoverable revenue potential
2. **Upsell Loyal customers:** avg $116 spend with room to grow toward Champion status ($188)
3. **Retention is improving:** month-1 cohort retention trending up from 3% to 14% in recent months — current efforts are working and should be scaled
4. **One-time buyers dominate lower segments:** Lost and At Risk customers average 0-0.1 active months — even one additional purchase would significantly impact their LTV

→ [Full Executive Summary](results/executive_summary.md)

## Repository Structure
```
thelook-ecommerce-customer-analysis/
│
├── README.md
├── queries/
│   ├── 01_rfm_segmentation.sql
│   ├── 02_cohort_retention.sql
│   └── 03_ltv_by_segment.sql
└── results/
    └── executive_summary.md
```
