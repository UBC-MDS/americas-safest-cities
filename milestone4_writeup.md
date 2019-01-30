# Milestone 4

#### Talha Siddiqui, Mohamad Makkaoui

## Overview

For this project, we attempted to visualize the crime rates and numbers in some of the major cities in the United States. This dataset was compiled by the Marshall Project, and it has violent crime data from 2015 stretching back to 1975. The visualization has two tabs; the first a map of the continental US representing the number or rate of violent crime as circles overlayed on the coordinates of the city. Using a panel, the user has the ability to alternate between raw numbers or rate of crime per 100,000 civilians, choose a particular year using a dial in the side panel, and the type of crime using a drop down menu. In addition, there is a bar chart that highlights the worst 5 cities for that particular year/type of crime combination. The second tab is a line graph where the user can compare violent crime rates for up to 5 cities at once with a time range varying between 2 and 40 years previous to 2015. Above the line graph we added containers above the line graph to the show the change in the national average within the time frame selected.

## Changes from Milestone 3

* Map scaling

The biggest issue when working with a map visualisation is the scaling of the map on the different resolutions and sizes of computers that it's going to be viewed on. Previously we had been having trouble implementing the proper scaling with a static side panel. To solve this, we added a draggable panel and this allowed us to change the width parameter to 100%, which then adjusts for the different screen sizes. There is a stark difference in the way the map renders between milestone 3 and 4 with the latter having a much slicker and aesthetically pleasing look.

* Adding the cities rank

Previously, once a user clicked on a particular cities circle, it would give information such as the population and amount of crime. We added a rank by manipulating the data just before it renders such that the user is now able to see where a particular city ranks against the different cities for a particular year and type of crime.

* Number/Rate toggling for map

This was a wishlist feature that we had been trying to implement since the beginning on the map visualization. Previously the map only showed raw numbers of crime for the cities. This isn't a problem in and of itself, but it was generally leading to uninteresting results as New York City would almost always come out on top due to sheer amount of their population. Thus, we added the rates per 100,000 as an option that the user can toggle with for a specific year and type of crime. This led to much more interesting results, as with normalization we were able to capture a more accurate estimation of the danger that a city poses.

* Fixing bugs

Some bugs we encountered along the way were dividing by zeros that we had filled in in the data cleaning phase that was causing major issues with the rendering of the circles on the map. This was fixed by removing those values. Other small bugs were related to styling the app and functionality with some of the widgets. These were addressed for Milestone 4.

* Draggable panel in map

As mentioned in the map scaling point above, we added a draggable panel to make for a more aesthetically pleasing and well-scaled map.

* Addition of information on line graph

We added 3 containers that show the national average at the beginning of the time range and the national average in 2015, with the percentage change between the two. This gives the user an idea of where the selected cities are at compared to the national average. The national average is a statistic also compiled by the Marshall project that we hadn't used up until this point.

## Biggest challenges

* Map rendering issues

The biggest challenge faced was getting the data to render as intended on the map. Various bugs and issues came up along the way in the data wrangling/pipeline that resulted in inaccurate representation of the crime numbers/rates on the map. We found the values causing the errors and removed them to solve this issue. Also, another challenge was finding the right scaling for the circles such that they are not too large as to convey no information, nor are they too small for the user to see. In the end we settled on a good value that worked for both numbers and rates.

* Data cleaning

The dataset was generally organized and complete but slightly tricky to wrangle. For the purposes of our application, we had trouble dealing with cities that had duplicates as county names and trouble with some cities with missing data for random categories or years. Adding the coordinates data also led to some missing cities and/or creating duplicates (due to the nature of the join).

## Further improvements

* Add data explorer tab

For the future, we could improve the application by adding a tab that allows the user to explore the data in list form and filter and sort as they see fit. This may give the user more information than is currently being conveyed in the two tabs.

* Up to date crime data

The dataset we worked with has information up until 2015. There is more recent data available online for most of the cities that we are visualizing that we can augment to our data that would give a more relevant and up-to-date view of crime in the US.

* Data Cleaning

As mentioned in the biggest challenges faced, this took us a while to get around and even then the current solution is make-shift. For the future, we hope to improve the data cleaning pipeline such that there are no hidden NA's that could alter the representations of violent crime on the map. And also ensure that the counties are accounted for and not lost in the join as may the case currently.
