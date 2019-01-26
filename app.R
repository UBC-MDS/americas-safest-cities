#
# America's Safest Cities
# Authors: Mohamad Makkaoui, Talha A. Siddiqui
#

library(shiny)
library(tidyverse)
library(leaflet)
library(shinythemes)
library(plotly)
library(shinyWidgets)
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
    
     #Application title
    titlePanel("America's Most Dangerous Cities"),
    
     #Application theme
    theme = shinytheme("readable"),
    
    
    tabsetPanel(
    #navbarPage("Crime",    
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
                         choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault")),
                         helpText("Top 5 Cities with the highest crime rates"),
                         switchInput(value = TRUE,onLabel = "Number",offLabel = "Rate",inputId = "switchInput"),
                         plotOutput("panelPlot")
                     ),
                     mainPanel(
                  #div(class="outer",
                      leafletOutput("map", width=1000, height=700)
                  #  absolutePanel(
                  #    id = "bar",class="panel panel-default",width = 300,height = "auto",fixed = TRUE,
                  #    draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                  #    selectInput("yearInput", "Year",
                  #    choices = c(1975:2015), selected = 2015),
                  #    selectInput("crimeInput", "Type of Violent crime",
                  #    choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault")),
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
                                         choices = c(2,5,10,20,40), selected = 20),
                             selectInput("crimeTrendInput", "Type of Violent crime",
                                         choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault")),
                             pickerInput(inputId = "cityInput",label="Select up to 5 cities to compare",choices = unique(data$city),multiple = TRUE,options = list('actions-box'=TRUE,"max-options"=5),selected = c("Chicago","Los Angeles"))
                             #selectInput("city1Input", "Selected Cities", choices = data$city, selected = data$city[1]),
                             #selectInput("city2Input", "", choices = data$city, selected = data$city[2]),
                             #selectInput("city3Input", "", choices = data$city, selected = data$city[3]),
                             #selectInput("city4Input", "", choices = data$city, selected = data$city[4]),
                             #selectInput("city5Input", "", choices = data$city, selected = data$city[5])
                         ),

                         # Show a plot of the generated distribution
                         mainPanel(
                             plotlyOutput("trendPlot")
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
        
      #  display <- leaf_data$Numbers
      #  if(input$switchInput == TRUE){
      #    display <- Numbers
      #  } else{
      #    display <- Rates
      #  }
        
        leaflet(data = leaf_data,options = leafletOptions(minZoom = 4)) %>%
            addProviderTiles(providers$Hydda.Base) %>%
            addProviderTiles(providers$Stamen.TonerLite,options = providerTileOptions(opacity = 0.35)) %>%
            setView(lng = -93.82, lat = 37.44, zoom = 4) %>%
            #setMaxBounds(lng1 = -93.45,lat1 = 37.15,lng2 = -94.05,lat2 = 37.75) %>%
            addCircleMarkers(
                ~long, ~lat, 
                radius =~(Numbers * 30/max(Numbers)),
                color = "red",
                weight = 3,
                popup = ~paste(
                    city,
                    "</br><b>Crime:</b>",crime_type,
                    "</br><b>Year:</b>",year,
                    "</br><b>Total:</b>",round(Numbers)
                ),
                fillOpacity = 0.5
            )
    })
    
    output$panelPlot <- renderPlot({
      data %>% filter(crime_type==input$crimeInput,year==input$yearInput) %>%
        arrange(desc(Rates))%>%
        slice(1:5)%>%
        ggplot(aes(y=Rates,x=reorder(city,Rates),fill="red"))+
        geom_bar(stat = "identity")+
        coord_flip()+
        xlab("Rates per 100,000 citizens")+
        theme_classic()+
        theme(axis.text.y = element_text(color = "grey20", size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"),
              axis.text.x = element_text(color = "grey20", size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"),
axis.ticks.x = element_blank(),axis.ticks.y = element_blank(),axis.title.y=element_blank(),legend.position = "none",axis.line.x = element_blank(),axis.line.y = element_blank())
        
    },height = 250,width = "auto")
    
    output$trendPlot <- renderPlotly({
        
        p <- data %>%
            arrange(year) %>%
            group_by(crime_type) %>%
            filter(city == input$cityInput,
                   year >= (2015-as.numeric(input$durationInput)),
                   crime_type == input$crimeTrendInput) %>% 
          ggplot(aes(x = year, y = Rates, colour = city)) +
            geom_path() +
            labs(
                title = 'Comparison of Violent Crime in Selected Cities',
                x = 'Years',
                y = 'Crime per 100k Population',
                legend = 'Cities'
            )
        ggplotly(p, tooltip = c('label', 'x', 'y', 'colour'))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)