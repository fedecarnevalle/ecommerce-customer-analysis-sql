# thelook eCommerce | Customer Analysis | Executive Summary

## Dataset
thelook_ecommerce public dataset | BigQuery  
RFM and LTV analyses use full order history. Cohort analysis covers last 16 months dynamically — no hardcoded dates. All analyses restricted to completed orders only (`status = 'Complete'`).

---

## 1. RFM Segmentation

Customers scored 1-5 on Recency, Frequency and Monetary dimensions using `NTILE(5)`. Combined score (3-15) determines segment. Analysis period: current year.

| Segment       | Customers | % Total | Avg Spend |
|---------------|-----------|---------|-----------|
| 1 - Lost      | 848       | 18.8%   | $33.7     |
| 2 - At Risk   | 1,792     | 39.6%   | $74.0     |
| 3 - Loyal     | 1,338     | 29.6%   | $116.3    |
| 4 - Champions | 543       | 12.0%   | $187.8    |

> 70% of customers fall in mid-tier segments (At Risk + Loyal). Only 12% qualify as Champions with avg spend of $187.8, while Lost customers (18.8%) show the lowest engagement at $33.7 avg spend. The most actionable opportunity lies in the At Risk segment (1,792 customers, avg $74): re-engagement campaigns targeting this group could recover significant revenue given their size. Loyal customers (avg $116) represent strong upsell potential toward Champion status.

---

## 2. Cohort Retention Analysis

Customers grouped by first purchase month. Each cell shows % of that cohort still active in subsequent months. Null values = months that have not yet occurred, not missing data. Analysis period: last 5 months.

| Cohort  | M0   | M1    | M2   | M3   | M4   | M5   |
|---------|------|-------|------|------|------|------|
| 2024-11 | 100% | 3.4%  | 3.1% | 2.6% | 2.8% | 2.6% |
| 2024-12 | 100% | 3.5%  | 3.7% | 3.9% | 3.3% | 3.3% |
| 2025-01 | 100% | 3.0%  | 2.8% | 3.9% | 3.3% | 4.2% |
| 2025-02 | 100% | 3.8%  | 4.3% | 3.8% | 3.1% | 3.8% |
| 2025-03 | 100% | 3.6%  | 3.6% | 3.4% | 4.6% | 4.7% |
| 2025-04 | 100% | 3.9%  | 4.5% | 4.7% | 3.5% | 3.6% |
| 2025-05 | 100% | 4.5%  | 4.0% | 4.2% | 4.7% | 4.7% |
| 2025-06 | 100% | 5.3%  | 4.9% | 4.3% | 5.8% | 5.1% |
| 2025-07 | 100% | 5.6%  | 5.5% | 4.8% | 5.3% | 5.6% |
| 2025-08 | 100% | 6.2%  | 6.0% | 5.3% | 5.7% | 5.5% |
| 2025-09 | 100% | 6.6%  | 6.3% | 6.2% | 7.3% | 6.3% |
| 2025-10 | 100% | 7.4%  | 7.6% | 7.2% | 7.3% | 4.3% |
| 2025-11 | 100% | 8.6%  | 8.9% | 7.7% | 3.9% | null |
| 2025-12 | 100% | 10.6% | 9.8% | 5.3% | null | null |
| 2026-01 | 100% | 14.1% | 7.8% | null | null | null |
| 2026-02 | 100% | 13.6% | null | null | null | null |
| 2026-03 | 100% | null  | null | null | null | null |

> Retention analysis reveals that less than 10% of new customers return the following month across older cohorts, indicating a high proportion of one-time buyers. However, month-1 retention shows a clear upward trend in recent cohorts — from ~3-4% in late 2024 to 14.1% in January 2026. This improvement is unlikely to be seasonal given consistent patterns across prior periods, suggesting retention campaigns are gaining traction over time.

---

## 3. LTV by RFM Segment

Monthly LTV calculated as total spend divided by active months. Single-purchase customers assigned 1 active month via `COALESCE(NULLIF(months_active, 0), 1)` to avoid division by zero while preserving actual spend. Analysis period: full history.

| Segment       | Customers | Avg Spend | Avg LTV/month | Avg Active Months |
|---------------|-----------|-----------|---------------|-------------------|
| 1 - Lost      | 5,195     | $35.1     | $35.1         | 0.0               |
| 2 - At Risk   | 11,049    | $74.6     | $74.2         | 0.1               |
| 3 - Loyal     | 8,258     | $125.2    | $107.4        | 2.4               |
| 4 - Champions | 3,261     | $207.6    | $119.3        | 8.4               |

> LTV analysis confirms the RFM segmentation with a clear value progression across tiers. Champions represent the highest value customers with avg historical spend of $207.6 and $119.3 monthly LTV over 8.4 active months. At Risk and Lost segments are predominantly one-time buyers with near-zero active months (0.1 and 0.0 respectively), explaining why their LTV closely mirrors their total spend. Converting At Risk customers (11,049, avg $74.6) into repeat buyers is the highest-impact retention opportunity — even a marginal increase in active months would significantly impact overall revenue.

---

## Overall Conclusions

1. **Re-engage At Risk first:** 1,792 customers averaging $74 spend — largest segment with recoverable revenue potential
2. **Upsell Loyal customers:** avg $116 spend with clear room to grow toward Champion status ($188)
3. **Retention is improving:** month-1 cohort retention trending up from 3% to 14% in recent months — current efforts are working and should be scaled
4. **One-time buyers dominate lower segments:** Lost and At Risk customers average 0-0.1 active months — even one additional purchase would significantly impact their LTV
5. **RFM and LTV converge:** both analyses point to the same strategic priority — converting At Risk customers into repeat buyers is the single highest-impact action available
