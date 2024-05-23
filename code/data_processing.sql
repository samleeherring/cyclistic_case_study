/* 
Cyclistic Case Study: Initial Setup and Quarterly Join Queries
*/
/*
Q1: jan-mar, 639,424 rows
Q2: apr-jun, 1,751,035 rows
Q3: jul-aep, 2,205,714 rows
Q4: oct-dec, 1,123,704 rows
*/
SELECT 
  *
FROM 
  `cyclistic_data.oct_23`

UNION ALL

SELECT
  *
FROM
  `cyclistic_data.nov_23`
  
UNION ALL

SELECT
  *
FROM
  `cyclistic_data.dec_23`;

-- Aggregate data organized into annual data set for future modification
SELECT
  *
FROM
  `cyclistic_data.q1_data`
UNION ALL

SELECT
  *
FROM
  `cyclistic_data.q2_data`
UNION ALL

SELECT
  *
FROM
  `cyclistic_data.q3_data`
UNION ALL

SELECT
  *
FROM
  `cyclistic_data.q4_data`;

-- Finding the geographical borders (lat/lon) of data
-- Lat = (41.16 : 42.18) Lon =(-87.46 : -88.16)
SELECT
  MAX(start_lat) AS north_lmt_1,
  MIN(start_lat) AS south_lmt_1,
  MAX(start_lng) AS east_lmt_1,
  MIN(start_lng) AS west_lmt_1,
  MAX(end_lat) AS north_lmt_2,
  MIN(end_lat) AS south_lmt_2,
  MAX(end_lng) AS east_lmt_2,
  MIN(end_lng) AS west_lmt_2
FROM
  `cyclistic_data.annual_data`

  -- Adding a day of week column for statistical analysis
  SELECT
  *,
  CASE 
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 1 THEN 'Sunday'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 2 THEN 'Monday'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 3 THEN 'Tuesday'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 4 THEN 'Wednesday'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 5 THEN 'Thursday'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 6 THEN 'Friday'
    WHEN EXTRACT(DAYOFWEEK FROM started_at) = 7 THEN 'Saturday'
  END day_of_week
FROM 
  `cyclistic_data.annual_data`

-- New columns to show trip duration, formatted & in seconds
SELECT 
  *,
  FORMAT_TIMESTAMP("%T", TIMESTAMP_SECONDS(seconds)) as trip_duration,
  
FROM
  (
  SELECT
    *,
    DATE_DIFF(ended_at, started_at, SECOND) AS seconds,
  FROM `cyclistic_data.annual_data` 
  )