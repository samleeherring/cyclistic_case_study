/*
Cyclistic Case Study: Data analysis & cleaning
*/

-- Calculating nulls and zero values
SELECT
  *
FROM 
  `magnetic-energy-424103-m2.cyclistic_data.q1_df`
WHERE
  distance_km IS null
-- distance: 426, duration: 0, end_station: 93,016, ended_at: 0, member: 0
-- only 0.7% of all entries have null distance values, dropping them

-- Looking for significant outliers in distance & duration fields
SELECT
  member_casual,
  MAX(duration_min) AS max_duration
FROM
  `magnetic-energy-424103-m2.cyclistic_data.q1_df`
GROUP BY
  member_casual
  -- shows max durations of 1,400.9 & 1,400.92
SELECT
  member_casual,
  MIN(duration_min) AS min_duration
FROM
  (SELECT
    member_casual, -- don't want 0 or negative values
    IF(duration_min > 0.0, duration_min, null) AS duration_min
  FROM
    `magnetic-energy-424103-m2.cyclistic_data.q1_df`)
GROUP BY
  member_casual
  --shows mins of 0.02 for both 

-- Full view of all ride durations  to glimpse outliers
SELECT
  ride_id, member_casual, duration_min, distance_km
FROM
  `magnetic-energy-424103-m2.cyclistic_data.q1_df`
ORDER BY
  duration_min DESC

-- Comparing median to max and min < 0 to better understand outliers
SELECT
  DISTINCT median_duration,
  member_casual
FROM
  (SELECT
    ride_id, member_casual, duration_min, distance_km,
    PERCENTILE_DISC(duration_min, 0.5) 
    OVER(PARTITION BY member_casual) AS median_duration
  FROM
    `magnetic-energy-424103-m2.cyclistic_data.q1_df`)
ORDER BY
  median_duration 
  --medians of 7.07 & 8.68 respectively'

-- Medians by day of the week & membership type
SELECT
  DISTINCT median_duration,
  day_of_week
FROM
  (SELECT
    ride_id, day_of_week, duration_min, distance_km,
    PERCENTILE_DISC(duration_min, 0.5) 
    OVER(PARTITION BY day_of_week) AS median_duration
  FROM(
    SELECT
      ride_id, member_casual, day_of_week, duration_min, distance_km
    FROM
    `magnetic-energy-424103-m2.cyclistic_data.q1_df`
    WHERE
      member_casual = 'member'))
ORDER BY
  median_duration DESC

-- Creating small tables to view ridership breakdowns of member types by day
SELECT
  day_of_week, member_casual,
  COUNT(DISTINCT ride_id) AS total_trips,
  ROUND((COUNT(DISTINCT ride_id)/total_trips_all)*100, 2) AS percent_total
FROM (
    SELECT
      COUNT(ride_id) AS total_trips_all
    FROM
      `cyclistic_data.q1_df`
    WHERE
      member_casual = 'casual'
  ), `cyclistic_data.q1_df`
WHERE
  member_casual = 'casual'
GROUP BY
  day_of_week,
  member_casual,
  total_trips_all
ORDER BY
  total_trips DESC
LIMIT
  7

-- &

SELECT
  day_of_week, member_casual,
  COUNT(DISTINCT ride_id) AS total_trips,
  ROUND((COUNT(DISTINCT ride_id)/total_trips_all)*100, 2) AS percent_total
FROM (
    SELECT
      COUNT(ride_id) AS total_trips_all
    FROM
      `cyclistic_data.q1_df`
    WHERE
      member_casual = 'member'
  ), `cyclistic_data.q1_df`
WHERE
  member_casual = 'member'
GROUP BY
  day_of_week,
  member_casual,
  total_trips_all
ORDER BY
  total_trips DESC
LIMIT
  7
-- Alternative table to the above views
SELECT
  day_of_week,
  COUNT(ride_id) AS total_rides,
  COUNT(members) AS member_rides,
  COUNT(casuals) AS casual_rides
FROM
  (SELECT
    day_of_week, ride_id, 
    IF(member_casual = 'member', ride_id, null) AS members,
    IF(member_casual = 'casual', ride_id, null) AS casuals
  FROM
  `cyclistic_data.q1_df`)
GROUP BY
   day_of_week
ORDER BY
  total_rides DESC

-- Amounts and percentages of rides by membership type
SELECT
  total_trips, member_trips, casual_trips,
  ROUND(member_trips/total_trips, 2)*100 AS member_percentage,
  ROUND(casual_trips/total_trips, 2)*100 AS casual_percentage
FROM (
  SELECT
    COUNT(ride_id) AS total_trips,
    COUNTIF(member_casual = 'member') AS member_trips,
    COUNTIF(member_casual = 'casual') AS casual_trips
  FROM
    `magnetic-energy-424103-m2.cyclistic_data.q1_df`
  )
  -- By weekly & membership breakdowns
SELECT
  day_of_week, total_rides, member_rides, casual_rides,
  ROUND((member_rides/total_rides)*100, 2) AS member_percent,
  ROUND((casual_rides/total_rides)*100, 2) AS casual_percent
FROM  
  (SELECT
    day_of_week,
    COUNT(ride_id) AS total_rides,
    COUNT(members) AS member_rides,
    COUNT(casuals) AS casual_rides
  FROM
    (SELECT
      day_of_week, ride_id, 
      IF(member_casual = 'member', ride_id, null) AS members,
      IF(member_casual = 'casual', ride_id, null) AS casuals
    FROM
    `cyclistic_data.q1_df`)
  GROUP BY
   day_of_week)
GROUP BY
  day_of_week, total_rides, member_rides, casual_rides
ORDER BY
  total_rides DESC

-- Collecting averages stats between membership types
SELECT
  (SELECT
    ROUND(AVG(duration_min),2)
  FROM
    `magnetic-energy-424103-m2.cyclistic_data.q1_df`
  ) AS avg_drtn_stats,
  (SELECT
    ROUND(AVG(duration_min),2)
  FROM
    `cyclistic_data.q1_df`
  WHERE
    member_casual = 'member'
  ) AS member_drtn_avg,
  (SELECT
    ROUND(AVG(duration_min),2)
  FROM
    `cyclistic_data.q1_df`
  WHERE
    member_casual = 'casual'
  ) AS casual_drtn_avg,
  (SELECT
    ROUND(AVG(distance_km),2)
  FROM
    `cyclistic_data.q1_df`
  ) AS avg_dist_stats,
  (SELECT
    ROUND(AVG(distance_km),2)
  FROM
    `cyclistic_data.q1_df`
  WHERE
    member_casual = 'member'
  ) AS member_dist_avg,
  (SELECT
    ROUND(AVG(distance_km),2)
  FROM
    `cyclistic_data.q1_df`
  WHERE
    member_casual = 'casual'
  ) AS casual_dist_avg

