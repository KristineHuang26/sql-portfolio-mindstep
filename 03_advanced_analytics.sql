-- ============================================================
-- 03 · ADVANCED ANALYTICS
-- CTEs, window functions (ROW_NUMBER, LAG, running totals),
-- date math, churn rate, cohort retention
-- ============================================================

-- Q12. Monthly signups + a running cumulative total of users.
--      (date bucketing with strftime + window SUM)
SELECT month,
       new_users,
       SUM(new_users) OVER (ORDER BY month) AS cumulative_users
FROM (
    SELECT strftime('%Y-%m', signup_date) AS month,
           COUNT(*)                       AS new_users
    FROM users
    GROUP BY month
) m
ORDER BY month;

-- Q13. Churn rate: of all paid subscriptions, what share cancelled?
--      (conditional aggregation -> a single KPI)
SELECT COUNT(*)                                                   AS total_subs,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)      AS churned,
       ROUND(100.0 * SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END)
                   / COUNT(*), 1)                                 AS churn_rate_pct
FROM subscriptions;

-- Q14. Is monthly or annual billing stickier?
--      Churn rate split by billing cycle.
SELECT billing_cycle,
       COUNT(*)                                                       AS subs,
       ROUND(100.0 * SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END)
                   / COUNT(*), 1)                                     AS churn_rate_pct
FROM subscriptions
GROUP BY billing_cycle
ORDER BY churn_rate_pct;

-- Q15. Average subscription lifetime in days for cancelled subs.
--      (date difference with julianday)
SELECT billing_cycle,
       ROUND(AVG(julianday(end_date) - julianday(start_date)), 0) AS avg_lifetime_days
FROM subscriptions
WHERE status = 'cancelled'
GROUP BY billing_cycle;

-- Q16. Rank each user's check-ins and isolate their FIRST one.
--      (ROW_NUMBER window function — useful for "first touch" analysis)
WITH ordered AS (
    SELECT user_id,
           checkin_date,
           mood_score,
           ROW_NUMBER() OVER (PARTITION BY user_id
                              ORDER BY checkin_date) AS rn
    FROM checkins
)
SELECT user_id, checkin_date AS first_checkin, mood_score AS first_mood
FROM ordered
WHERE rn = 1
ORDER BY user_id
LIMIT 15;

-- Q17. Mood trajectory: for active users, compare their first vs.
--      latest mood score using window functions. Does mood improve?
WITH ranked AS (
    SELECT user_id,
           mood_score,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY checkin_date)        AS rn_first,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY checkin_date DESC)   AS rn_last,
           COUNT(*)    OVER (PARTITION BY user_id)                               AS n
    FROM checkins
)
SELECT ROUND(AVG(CASE WHEN rn_first = 1 THEN mood_score END), 2) AS avg_first_mood,
       ROUND(AVG(CASE WHEN rn_last  = 1 THEN mood_score END), 2) AS avg_latest_mood
FROM ranked
WHERE n >= 5;   -- users with enough history to show a trend

-- Q18. Month-1 retention by signup cohort.
--      A cohort = users who signed up in the same month. Retained =
--      they logged at least one check-in 28-60 days after signing up.
--      (CTEs + JOIN + date math + conditional aggregation)
WITH cohort AS (
    SELECT user_id,
           strftime('%Y-%m', signup_date) AS cohort_month,
           signup_date
    FROM users
),
retained AS (
    SELECT DISTINCT co.user_id
    FROM cohort co
    JOIN checkins c ON c.user_id = co.user_id
    WHERE julianday(c.checkin_date) - julianday(co.signup_date) BETWEEN 28 AND 60
)
SELECT co.cohort_month,
       COUNT(DISTINCT co.user_id)                                   AS cohort_size,
       COUNT(DISTINCT r.user_id)                                    AS retained_users,
       ROUND(100.0 * COUNT(DISTINCT r.user_id)
                   / COUNT(DISTINCT co.user_id), 1)                 AS month1_retention_pct
FROM cohort co
LEFT JOIN retained r ON r.user_id = co.user_id
GROUP BY co.cohort_month
ORDER BY co.cohort_month;
