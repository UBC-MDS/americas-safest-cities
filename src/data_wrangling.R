library(dplyr)
library(tidyverse)

crime <- read.csv("ucr_crime_1975_2015.csv")
latlon <- read.csv("1000-largest-us-cities-by-population-with-geographic-coordinates.csv",sep=";")

#Clean city names and select important columns
crime_clean <- crime %>%
  filter(department_name != "National") %>% 
  separate(col=department_name,into=c("city","state"),sep=",") %>%
  select(ORI,year,city,total_pop,homs_sum,rape_sum,rob_sum,agg_ass_sum,violent_crime) %>%
  replace(is.na(.), 0)

crime_clean$city[crime_clean$city=="New York City"] <- "New York"

#Cleaning the coordinate/state dataframe
latlon <- latlon %>%
  select(City,State,Coordinates,Population) %>%
  filter(Population > 190000) %>%
  select(city=City,state=State,Coordinates)

#Left Joining the coordinates table to the crime dataframe and cleaning
city_merged <- crime_clean %>%
  left_join(latlon,by="city") %>%
  na.omit() %>%
  separate(col=Coordinates,into=c("lat","long"),sep=", ") %>%
  select(year,city,state,lat,long,total_pop,violent_crime,homs_sum,rape_sum,rob_sum,agg_ass_sum)

#To write
write_csv(city_merged,"data_cleaned.csv")

#To check
#my_table <- city_merged %>%
#  group_by(year) %>%
#  summarise(n=n())