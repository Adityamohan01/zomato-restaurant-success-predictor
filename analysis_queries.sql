-- ============================================================
--  ZOMATO / SWIGGY RESTAURANT SUCCESS PREDICTOR
--  Phase 2 — SQL Analysis (MySQL Workbench)
--  8 Business Queries | Run each one separately
--  Screenshot every result and save to /sql/screenshots/
-- ============================================================

-- ── SETUP: Run this first ────────────────────────────────────
CREATE DATABASE IF NOT EXISTS zomato_project;
USE zomato_project;

-- ============================================================
-- STEP 1: CREATE TABLE
-- ============================================================
DROP TABLE IF EXISTS restaurants;

CREATE TABLE restaurants (
    Restaurant_ID           VARCHAR(10)    PRIMARY KEY,
    Restaurant_Name         VARCHAR(50),
    City                    VARCHAR(20),
    Area                    VARCHAR(30),
    Cuisine_Type            VARCHAR(30),
    Restaurant_Type         VARCHAR(30),
    Price_Range             VARCHAR(30),
    Rating                  DECIMAL(3,1),
    Total_Reviews           INT,
    Avg_Delivery_Time_Min   INT,
    Monthly_Orders          INT,
    Avg_Order_Value_INR     INT,
    Years_Active            DECIMAL(4,1),
    Review_Sentiment_Score  DECIMAL(4,2),
    Discount_Offered_Pct    INT,
    On_Zomato               VARCHAR(5),
    On_Swiggy               VARCHAR(5),
    Staff_Count             INT,
    Success_Score           DECIMAL(5,1),
    Status                  VARCHAR(15)
);

-- ── IMPORT DATA ──────────────────────────────────────────────
-- In MySQL Workbench:
-- 1. Right-click 'restaurants' table → Table Data Import Wizard
-- 2. Select: data/cleaned/zomato_cleaned.csv
-- 3. Map columns → Finish
-- OR use the command below (update path to your CSV location):
-- LOAD DATA INFILE '/path/to/zomato_cleaned.csv'
-- INTO TABLE restaurants
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- Verify import
SELECT COUNT(*) AS total_rows FROM restaurants;
SELECT * FROM restaurants LIMIT 5;


-- ============================================================
-- QUERY 1: Overall Health Check
-- Business question: What is the big picture?
-- ============================================================
SELECT
    Status,
    COUNT(*)                                        AS total,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS pct,
    ROUND(AVG(Rating), 2)                           AS avg_rating,
    ROUND(AVG(Success_Score), 1)                    AS avg_success,
    ROUND(AVG(Monthly_Orders), 0)                   AS avg_orders
FROM restaurants
GROUP BY Status
ORDER BY FIELD(Status, 'Thriving', 'Stable', 'Struggling', 'Closed');

-- 📌 Expected insight: Thriving restaurants have higher ratings
--    and more monthly orders than Closed ones


-- ============================================================
-- QUERY 2: Survival Rate by City
-- Business question: Which city has the best restaurant ecosystem?
-- ============================================================
SELECT
    City,
    COUNT(*)                                                          AS total_restaurants,
    SUM(CASE WHEN Status != 'Closed' THEN 1 ELSE 0 END)              AS surviving,
    SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)             AS thriving,
    SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END)               AS closed,
    ROUND(
        100.0 * SUM(CASE WHEN Status != 'Closed' THEN 1 ELSE 0 END)
        / COUNT(*), 1)                                                AS survival_rate_pct,
    ROUND(AVG(Success_Score), 1)                                      AS avg_success_score,
    ROUND(AVG(Rating), 2)                                             AS avg_rating
FROM restaurants
GROUP BY City
ORDER BY survival_rate_pct DESC;

-- 📌 Screenshot this — great for Power BI city map


-- ============================================================
-- QUERY 3: Platform Presence vs Performance
-- Business question: Is being on both Zomato & Swiggy worth it?
-- ============================================================
SELECT
    CASE
        WHEN On_Zomato = 'Yes' AND On_Swiggy = 'Yes' THEN 'Both Platforms'
        WHEN On_Zomato = 'Yes' AND On_Swiggy = 'No'  THEN 'Zomato Only'
        WHEN On_Zomato = 'No'  AND On_Swiggy = 'Yes' THEN 'Swiggy Only'
        ELSE 'No Platform'
    END                                                  AS Platform_Presence,
    COUNT(*)                                             AS restaurant_count,
    ROUND(AVG(Success_Score), 1)                         AS avg_success_score,
    ROUND(AVG(Monthly_Orders), 0)                        AS avg_monthly_orders,
    ROUND(AVG(Monthly_Orders * Avg_Order_Value_INR), 0)  AS avg_monthly_revenue_INR,
    SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END) AS thriving_count,
    SUM(CASE WHEN Status = 'Closed'   THEN 1 ELSE 0 END) AS closed_count
FROM restaurants
GROUP BY Platform_Presence
ORDER BY avg_success_score DESC;

-- 📌 KEY RESUME INSIGHT: "Dual-platform restaurants earn Xx more orders"
--    Calculate multiplier: Both_avg_orders / No_Platform_avg_orders


-- ============================================================
-- QUERY 4: The Discount Trap
-- Business question: Are struggling restaurants over-discounting?
-- ============================================================
SELECT
    Status,
    COUNT(*)                                    AS count,
    ROUND(AVG(Discount_Offered_Pct), 1)         AS avg_discount_pct,
    MIN(Discount_Offered_Pct)                   AS min_discount,
    MAX(Discount_Offered_Pct)                   AS max_discount,
    ROUND(AVG(Monthly_Orders), 0)               AS avg_orders,
    ROUND(AVG(Rating), 2)                       AS avg_rating
FROM restaurants
GROUP BY Status
ORDER BY FIELD(Status, 'Thriving', 'Stable', 'Struggling', 'Closed');

-- 📌 KEY INSIGHT: Closed restaurants offer MORE discount
--    but it does NOT improve their orders or survival
--    → Over-discounting is a symptom of failure, not a cure


-- ============================================================
-- QUERY 5: Delivery Speed vs Success
-- Business question: Does faster delivery predict survival?
-- ============================================================
SELECT
    CASE
        WHEN Avg_Delivery_Time_Min <= 30 THEN '1. Fast (under 30 min)'
        WHEN Avg_Delivery_Time_Min <= 45 THEN '2. Normal (30-45 min)'
        ELSE                                  '3. Slow (over 45 min)'
    END                                                        AS Delivery_Speed,
    COUNT(*)                                                   AS count,
    ROUND(AVG(Success_Score), 1)                               AS avg_success,
    ROUND(AVG(Rating), 2)                                      AS avg_rating,
    ROUND(AVG(Monthly_Orders), 0)                              AS avg_orders,
    SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)       AS thriving_count,
    SUM(CASE WHEN Status = 'Closed'   THEN 1 ELSE 0 END)       AS closed_count,
    ROUND(
        100.0 * SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)
        / COUNT(*), 1)                                         AS thriving_pct
FROM restaurants
GROUP BY Delivery_Speed
ORDER BY Delivery_Speed;

-- 📌 Fast restaurants should have much higher thriving_pct


-- ============================================================
-- QUERY 6: Cuisine Performance Ranking
-- Business question: Which cuisine has the best success rate?
-- ============================================================
SELECT
    Cuisine_Type,
    COUNT(*)                                                      AS total,
    ROUND(AVG(Success_Score), 1)                                  AS avg_success_score,
    ROUND(AVG(Rating), 2)                                         AS avg_rating,
    SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)          AS thriving,
    SUM(CASE WHEN Status = 'Closed'   THEN 1 ELSE 0 END)          AS closed,
    ROUND(
        100.0 * SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)
        / COUNT(*), 1)                                            AS thriving_pct,
    ROUND(AVG(Monthly_Orders * Avg_Order_Value_INR), 0)           AS avg_monthly_revenue
FROM restaurants
GROUP BY Cuisine_Type
ORDER BY avg_success_score DESC;

-- 📌 Top 3 cuisines to recommend for new restaurant owners


-- ============================================================
-- QUERY 7: Sentiment vs Rating — Which Predicts Success Better?
-- Business question: Is sentiment score a better predictor than stars?
-- ============================================================

-- Part A: Correlation check (manual calculation)
SELECT
    ROUND(
        (COUNT(*) * SUM(Rating * Success_Score) - SUM(Rating) * SUM(Success_Score))
        / SQRT(
            (COUNT(*) * SUM(Rating * Rating)         - SUM(Rating) * SUM(Rating)) *
            (COUNT(*) * SUM(Success_Score*Success_Score) - SUM(Success_Score)*SUM(Success_Score))
        ), 3)  AS rating_vs_success_correlation,
    ROUND(
        (COUNT(*) * SUM(Review_Sentiment_Score * Success_Score) - SUM(Review_Sentiment_Score) * SUM(Success_Score))
        / SQRT(
            (COUNT(*) * SUM(Review_Sentiment_Score*Review_Sentiment_Score) - SUM(Review_Sentiment_Score)*SUM(Review_Sentiment_Score)) *
            (COUNT(*) * SUM(Success_Score*Success_Score)                   - SUM(Success_Score)*SUM(Success_Score))
        ), 3)  AS sentiment_vs_success_correlation
FROM restaurants;

-- Part B: Sentiment category breakdown
SELECT
    CASE
        WHEN Review_Sentiment_Score >= 0.3  THEN 'Positive'
        WHEN Review_Sentiment_Score >= -0.3 THEN 'Neutral'
        ELSE                                     'Negative'
    END                                                        AS Sentiment_Category,
    COUNT(*)                                                   AS count,
    ROUND(AVG(Success_Score), 1)                               AS avg_success,
    ROUND(AVG(Rating), 2)                                      AS avg_rating,
    SUM(CASE WHEN Status = 'Closed' THEN 1 ELSE 0 END)         AS closed_count,
    ROUND(
        100.0 * SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)
        / COUNT(*), 1)                                         AS thriving_pct
FROM restaurants
GROUP BY Sentiment_Category
ORDER BY avg_success DESC;

-- 📌 KEY RESUME INSIGHT: Compare both correlations
--    "Sentiment (r=X) outperforms Rating (r=Y) as a success predictor"


-- ============================================================
-- QUERY 8: Top 10 Perfect Restaurant Profiles
-- Business question: What does a perfect restaurant look like?
-- ============================================================
SELECT
    Restaurant_Name,
    City,
    Area,
    Cuisine_Type,
    Price_Range,
    Rating,
    Avg_Delivery_Time_Min                            AS Delivery_Min,
    Monthly_Orders,
    ROUND(Monthly_Orders * Avg_Order_Value_INR, 0)   AS Monthly_Revenue_INR,
    Review_Sentiment_Score                           AS Sentiment,
    Discount_Offered_Pct                             AS Discount_Pct,
    Success_Score
FROM restaurants
WHERE Status = 'Thriving'
ORDER BY Success_Score DESC
LIMIT 10;

-- 📌 This is your "blueprint for success" slide in Power BI


-- ============================================================
-- BONUS QUERY: Price Range Revenue Analysis
-- Business question: Which price segment is most profitable?
-- ============================================================
SELECT
    Price_Range,
    COUNT(*)                                                      AS count,
    ROUND(AVG(Monthly_Orders * Avg_Order_Value_INR), 0)           AS avg_monthly_revenue,
    ROUND(AVG(Success_Score), 1)                                  AS avg_success,
    ROUND(AVG(Rating), 2)                                         AS avg_rating,
    SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)          AS thriving,
    ROUND(
        100.0 * SUM(CASE WHEN Status = 'Thriving' THEN 1 ELSE 0 END)
        / COUNT(*), 1)                                            AS thriving_pct
FROM restaurants
GROUP BY Price_Range
ORDER BY avg_monthly_revenue DESC;


-- ============================================================
-- SAVE RESULTS
-- For each query result in MySQL Workbench:
-- Click the Export button (grid icon) → Export as CSV
-- Save to: sql/results/query_1_health_check.csv etc.
-- Take a screenshot of each result grid too
-- ============================================================
