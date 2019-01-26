#
# America's Safest Cities
# Authors: Mohamad Makkaoui, Talha A. Siddiqui
#

library(shiny)
library(tidyverse)
library(leaflet)
library(shinythemes)
library(RColorBrewer)
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
        # Interactive map
        tabPanel("Interactive Map",
                 fluidRow(
                     sidebarPanel(
                         position = "right",
                         width = 3,
                         helpText("Click on the bubble to view crime numbers"),
                         sliderInput("yearInput","Year",min = 1975,max=2015,value = 2015,sep=""),
                         selectInput("crimeInput", "Type of Violent crime",
                         choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault")),
                         helpText("Worst 5 Cities Ranked"),
                         # Calling panel plot
                         plotOutput("panelPlot")
                     ),
                     mainPanel(
                      leafletOutput("map", width=1200, height=700)
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
                             checkboxGroupButtons(
                               "durationInput",label="Years",choices = c(2,5,10,20,40),justified = TRUE,status = "primary",selected = 20
                             ),
                             
                             selectInput("crimeTrendInput", "Type of Violent crime",
                                         choices = c("All","Homicide", "Rape","Robbery","Aggravated Assault")),
                             pickerInput(inputId = "cityInput",label="Select up to 5 cities to compare",choices = unique(data$city),multiple = TRUE,options = list('actions-box'=TRUE,"max-options"=5),selected = c("Chicago","Los Angeles"))
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
        
        leaflet(data = leaf_data,options = leafletOptions(minZoom = 4)) %>%
            addProviderTiles(providers$Hydda.Base) %>%
            addProviderTiles(providers$Stamen.TonerLite,options = providerTileOptions(opacity = 0.35)) %>%
            setView(lng = -93.82, lat = 37.44, zoom = 4) %>%
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
        arrange(desc(Numbers))%>%
        slice(1:5)%>%
        ggplot(aes(y=Numbers,x=reorder(city,Numbers),fill="red"))+
        geom_bar(stat = "identity")+
        coord_flip()+
        xlab("Violent Crime Numbers")+
        theme_classic()+
        theme(axis.text.y = element_text(color = "grey20", size = 12, angle = 0, hjust = 1, vjust = 0, face = "plain"),axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),axis.ticks.y = element_blank(),axis.title.y=element_blank(),axis.title.x=element_blank(),legend.position = "none",axis.line.x = element_blank(),axis.line.y = element_blank())
        
    },height = 250,width = "auto")
    
    output$trendPlot <- renderPlotly({

        #plotly(
            p <- data %>%
            arrange(year) %>%
            group_by(crime_type) %>%
            filter(city == input$cityInput,
                   year >= (2015-max(as.numeric(input$durationInput))),
                   crime_type == input$crimeTrendInput) %>%
            ggplot(aes(x = year, y = Rates, color = city)) +
            geom_path() + 
            scale_colour_brewer(palette="Set1") +
            labs(
                title = 'Comparison of Violent Crime Rates in Selected Cities',
                subtitle = '',
                y = 'Crime per 100k Population',
                legend = 'Cities'
            ) +
            theme(title=element_text(size=12),legend.title = element_blank(),axis.title.x = element_blank(),axis.text.x = element_text(size = 16),axis.text.y = element_text(size=16),legend.text = element_text(size=10)
                    )
            ggplotly(p,tooltip = c('label','x','y','colour'))
              
        #)
        
    })
}

# Run the application 
shinyApp(ui = ui, server = server)