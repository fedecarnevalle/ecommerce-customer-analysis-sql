-- ================================================================
-- Customer Lifetime Value (LTV) by RFM Segment
-- Objective: Quantify customer value across RFM segments to
-- prioritize retention and upsell investment
--
-- LTV Calculation: total spend / active months per customer
-- Edge case handling:
--   - Single-purchase customers have 0 active months (first = last order)
--   - NULLIF converts 0 to NULL to avoid division by zero
--   - COALESCE replaces NULL with 1, treating them as 1 active month
--   This preserves actual spend while enabling a meaningful LTV calculation
--
-- Analysis period: full history, completed orders only
-- ================================================================

WITH initial_metrics AS (
    SELECT 
        o.user_id,
        MIN(o.created_at) AS first_order,
        MAX(o.created_at) AS last_order,
        DATE_DIFF(DATE(MAX(o.created_at)), DATE(MIN(o.created_at)), MONTH) AS months_active,
        DATE_DIFF(CURRENT_DATE(), MAX(DATE(o.created_at)), DAY) AS days_previous_order,
        COUNT(DISTINCT o.order_id) AS transactions,
        ROUND(SUM(oi.sale_price), 1) AS amount_spent
    FROM `bigquery-public-data.thelook_ecommerce.orders` AS o
    LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    USING(order_id)
    WHERE o.status = 'Complete'
    GROUP BY o.user_id
),
rfm_scores AS (
    SELECT
        user_id,
        days_previous_order,
        transactions,
        amount_spent,
        months_active,
        NTILE(5) OVER(ORDER BY days_previous_order DESC) AS recency_score,
        NTILE(5) OVER(ORDER BY transactions ASC) AS frequency_score,
        NTILE(5) OVER(ORDER BY amount_spent ASC) AS monetary_score
    FROM initial_metrics
),
customer_category AS (
    SELECT
        CASE 
            WHEN recency_score + frequency_score + monetary_score BETWEEN 3 AND 6 THEN '1 - Lost'
            WHEN recency_score + frequency_score + monetary_score BETWEEN 7 AND 9 THEN '2 - At Risk'
            WHEN recency_score + frequency_score + monetary_score BETWEEN 10 AND 12 THEN '3 - Loyal'
            WHEN recency_score + frequency_score + monetary_score BETWEEN 13 AND 15 THEN '4 - Champions'
        END AS customer_clasification,
        *
    FROM rfm_scores
)
SELECT 
    customer_clasification,
    COUNT(*) AS customers,
    ROUND(AVG(amount_spent), 1) AS avg_amount_spent,
    ROUND(AVG(amount_spent / COALESCE(NULLIF(months_active, 0), 1)), 1) AS avg_ltv,
    ROUND(AVG(months_active), 1) AS avg_months_active
FROM customer_category
GROUP BY customer_clasification
ORDER BY customer_clasification ASC;

/*
Results - LTV by RFM Segment (full history, completed orders):

| Segment       | Customers | Avg Spend | Avg LTV/month | Avg Active Months |
|---------------|-----------|-----------|---------------|-------------------|
| 1 - Lost      | 5,195     | $35.1     | $35.1         | 0.0               |
| 2 - At Risk   | 11,049    | $74.6     | $74.2         | 0.1               |
| 3 - Loyal     | 8,258     | $125.2    | $107.4        | 2.4               |
| 4 - Champions | 3,261     | $207.6    | $119.3        | 8.4               |

Key findings:
- Clear value progression across segments: Champions spend 6x more than Lost customers
- Lost and At Risk are predominantly one-time buyers (0.0 and 0.1 avg active months)
  explaining why their LTV mirrors their total spend
- Champions average 8.4 active months generating $119.3/month
- Converting At Risk customers (11,049, avg $74.6) into repeat buyers is the
  highest-impact retention opportunity given segment size
*/
