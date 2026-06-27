# MindStep — SQL Analytics Portfolio

**A product-analytics deep-dive into a wellness habit-tracking app, written entirely in SQL.**

I built this project to analyze how users of a (fictional) mobile app called *MindStep* sign up, convert to paid plans, engage day-to-day, and churn. My background is in psychology, so I'm especially interested in the behavioural side of the data — *why* people stick with a habit and what the numbers say about engagement and wellbeing — and in turning that into the kind of metrics a business actually decides on (conversion, MRR, retention, churn).

> **At a glance:** 4 related tables · 1,000 users · 553 subscriptions · ~18,600 engagement events · 18 queries from foundations to window functions and cohort retention.

---

## The questions this project answers

- Which acquisition channels bring users who actually **pay**?
- What's our **monthly recurring revenue (MRR)**, and which plan drives it?
- Are **monthly or annual** subscribers stickier — and by how much?
- Does paying correlate with **higher engagement and mood**?
- What does **month-1 retention** look like across signup cohorts?

## Key findings

| Metric | Result |
|---|---|
| Free → paid conversion | **55.3%** of users convert to a paid plan |
| Best-converting channel | **Email (69%)** and **Referral (63%)** far outperform paid social (53%) |
| Total MRR | **~$5,866 USD/mo**, with Pro generating more than Plus despite fewer subscribers |
| Churn rate | **22.6%** overall — but **monthly plans churn at 27.2% vs. just 11.6% for annual** |
| Subscription lifetime | Annual subs last **221 days** on average vs. **140** for monthly |
| Engagement & paying | Paid users average **23 check-ins** (vs. 13 for free) and a higher mood score (**5.9 vs. 5.1**) |


**So what?** Two clear, actionable takeaways: (1) double down on Email/Referral acquisition, which convert ~30% better than paid social; (2) nudge users toward annual billing — it more than halves churn. The engagement gap also suggests that the in-app habit experience, not just price, is what retains paying users.

*Full write-up with the reasoning behind each number is in [`insights.md`](insights.md).*

---

## The data model

Four tables, structured the way a real product warehouse would be — a reference table, a users table, the subscriptions they buy, and their day-to-day engagement events.

```
plans (plan_id) ──< subscriptions >── (user_id) users ──< checkins
   plan tiers        who pays for what        registered users    daily mood + habit logs
```

| Table | Rows | What it holds |
|---|---|---|
| `plans` | 3 | The tiers we sell: Free, Plus ($9.99), Pro ($19.99) |
| `users` | 1,000 | Signup date, country/province, age, acquisition channel |
| `subscriptions` | 553 | Paid plans, billing cycle, start/end dates, status (free users have no row → great for `LEFT JOIN`) |
| `checkins` | ~18,600 | Each time a user logs a mood score (1–10) and whether they completed their habit |

> The data is **synthetic** (generated with realistic behavioural patterns — e.g. monthly plans churn faster, engagement decays after signup) so the project is fully shareable while still producing meaningful analysis.

---

## Skills demonstrated

Organized into three tiers of increasing difficulty so you can see the full range.

| Tier | File | SQL techniques |
|---|---|---|
| **1 · Foundations** | [`queries/01_foundations.sql`](queries/01_foundations.sql) | `SELECT`, `WHERE`, `ORDER BY`, `COUNT`, `GROUP BY`, `INNER JOIN`, `AVG` |
| **2 · Aggregation & joins** | [`queries/02_aggregation_joins.sql`](queries/02_aggregation_joins.sql) | `LEFT JOIN`, `GROUP BY … HAVING`, `CASE` segmentation, conditional aggregation, subqueries, conversion-rate logic |
| **3 · Advanced analytics** | [`queries/03_advanced_analytics.sql`](queries/03_advanced_analytics.sql) | CTEs (`WITH`), window functions (`ROW_NUMBER`, `SUM OVER`), date math, **churn rate**, **cohort retention** |

---

## How to run it

**Option A — open the ready-made database (fastest):**
1. Download [DB Browser for SQLite](https://sqlitebrowser.org/) (free).
2. Open `mindstep.db`.
3. Paste any query from the `queries/` folder into the *Execute SQL* tab and run it.

**Option B — build from scratch (shows the schema works):**
```bash
sqlite3 mindstep_new.db < schema.sql
sqlite3 mindstep_new.db < seed_data.sql
```
Then run any query, e.g.:
```bash
sqlite3 mindstep_new.db < queries/03_advanced_analytics.sql
```

The raw tables are also provided as CSVs in `data/` if you'd rather load them into PostgreSQL, BigQuery, or pandas.
