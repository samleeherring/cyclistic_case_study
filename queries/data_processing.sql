/* 
Cyclistic Case Study: Initial Setup, Processing, & Join Queries
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

-- Checking for duplicates across all data (annual_data)
SELECT *
FROM (
SELECT *,
  row_number() over (partition by ride_id order by ride_id) as rn
FROM `cyclistic_data.annual_data`
ORDER BY ride_id) x
WHERE x.rn > 1; 
-- no dups

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

-- Converting all lat/lon fields into radians for ride distance data
/*
DECLARE pi FLOAT64;
SET pi = bqutil.fn.pi();
*/
/*
There wasn't a pi() function in BigQuery which... I hope they fix that
Also added in distance column & removed columns used to calculate it
SELECT
  * EXCEPT (start_lat, start_lng, end_lat, end_lng, lat_rad_1, lng_rad_1, lat_rad_2, lng_rad_2),
  ROUND((6371 * ACOS((SIN(lat_rad_1)*SIN(lat_rad_2))+COS(lat_rad_1)
  *COS(lat_rad_2)*COS(lng_rad_2-lng_rad_1))),3) AS distance
FROM (
  SELECT
    *,
    ROUND((start_lat * 2 * ACOS(-1) /360),3) AS lat_rad_1,
    ROUND((start_lng * 2 * ACOS(-1) /360),3) AS lng_rad_1,
    ROUND((end_lat * 2 * ACOS(-1) /360),3) AS lat_rad_2,
    ROUND((end_lng * 2 * ACOS(-1) /360),3) AS lng_rad_2,
  FROM `cyclistic_data.q1_data`
)
Something is wrong with the math here, the distance calculation is off
Ok had to abandon the trig approach and use legacy function combos instead
*/

-- Adding distance columnn to data frame
SELECT
  * EXCEPT(start_lng, start_lat, end_lng, end_lat),
  ROUND(ST_DISTANCE(start_point, end_point)/1000, 2) AS distance
FROM
  (SELECT
    *,
    ST_GEOGPOINT(start_lng, start_lat) AS start_point,
    ST_GEOGPOINT(end_lng, end_lat) AS end_point
  FROM
    `cyclistic_data.apr_23`
  WHERE
    end_lat <> 0)
ORDER BY
  end_station_name DESC -- places nulls at the end for easier verification

-- Final query for initial processing: establishing workable data frames
SELECT
  ride_id, started_at, ended_at, day_of_week, ROUND(seconds/60,2) AS duration_min,
  distance AS distance_km, start_station_name, end_station_name, member_casual
FROM
  `cyclistic_data.q1_data`
ORDER BY
  ride_id DESC