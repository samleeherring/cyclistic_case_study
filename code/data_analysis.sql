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
    `cyclistic_data.q1_df`
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
    `cyclistic_data.q1_df`
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

-- View avg distances traveled overall and by membership type over weekdays
SELECT
    day_of_week,
    ROUND(AVG(distance_km),2) AS avg_ride_distance,
    ROUND(AVG(members),2) AS avg_member_dist,
    ROUND(AVG(casuals),2) AS avg_casual_dist
FROM
    (SELECT
      member_casual, day_of_week, distance_km, 
      IF(member_casual = 'member', distance_km, null) AS members,
      IF(member_casual = 'casual', distance_km, null) AS casuals
    FROM
    `cyclistic_data.q1_df`)
GROUP BY
   day_of_week
ORDER BY
  avg_ride_distance DESC
-- both show that sundays have the highest avg distance traveled

-- Looking at ridership stats (distance + duration) of the 3 bike types 
SELECT
  rideable_type,
  ROUND(AVG(seconds)/60,2) AS avg_duration,
  ROUND(AVG(distance),2) AS avg_distance
FROM 
  `cyclistic_data.q1_data` 
GROUP BY
  1
LIMIT 3
--data consistent with other avg ridership stats except for one thing:
--the returned table showed a ridiculously high avg duration on docked_bike
--which is only used by casual riders, so I queried just those
SELECT
  member_casual,
  rideable_type,
  ROUND(seconds/60,2) AS duration,
  distance
FROM
  `cyclistic_data.q1_data`
WHERE
  rideable_type = 'docked_bike'
ORDER BY
  duration DESC
--and found that the top 1.75% of longest duration rides on that bike type
--show no distance traveled, either bc of the same endpoint or bc there wasn't one.
--going to filter out records with durations > 1000 & distance = 0|null
WITH
no_nulls AS (
SELECT
  rideable_type, distance,
  IF (duration > 1000 AND distance IS null, null, duration) AS duration  
FROM  
  (SELECT
    rideable_type,
    ROUND(seconds/60,2) AS duration,
    distance
  FROM
    `cyclistic_data.q1_data`
  WHERE
    rideable_type = 'docked_bike'
  ORDER BY
    duration DESC)
)
SELECT 
  rideable_type
  ,ROUND(AVG(no_nulls.duration),2) AS avg_duration
  ,ROUND(AVG(no_nulls.distance),2) AS avg_distance
FROM
  no_nulls
WHERE
  no_nulls.distance IS NOT null
GROUP BY
  rideable_type
--this still shows a high average, but at least the empty/extreme fields aren't a factor
--old docked_bike avg: 158.13 min, new avg: 41.37 min

--Finding top stations by membership type
--starting stations:
SELECT
  DISTINCT(end_station_name) AS end_station,
  SUM(
    CASE WHEN(ride_id = ride_id AND end_station_name = end_station_name)
    THEN 1 ELSE 0 END) AS total_rides,
  SUM(
    CASE WHEN(member_casual = 'member' AND end_station_name = end_station_name)
    THEN 1 ELSE 0 END) AS member,
  SUM(
    CASE WHEN(member_casual = 'casual' AND end_station_name = end_station_name)
    THEN 1 ELSE 0 END) AS casual
FROM
  `cyclistic_data.q1_df`
GROUP BY
  end_station_name
ORDER BY
  total_rides DESC
--ending stations:
SELECT
  DISTINCT(end_station_name) AS end_station,
  SUM(
    CASE WHEN(ride_id = ride_id AND end_station_name = end_station_name)
    THEN 1 ELSE 0 END) AS total_rides,
  SUM(
    CASE WHEN(member_casual = 'member' AND end_station_name = end_station_name)
    THEN 1 ELSE 0 END) AS member,
  SUM(
    CASE WHEN(member_casual = 'casual' AND end_station_name = end_station_name)
    THEN 1 ELSE 0 END) AS casual
FROM
  `cyclistic_data.q1_df`
GROUP BY
  end_station_name
ORDER BY
  total_rides DESC

--Top station combos by membership type
SELECT
    start_station_name, end_station_name,
    COUNT(*) AS combo,
    COUNTIF(member_casual='member') AS member_combo,
    COUNTIF(member_casual='casual') AS casual_combo
FROM 
    `cyclistic_data.q1_df`
WHERE
    start_station_name = start_station_name
    AND end_station_name = end_station_name
    AND end_station_name IS NOT null
    AND start_station_name IS NOT null
GROUP BY
    1,2
ORDER BY
    combo DESC

--Viewing total trips by membership type with day of week and percentages
SELECT
  total_trips, member_trips,
  casual_trips, trip_date, 
  day_of_week,
  ROUND(member_trips/total_trips,2)*100 AS member_percentage,
  ROUND(casual_trips/total_trips,2)*100 AS casual_percentage
FROM  (
  SELECT
    COUNT(ride_id) AS total_trips,
    COUNTIF(member_casual='member') AS member_trips,
    COUNTIF(member_casual='casual') AS casual_trips,
    DATE(started_at) AS trip_date,
    day_of_week
  FROM
    `cyclistic_data.q1_df`
  WHERE
    ride_id = ride_id
  GROUP BY
    trip_date,
    day_of_week)
ORDER BY
  total_trips DESC

--Using this query to see the most popular start times among riders
SELECT
  total_trips, member_trips,
  casual_trips, trip_date, 
  day_of_week, start_hour,
  ROUND(member_trips/total_trips,2)*100 AS member_percentage,
  ROUND(casual_trips/total_trips,2)*100 AS casual_percentage
FROM  (
  SELECT
    EXTRACT(HOUR FROM started_at) AS start_hour,
    COUNT(ride_id) AS total_trips,
    COUNTIF(member_casual='member') AS member_trips,
    COUNTIF(member_casual='casual') AS casual_trips,
    DATE(started_at) AS trip_date,
    day_of_week
  FROM
    `cyclistic_data.q1_df`
  WHERE
    ride_id = ride_id
  GROUP BY
    trip_date,
    day_of_week,
    start_hour)
ORDER BY
  total_trips DESC