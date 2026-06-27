-- ============================================================
-- 01 · FOUNDATIONS
-- SELECT, WHERE, ORDER BY, COUNT, basic GROUP BY, a first JOIN
-- ============================================================

-- Q1. How many users have we acquired in total?
SELECT COUNT(*) AS total_users
FROM users;

-- Q2. Where are our users? Rank provinces by user count.
--     (basic GROUP BY + ORDER BY)
SELECT province,
       COUNT(*) AS users
FROM users
GROUP BY province
ORDER BY users DESC;

-- Q3. Which acquisition channels bring the most signups?
SELECT acquisition_channel,
       COUNT(*) AS signups
FROM users
GROUP BY acquisition_channel
ORDER BY signups DESC;

-- Q4. List every active paid subscriber with their plan name.
--     (INNER JOIN across two tables)
SELECT u.user_id,
       u.province,
       p.plan_name,
       s.billing_cycle,
       s.start_date
FROM subscriptions s
JOIN users u  ON u.user_id  = s.user_id
JOIN plans p  ON p.plan_id  = s.plan_id
WHERE s.status = 'active'
ORDER BY s.start_date DESC
LIMIT 20;

-- Q5. What is the average mood score users log in the app?
SELECT ROUND(AVG(mood_score), 2) AS avg_mood
FROM checkins;
