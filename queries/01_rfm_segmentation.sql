-- ================================================================
-- RFM Segmentation Analysis
-- Objective: Segment customers based on Recency, Frequency and
-- Monetary value to identify retention and upsell opportunities
--
-- RFM Scoring (1-5 scale, 5 = best):
--   Recency (R): days since last purchase — lower days = higher score
--   Frequency (F): number of distinct orders — more orders = higher score
--   Monetary (M): total amount spent — higher spend = higher score
--
-- Segments based on combined R+F+M score (3-15 range):
--   Champions (13-15): recent, frequent, high spenders
--   Loyal (10-12): consistent buyers with good spend
--   At Risk (7-9): previously engaged, losing activity
--   Lost (3-6): low recency, frequency and spend
--
-- Analysis period: current year, completed orders only
-- ================================================================

WITH initial_metrics AS (
    SELECT 
        o.user_id,
        DATE_DIFF(CURRENT_DATE(), MAX(DATE(o.created_at)), DAY) AS days_previous_order,
        COUNT(DISTINCT o.order_id) AS transactions,
        ROUND(SUM(oi.sale_price), 1) AS amount_spent
    FROM `bigquery-public-data.thelook_ecommerce.orders` AS o
    LEFT JOIN `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    USING(order_id)
    WHERE EXTRACT(YEAR FROM o.created_at) = EXTRACT(YEAR FROM CURRENT_DATE)
          AND o.status = 'Complete'
    GROUP BY o.user_id
),
scores AS (
    SELECT
        user_id,
        days_previous_order,
        transactions,
        amount_spent,
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
        amount_spent
    FROM scores
),
results AS (
    SELECT 
        customer_clasification,
        COUNT(*) AS customers,
        ROUND(AVG(amount_spent), 1) AS avg_spent
    FROM customer_category
    GROUP BY 1
)
SELECT
    customer_clasification,
    customers,
    ROUND(100 * (customers / SUM(customers) OVER()), 1) AS pct_rate,
    avg_spent
FROM results
ORDER BY 1;

/*
Results - RFM Segmentation (current year, completed orders):

| Segment       | Customers | % Total | Avg Spend |
|---------------|-----------|---------|-----------|
| 1 - Lost      | 848       | 18.8%   | $33.7     |
| 2 - At Risk   | 1,792     | 39.6%   | $74.0     |
| 3 - Loyal     | 1,338     | 29.6%   | $116.3    |
| 4 - Champions | 543       | 12.0%   | $187.8    |

Key findings:
- 70% of customers fall in mid-tier segments (At Risk + Loyal)
- Only 12% qualify as Champions with avg spend of $187.8
- At Risk segment (1,792 customers, avg $74) is the highest priority for
  re-engagement campaigns — largest segment with recoverable revenue potential
- Loyal customers (avg $116) represent strong upsell potential toward Champion status
*/
