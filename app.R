#
# America's Safest Cities
# Authors: Mohamad Makkaoui, Talha A. Siddiqui
#

library(shiny)
library(tidyverse)
library(leaflet)
library(shinythemes)
theme_set(theme_light())

crime <- tibble(crime_numbers = c("violent_crime","homs_sum","rape_sum","rob_sum","agg_ass_sum"),
                crime_type = c("All","Homicide","Rape","Robbery","Aggravated Assault"))

raw_data <- read_csv('data/data_cleaned.csv')

data <- raw_data %>% 
    gather(crime_numbers, Numbers, 7:11) %>% 
    select(year, city, state, lat, long,
           total_pop, crime_numbers, Numbers) %>% 
    inner_join(crime) %>% 
    mutate(Rates = 100000 * Numbers / total_pop)

#########################
# Define User Interface #
#########################

ui <- fluidPage(
    
    # Application title
    titlePanel("America's Safest Cities"),
    
    # Application theme
    theme = shinytheme("readable"),
    
    
    tabsetPanel(
        
        # Interactive map
        tabPanel("Interactive Map",
                 fluidRow(
                     sidebarPanel(
                         position = "right",
                         width = 3,
                         helpText("Click on the bubble to view data"),
                         selectInput("yearInput", "Year",
                                     choices = c(1975:2015), selected = 2015),
                         selectInput("crimeInput", "Type of Violent crime",
                                     choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault"))
                         
                     ),
                     mainPanel(
                         leafletOutput("map", width=800, height=600)
                     )
                 )
                 
        ),
        
        # Data tab
        tabPanel("Trend Chart",
                 fluidRow(
                     sidebarLayout(
                         sidebarPanel(
                             position = "right",
                             width = 3,
                             selectInput("durationInput", "Years",
                                         choices = c(2,5,10,20,40), selected = 5),
                             selectInput("crimeTrendInput", "Type of Violent crime",
                                         choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault")),
                             selectInput("city1Input", "Selected Cities", choices = data$city, selected = data$city[1]),
                             selectInput("city2Input", "", choices = data$city, selected = data$city[2]),
                             selectInput("city3Input", "", choices = data$city, selected = data$city[3]),
                             selectInput("city4Input", "", choices = data$city, selected = data$city[4]),
                             selectInput("city5Input", "", choices = data$city, selected = data$city[5])
                         ),

                         # Show a plot of the generated distribution
                         mainPanel(
                             plotOutput("trendPlot")
                         )
                     )
                 )
        )
        
    )
)

#######################
# Define Server Logic #
#######################

server <- function(input, output) {
    
    output$map <- renderLeaflet({
        
        # Leaflet dataframe
        leaf_data <- data %>% 
            arrange(year) %>% 
            group_by(city, crime_type) %>% 
            filter(year == input$yearInput, 
                   crime_type == input$crimeInput) %>% 
            filter(city != "National")
        
        
        leaflet(data = leaf_data) %>%
            addProviderTiles(providers$Stamen.TonerLite,
                             options = providerTileOptions(noWrap = TRUE)
            ) %>%
            setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
            addTiles() %>% 
            addCircleMarkers(
                ~long, ~lat, 
                radius =~(Numbers * 30/max(Numbers)), 
                popup = ~paste(
                    "</br><b>Crime:</b>",crime_type,
                    "</br><b>City:</b>",city,
                    "</br><b>Year:</b>",year,
                    "</br><b>Total:</b>",round(Numbers)
                ),
                fillOpacity = 0.5
            )
    })
    
    output$trendPlot <- renderPlot({
        
        selected_cities <- c(input$city1Input, input$city2Input, input$city3Input,
                             input$city4Input, input$city5Input)

        data %>%
            arrange(year) %>%
            group_by(crime_type) %>%
            filter(city == selected_cities,
                   year >= (2015-as.numeric(input$durationInput)),
                   crime_type == input$crimeTrendInput) %>%
            ggplot(aes(x = year, y = Rates, colour = city)) +
            geom_line(size = 2) + 
            labs(
                title = 'Comparison of Violent Crime in Selected Cities',
                subtitle = '',
                x = 'Years',
                y = 'Crime per 100k Population',
                legend = 'Cities'
            )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)