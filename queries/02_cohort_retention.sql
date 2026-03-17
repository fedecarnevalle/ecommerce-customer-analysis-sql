-- ================================================================
-- Cohort Retention Analysis
-- Objective: Track what percentage of new customers return to
-- purchase in subsequent months after their first order
--
-- Each row represents a cohort of customers who made their first
-- purchase in that month. Month_0 = 100% (entry month).
-- Subsequent columns show % of that cohort still active.
-- Null values = months that have not yet occurred, not missing data.
--
-- Analysis period: last 16 months (dynamic, no hardcoded dates)
-- ================================================================

WITH initial_order AS (
    SELECT 
        user_id,
        MIN(created_at) AS first_order
    FROM `bigquery-public-data.thelook_ecommerce.orders`
    GROUP BY user_id
    HAVING DATE(MIN(created_at)) > DATE_SUB(CURRENT_DATE(), INTERVAL 16 MONTH)
),
orders_history AS (
    SELECT 
        user_id,
        DATE_TRUNC(created_at, MONTH) AS month_year
    FROM `bigquery-public-data.thelook_ecommerce.orders`
    WHERE DATE(created_at) > DATE_SUB(CURRENT_DATE(), INTERVAL 16 MONTH)
),
cohort_data AS (
    SELECT 
        DATE_TRUNC(DATE(io.first_order), MONTH) AS cohort_month,
        DATE_DIFF(DATE(oh.month_year), DATE(io.first_order), MONTH) AS month_number,
        COUNT(io.user_id) AS users
    FROM initial_order AS io
    INNER JOIN orders_history AS oh
    USING(user_id)
    GROUP BY DATE_TRUNC(DATE(io.first_order), MONTH), month_number
    ORDER BY cohort_month ASC
),
cohort_size AS (
    SELECT * FROM cohort_data WHERE month_number = 0
),
cohort_pct AS (
    SELECT 
        cd.cohort_month,
        cd.month_number,
        ROUND(100 * (cd.users / cs.users), 1) AS pct_retention
    FROM cohort_data AS cd
    LEFT JOIN cohort_size AS cs
    USING(cohort_month)
)
SELECT *
FROM cohort_pct
PIVOT(MAX(pct_retention) FOR month_number IN (0,1,2,3,4,5,7,8,9,10,11,12,13,14,15))
ORDER BY cohort_month;

/*
Results - Cohort Retention (last 16 months, % of cohort still active):

| Cohort    | M0    | M1   | M2  | M3  | M4  | M5  | M7  | M8  | M9  | M10 | M11 |
|-----------|-------|------|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| 2024-11   | 100%  | 3.4% | 3.1%| 2.6%| 2.8%| 2.6%| 1.7%| 3.4%| 3.6%| 2.6%| 3.6%|
| 2024-12   | 100%  | 3.5% | 3.7%| 3.9%| 3.3%| 3.3%| 3.6%| 4.1%| 3.0%| 2.4%| 3.2%|
| 2025-01   | 100%  | 3.0% | 2.8%| 3.9%| 3.3%| 4.2%| 3.5%| 3.6%| 3.6%| 3.7%| 3.9%|
| 2025-02   | 100%  | 3.8% | 4.3%| 3.8%| 3.1%| 3.8%| 3.9%| 4.1%| 3.7%| 4.0%| 5.2%|
| 2025-03   | 100%  | 3.6% | 3.6%| 3.4%| 4.6%| 4.7%| 3.4%| 4.1%| 3.0%| 3.9%| 3.5%|
| 2025-04   | 100%  | 3.9% | 4.5%| 4.7%| 3.5%| 3.6%| 3.9%| 5.1%| 4.5%| 3.0%| 1.5%|
| 2025-05   | 100%  | 4.5% | 4.0%| 4.2%| 4.7%| 4.7%| 3.8%| 4.4%| 4.0%| 1.4%| null|
| 2025-06   | 100%  | 5.3% | 4.9%| 4.3%| 5.8%| 5.1%| 4.4%| 4.4%| 2.7%| null| null|
| 2025-07   | 100%  | 5.6% | 5.5%| 4.8%| 5.3%| 5.6%| 4.7%| 2.3%| null| null| null|
| 2025-08   | 100%  | 6.2% | 6.0%| 5.3%| 5.7%| 5.5%| 2.4%| null| null| null| null|
| 2025-09   | 100%  | 6.6% | 6.3%| 6.2%| 7.3%| 6.3%| null| null| null| null| null|
| 2025-10   | 100%  | 7.4% | 7.6%| 7.2%| 7.3%| 4.3%| null| null| null| null| null|
| 2025-11   | 100%  | 8.6% | 8.9%| 7.7%| 3.9%| null| null| null| null| null| null|
| 2025-12   | 100%  | 10.6%| 9.8%| 5.3%| null| null| null| null| null| null| null|
| 2026-01   | 100%  | 14.1%| 7.8%| null| null| null| null| null| null| null| null|
| 2026-02   | 100%  | 13.6%| null| null| null| null| null| null| null| null| null|
| 2026-03   | 100%  | null | null| null| null| null| null| null| null| null| null|

Key findings:
- Less than 10% of new customers return the following month across older cohorts
- Month-1 retention shows clear upward trend in recent cohorts: from ~3-4% in late 2024
  to 14.1% in January 2026 — suggesting retention campaigns gaining traction
- Improvement is consistent across months, not seasonal
- Null values = months that have not yet occurred, not missing data
*/
