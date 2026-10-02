-- Data Quality Check
SELECT
    SUM(CASE WHEN Delivery_person_Age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN Delivery_person_Ratings IS NULL THEN 1 ELSE 0 END) AS null_ratings,
    SUM(CASE WHEN Weather IS NULL THEN 1 ELSE 0 END) AS null_weather,
    SUM(CASE WHEN Road_traffic_density IS NULL THEN 1 ELSE 0 END) AS null_traffic,
    COUNT(*) AS total_rows
FROM updated;


-- Univariate Analysis 
-- Delivery Time Distribution
SELECT
    CASE
        WHEN Time_taken_min <= 15 THEN '10-15'
        WHEN Time_taken_min <= 20 THEN '16-20'
        WHEN Time_taken_min <= 25 THEN '21-25'
        WHEN Time_taken_min <= 30 THEN '26-30'
        WHEN Time_taken_min <= 35 THEN '31-35'
        WHEN Time_taken_min <= 40 THEN '36-40'
        ELSE '40+'
    END AS delivery_time_bin,
    COUNT(*) AS total_orders
FROM updated
GROUP BY delivery_time_bin
ORDER BY MIN(Time_taken_min);

-- Delivery Time Statistics
SELECT
    MIN(Time_taken_min) AS min_time,
    MAX(Time_taken_min) AS max_time,
    ROUND(AVG(Time_taken_min), 2) AS avg_time,
    ROUND(STDDEV(Time_taken_min), 2) AS stddev_time
FROM updated;

-- Courier Age Distribution
SELECT
    CASE
        WHEN Delivery_person_Age < 25 THEN '20-24'
        WHEN Delivery_person_Age < 30 THEN '25-29'
        WHEN Delivery_person_Age < 35 THEN '30-34'
        WHEN Delivery_person_Age < 40 THEN '35-39'
        ELSE '40+'
    END AS age_bin,
    COUNT(*) AS total_couriers
FROM updated
GROUP BY age_bin
ORDER BY MIN(Delivery_person_Age);

-- Distance_km vs Test 
SELECT
    'Training (updated)' AS data_source,
    CASE
        WHEN Distance_km <= 5 THEN '0-5'
        WHEN Distance_km <= 10 THEN '6-10'
        WHEN Distance_km <= 15 THEN '11-15'
        WHEN Distance_km <= 20 THEN '16-20'
        ELSE '20+'
    END AS distance_bin,
    COUNT(*) AS total_orders
FROM updated
GROUP BY distance_bin
UNION ALL
SELECT
    'Test (cleaned_test)' AS data_source,
    CASE
        WHEN Distance_km <= 5 THEN '0-5'
        WHEN Distance_km <= 10 THEN '6-10'
        WHEN Distance_km <= 15 THEN '11-15'
        WHEN Distance_km <= 20 THEN '16-20'
        ELSE '20+'
    END AS distance_bin,
    COUNT(*) AS total_orders
FROM cleaned_test
GROUP BY distance_bin
ORDER BY data_source, distance_bin;


-- Bivariate Analysis
-- Distance vs Delivery Time 
SELECT
    Distance_km,
    Time_taken_min
FROM updated
ORDER BY Distance_km;

SELECT
    CASE
        WHEN Distance_km <= 5 THEN '0-5'
        WHEN Distance_km <= 10 THEN '6-10'
        WHEN Distance_km <= 15 THEN '11-15'
        WHEN Distance_km <= 20 THEN '16-20'
        ELSE '20+'
    END AS distance_bin,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    COUNT(*) AS total_orders
FROM updated
GROUP BY distance_bin
ORDER BY MIN(Distance_km);

-- Traffic Density vs Delivery Time 
SELECT
    Road_traffic_density,
    MIN(Time_taken_min) AS min_time,
    ROUND(AVG(Time_taken_min), 2) AS avg_time,
    MAX(Time_taken_min) AS max_time,
    COUNT(*) AS total_orders
FROM updated
GROUP BY Road_traffic_density
ORDER BY avg_time DESC;

SELECT
    Road_traffic_density,
    Time_taken_min,
    NTILE(4) OVER (PARTITION BY Road_traffic_density ORDER BY Time_taken_min) AS quartile
FROM updated;

-- Festival Impact for Delivery Time
SELECT
    Festival,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    ROUND(AVG(Distance_km), 2) AS avg_distance,
    COUNT(*) AS total_orders
FROM updated
GROUP BY Festival;

-- multiple_deliveries impact for Delivery Time
SELECT
    multiple_deliveries,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    COUNT(*) AS total_orders
FROM updated
GROUP BY multiple_deliveries
ORDER BY multiple_deliveries;

-- Correlation between Distance_km and Time_taken_min
SELECT
    (
        (COUNT(*) * SUM(Distance_km * Time_taken_min)) - (SUM(Distance_km) * SUM(Time_taken_min))
    ) /
    (
        SQRT(COUNT(*) * SUM(Distance_km * Distance_km) - POWER(SUM(Distance_km), 2)) *
        SQRT(COUNT(*) * SUM(Time_taken_min * Time_taken_min) - POWER(SUM(Time_taken_min), 2))
    ) AS correlation_distance_vs_time
FROM updated;

-- Feature Importances
SELECT * FROM feature_importance
ORDER BY Importance DESC
LIMIT 10;

-- City-level Summary
SELECT
    City,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    ROUND(AVG(Distance_km), 2) AS avg_distance,
    COUNT(*) AS total_orders
FROM updated
GROUP BY City
ORDER BY avg_delivery_time DESC;

-- Weather impact for Delivery Time
SELECT
    Weather,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    COUNT(*) AS total_orders
FROM updated
GROUP BY Weather
ORDER BY avg_delivery_time DESC;

-- Delivery_person_Ratings impact for Delivery Time
SELECT
    CASE
        WHEN Delivery_person_Ratings >= 4.5 THEN 'High (>=4.5)'
        WHEN Delivery_person_Ratings >= 4.0 THEN 'Medium (4.0-4.49)'
        ELSE 'Low (<4.0)'
    END AS rating_segment,
    ROUND(AVG(Time_taken_min), 2) AS avg_delivery_time,
    COUNT(*) AS total_couriers
FROM updated
GROUP BY rating_segment
ORDER BY avg_delivery_time DESC;