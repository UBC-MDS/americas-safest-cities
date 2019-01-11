# America's Safest Cities
#### Shiny App to explore and compare America's safest cities.

## Overview

Crime continues to be on the rise in our streets! Or so has been the narrative that's been thrown around by the media for as long as anyone can remember. 

And yet here we are in 2019, with people and life going on as normal for the majority of Americans. So what actually did happen to violent crime in the USA?

The Marshall Project, a nonprofit, nonpartisan online journalism organization, based out of New York City, have compiled a dataset that contains the numbers and rates of violent crime totals for the major cities in the US spanning the last 40 years.

Using this dataset, our aim is to develop a visualization that can highlight the difference over time in crime rates in different cities and also to compare between the cities. The goal is present this information in an easy-to-digest manner for the general public, such that everyday Americans can use the interactive map to explore violent crime statistics from major cities. The accompanying charts allow easy comparison of violent crime trends for selected cities.


## Description of the data

The dataset that we’ll be using is the one compiled by the Marshall project detailing the number and rate of violent crimes that occurred in 68 cities in the United States between 1975 and 2015. The four types of violent crime that they have compiled information on are:

1) Homicide
2) Rape
3) Robbery
4) Aggravated Assault

The information on each type of crime for each city in a specific year is presented in raw format (or totals), and is also presented in normalized format that is the rate of the type of crime per 100,000 people. The two of these in tandem could give us a clearer indication of whether a city is trending upwards or downwards with regards to violent crime better than totals only, as the normalized numbers adjust for size of population. For this they have included in the dataset the population of the city that adjusts year after year with updated population totals.

Specifically, they have collected information on 17 fields, some derived from others and they are compiled in the table below:

 | Name of field | Description |
 | --------|-------------------------|
 | ORI | Unique Identifier |
 | year | The year the statistics are compiled for | 
 | department_name | City name |
 | total_pop | Total population |
 | homs_sum | Total number of homicides |
 | rape_sum | Total number of rapes |
 | rob_sum | Total number of robberies |
 | agg_ass_sum | Total number of aggravated assault |
 | homs_per_100k   | Homicides per 100,000 people |
 | rape_per_100k | Rapes per 100,000 people |
 | rob_per_100k | Robberies per 100,000 people |
 | agg_ass_per_100k | Agg. Assault per 100,000 people |
 | violent_crime    | Total number of violent crime |
 | violent_per_100k | Violent crime per 100,000 people |

 For the purposes of this investigation, we will disregard the 'source' and 'url' columns.

## Usage scenarios & tasks
 
Jim and Sally are new parents looking to move to a safe city in the United States to raise their daughter. For major U.S. cities (population over 250,000), they want to [explore] violent crime figures, [compare] these figures for their favorite cities and [identify] the overall safest cities to choose the ideal city as their future hometown. Jim and Sally can use the “America’s Safest Cities” app for their search, which presents information in an interactive map and accompanying charts. The interactive map along with suggested safest cities helps them explore different cities around the country while considering other factors such as job prospects, diversity, proximity to their families and hometowns. They shortlist 4 cities of their choice to compare in detail. They filter the comparison charts for the shortlisted cities which helps provide a detailed breakdown of violent crime in those cities. They contrast violent crime statistics of the shortlisted cities against the safest cities in the United States.
