-- ============================================================
-- MindStep — Database Schema
-- Engine: SQLite (portable ANSI SQL; PostgreSQL notes in README)
-- A wellness habit-tracking app. 4 tables, modelled like a real
-- product-analytics warehouse: users, the plans they can buy,
-- their subscriptions, and their daily app check-ins.
-- ============================================================

DROP TABLE IF EXISTS checkins;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS plans;

-- Reference table: the subscription tiers we sell
CREATE TABLE plans (
    plan_id        INTEGER PRIMARY KEY,
    plan_name      TEXT    NOT NULL,   -- Free / Plus / Pro
    monthly_price  REAL    NOT NULL    -- list price per month (USD)
);

-- One row per registered user
CREATE TABLE users (
    user_id              INTEGER PRIMARY KEY,
    signup_date          TEXT    NOT NULL,   -- 'YYYY-MM-DD'
    country              TEXT,
    province             TEXT,               -- province / state code
    age                  INTEGER,
    acquisition_channel  TEXT                -- how they found us
);

-- One row per paid subscription. Free users have NO row here
-- (so LEFT JOIN reveals free vs. paid). end_date IS NULL = still active.
CREATE TABLE subscriptions (
    subscription_id  INTEGER PRIMARY KEY,
    user_id          INTEGER NOT NULL REFERENCES users(user_id),
    plan_id          INTEGER NOT NULL REFERENCES plans(plan_id),
    billing_cycle    TEXT,                 -- 'monthly' / 'annual'
    start_date       TEXT    NOT NULL,
    end_date         TEXT,                 -- NULL while active
    status           TEXT                  -- 'active' / 'cancelled'
);

-- Engagement events: each time a user logs a mood + habit in the app
CREATE TABLE checkins (
    checkin_id       INTEGER PRIMARY KEY,
    user_id          INTEGER NOT NULL REFERENCES users(user_id),
    checkin_date     TEXT    NOT NULL,
    mood_score       INTEGER,              -- 1 (low) .. 10 (high)
    habit_completed  INTEGER               -- 1 = yes, 0 = no
);
