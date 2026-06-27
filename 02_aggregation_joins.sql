-- ============================================================
-- 02 · AGGREGATION & JOINS
-- GROUP BY + HAVING, multi-table joins, LEFT JOIN, CASE, subqueries
-- ============================================================

-- Q6. Free vs. paid: how many users convert to a paid plan?
--     LEFT JOIN keeps users who never subscribed (free users).
SELECT CASE WHEN s.user_id IS NULL THEN 'Free (no sub)'
            ELSE 'Paid'
       END AS user_type,
       COUNT(DISTINCT u.user_id) AS users
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.user_id
GROUP BY user_type;

-- Q7. Conversion rate by acquisition channel — which channel sends
--     us users who actually pay? (LEFT JOIN + conditional aggregation)
SELECT u.acquisition_channel,
       COUNT(DISTINCT u.user_id)                              AS total_users,
       COUNT(DISTINCT s.user_id)                              AS paid_users,
       ROUND(100.0 * COUNT(DISTINCT s.user_id)
                   / COUNT(DISTINCT u.user_id), 1)            AS conversion_pct
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.user_id
GROUP BY u.acquisition_channel
ORDER BY conversion_pct DESC;

-- Q8. Estimated monthly recurring revenue (MRR) by plan,
--     counting only active subscriptions.
SELECT p.plan_name,
       COUNT(*)                              AS active_subs,
       ROUND(SUM(p.monthly_price), 2)        AS mrr_usd
FROM subscriptions s
JOIN plans p ON p.plan_id = s.plan_id
WHERE s.status = 'active'
GROUP BY p.plan_name
ORDER BY mrr_usd DESC;

-- Q9. Power users: which users logged MORE THAN 40 check-ins?
--     (GROUP BY + HAVING — filtering on an aggregate)
SELECT user_id,
       COUNT(*)                AS checkins,
       ROUND(AVG(mood_score),1) AS avg_mood
FROM checkins
GROUP BY user_id
HAVING COUNT(*) > 40
ORDER BY checkins DESC
LIMIT 15;

-- Q10. Segment users by engagement level using CASE, then size
--      each segment. (CASE + subquery in FROM)
SELECT engagement_segment,
       COUNT(*) AS users
FROM (
    SELECT u.user_id,
           CASE WHEN COUNT(c.checkin_id) = 0          THEN '0 · Dormant'
                WHEN COUNT(c.checkin_id) < 10         THEN '1 · Low'
                WHEN COUNT(c.checkin_id) < 30         THEN '2 · Medium'
                ELSE '3 · High'
           END AS engagement_segment
    FROM users u
    LEFT JOIN checkins c ON c.user_id = u.user_id
    GROUP BY u.user_id
) t
GROUP BY engagement_segment
ORDER BY engagement_segment;

-- Q11. Does paying correlate with engagement & mood?
--      Compare avg check-ins and mood for paid vs free users.
SELECT CASE WHEN s.user_id IS NULL THEN 'Free' ELSE 'Paid' END AS user_type,
       COUNT(DISTINCT u.user_id)                                AS users,
       ROUND(1.0 * COUNT(c.checkin_id)
                 / COUNT(DISTINCT u.user_id), 1)                AS avg_checkins_per_user,
       ROUND(AVG(c.mood_score), 2)                              AS avg_mood
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.user_id
LEFT JOIN checkins c      ON c.user_id = u.user_id
GROUP BY user_type;
