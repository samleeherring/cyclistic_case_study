library(tidyverse)
library(readr)
library(dplyr)

# dec23 <- read_csv("data/202312-divvy-tripdata.csv") missing entire columns of values
nov23 <- read_csv("data/202311-divvy-tripdata.csv")
oct23 <- read_csv("data/202310-divvy-tripdata.csv")
sep23 <- read_csv("data/202309-divvy-tripdata.csv")
aug23 <- read_csv("data/202308-divvy-tripdata.csv")
jul23 <- read_csv("data/202307-divvy-tripdata.csv")
jun23 <- read_csv("data/202306-divvy-tripdata.csv")
may23 <- read_csv("data/202305-divvy-tripdata.csv")
apr23 <- read_csv("data/202304-divvy-tripdata.csv")
mar23 <- read_csv("data/202303-divvy-tripdata.csv")
feb23 <- read_csv("data/202302-divvy-tripdata.csv")
jan23 <- read_csv("data/202301-divvy-tripdata.csv")
dec22 <- read_csv("data/202212-divvy-tripdata.csv")

test_join <- full_join(dec22, jan23)
ncol(test_join)
nrow(jan23) + nrow(dec22)
nrow(test_join)
## all data transfered together in join

winter_data <- full_join(test_join, feb23)
spring_data <- full_join(mar23, full_join(apr23, may23))
summer_data <- full_join(jun23, full_join(jul23, aug23)) ## seeing NA values
autumn_data <- full_join(sep23, full_join(oct23, nov23))

nrow(summer_data)
colSums(is.na(summer_data)) ## cols 5-8 & 11,12, bout 17% of total
nrow(autumn_data)
colSums(is.na(autumn_data)) ## 16% 
nrow(winter_data)
colSums(is.na(winter_data)) ## 15%
nrow(spring_data)
colSums(is.na(spring_data)) ## 16%
## it's likely that this percentage of riders encountered an app issue or made an error

colnames(summer_data)

## for checking which columns have the most NA values
colSums(is.na(summer_data))

summer_data %>% 
  select(started_at, start_station_name, start_station_id, ended_at, end_station_name, end_station_id) %>%
  arrange(started_at) %>%
  drop_na() # returns 73% of initial data
  # group_by(started_at, ended_at) %>%
  # filter(is.na(start_station_name)) %>%
  # mutate(started_at = ymd(started_at),
  #           ended_at = ymd(ended_at))
  
dttm_sample <- summer_data %>%
  drop_na() %>%
  slice_head()

dttm_sample$ended_at - dttm_sample$started_at

## df for finding ride durations, no NA values
q2_time <- summer_data %>%
  select(member_casual, started_at, ended_at) %>%
  mutate(duration = ended_at - started_at) %>%
  filter(duration > 0) %>%
  arrange(-duration)

q2_time %>%
  filter(duration < 0) # there are 97 instances of negative trip durations
                       # just gonna go ahead and filter them out

## df for averages, maximums, minimums, median trip duration of member types
q2_stats <- q2_time %>%
  select(member_casual, duration) %>%
  mutate(across(duration, ~ as.numeric(., units = "mins"))) %>%
  group_by(member_casual) %>%
  summarise(avg_drtn = mean(duration),
            mdn_drtn = median(duration),
            max_drtn = max(duration),
            min_drtn = min(duration)) %>%
  ungroup()
## looks like avg and median durations weren't affected by filtering > 0
  
## df for finding ride distances, 3400 NA values from end_lat & end_lng  
q2_dist <- summer_data %>%
  select(member_casual, start_lat, start_lng, end_lat, end_lng) %>%
  # filter(is.na(end_lat)) 3,400 instances of NA end_lat/lng, not even 1%
  drop_na() %>%
  mutate(lat_1 = start_lat * 2 * pi/360,
         lon_1 = start_lng * 2 * pi/360,
         lat_2 = end_lat * 2 * pi/360,
         lon_2 = end_lng * 2 * pi/360,
         #converting to radians
         distance = 6371 * acos((sin(lat_2)*sin(lat_1))+cos(lat_2)*cos(lat_1)
                         *cos(lon_1-lon_2)))
  
q2_dist$distance[is.nan(q2_dist$distance)] <- 0.0

q2_dist_stats <- q2_dist %>%
  select(member_casual, distance) %>%
  group_by(member_casual) %>%
  summarise(avg_dist = mean(distance),
            mdn_dist = median(distance),
            max_dist = max(distance),
            min_dist = min(distance)) %>%
  ungroup()
  
## df for identifying trends in membership types and rideable types  
q2_type <- summer_data %>%
  select(rideable_type, member_casual) %>%
  group_by(member_casual) %>%
  count(rideable_type) %>%
  mutate(ride_number = n) %>%
  ungroup() %>%
  add_row(member_casual = 'member', rideable_type = 'docked_bike', n = 0,
          ride_number = 0) # for rough plot

q2_type %>%
  ggplot(aes(x=rideable_type, y=ride_number, fill=member_casual)) +
  geom_col(position = 'dodge') +
  scale_y_continuous(labels = seq(0, 700, 100), breaks = seq(0, 700000, 100000), expand = waiver()) +
  labs(
    x = NULL,
    y = 'Number of rides (x1,000)',
    title = 'Cyclistic ridership for Q2 of 2023'
  )
ggsave('rough_plots/q2_ridership_bar_plot.png')
  
## df for finding most frequented stations by riders  
# q2_lctn <- 
  summer_data %>%
  select(start_station_name, start_station_id, end_station_name, end_station_id) %>%
    drop_na() 
  
  
  

  
  
  