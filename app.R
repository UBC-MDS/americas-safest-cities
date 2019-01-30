#
# America's Most Dangerous Cities
# Authors: Mohamad Makkaoui, Talha A. Siddiqui
#

library(shiny)
library(tidyverse)
library(leaflet)
library(shinythemes)
library(RColorBrewer)
library(plotly)
library(shinyWidgets)
require(shinydashboard)
library(V8)
library(shinyjs)


theme_set(theme_light())

############################
# Data Import & Processing #
############################

crime <-
  tibble(
    crime_numbers = c(
      "violent_crime",
      "homs_sum",
      "rape_sum",
      "rob_sum",
      "agg_ass_sum"
    ),
    crime_type = c("All", "Homicide", "Rape", "Robbery", "Aggravated Assault")
  )

raw_data <- read_csv('data/data_cleaned.csv')

# Creating the primary dataframe that will be used throughout the app

data <- raw_data %>%
  gather(crime_numbers, Numbers, 7:11) %>%
  select(year, city, state, lat, long,
         total_pop, crime_numbers, Numbers) %>%
  inner_join(crime) %>%
  mutate(Rates = 100000 * Numbers / total_pop) %>%
  replace(is.na(.), 0) %>%
  filter(!(city == "Aurora" & state == "Illinois")) %>%
  filter(!(city == "Columbus" & state == "Georgia"))

#########################
# Define User Interface #
#########################

ui <- fluidPage(theme = shinytheme("readable"),
                tabsetPanel(
                  # Interactive map
                  tabPanel(
                    "Interactive Map",
                    div(
                      class = "outer",
                      tags$head(# Include custom CSS necessary for full width map display
                        includeCSS("styles.css")),
                      leafletOutput("map", width = "100%", height = "100%"),
                      absolutePanel(
                        id = "controls",
                        class = "panel panel-default",
                        fixed = TRUE,
                        draggable = TRUE,
                        top = 45,
                        left = "auto",
                        right = 30,
                        bottom = 'auto',
                        width = 350,
                        height = "auto",
                        h3("How Safe is America?"),
                        #p("Click on a city's bubble to view details"),
                        radioGroupButtons(
                          inputId = 'radioInput',
                          label = NULL,
                          choices = c('Rates','Numbers'),
                          selected = 'Rates',
                          status = 'danger', # 'info' 'danger'
                          justified = TRUE
                        ),
                        knobInput(
                          inputId = "yearInput",
                          label = "Use knob to change year",
                          value = 2015,
                          min = 1975,
                          max = 2015,
                          displayPrevious = TRUE,
                          lineCap = "default",
                          fgColor = '#F8766D',
                          inputColor = 'red',
                          angleArc = 350,
                          width = '100%'
                          # height = '95%'
                        ),
                        #p("Use the knob above to change year"),
                        selectInput(
                          "crimeInput",
                          "Type of Violent crime",
                          choices = c("All", "Homicide", "Rape", "Robbery", "Aggravated Assault")
                        ),
                        helpText("Worst 5 Cities Ranked"),
                        # Calling panel plot for 5 worst cities
                        plotOutput("panelPlot")
                      )
                      
                    )
                  ),
                  
                  # Compare Cities
                  tabPanel(
                    "Comparison",
                    dashboardPage(
                      sidebar = (dashboardSidebar(
                        sidebarMenu(
                          position = "center",
                          width = 4,
                          radioGroupButtons(
                            "durationInput",
                            label = HTML('<p style="color:black;">No. of Years before 2015</p>'),
                            choices = c(2, 5, 10, 20, 40),
                            justified = TRUE,
                            status = "info",
                            selected = 20
                          ),
                          selectInput(
                            "crimeTrendInput",
                            HTML('<br><p style="color:black;">Type of Violent crime</p>'),
                            choices = c("All", "Homicide", "Rape", "Robbery", "Aggravated Assault")
                          ),
                          pickerInput(
                            inputId = "cityInput",
                            label = HTML(
                              '<br><p style="color:black;">Select up to 5 cities to compare</p>'
                            ),
                            choices = unique(data$city),
                            multiple = TRUE,
                            options = list('actions-box' = TRUE, "max-options" = 5),
                            selected = c("Chicago", "Los Angeles")
                          )
                        )
                      )),
                      header = (dashboardHeader(title = "How Safe is America?")),
                      body = dashboardBody(
                        # CSS to customize appearance
                        tags$head(tags$style(
                          HTML(
                            '/* main sidebar */
                                .skin-blue .main-sidebar {
                                background-color: #eaeaea;
                                }

                                /* body */
                                .content-wrapper, .right-side {
                                background-color: #FFFFFF;
                                }'
                          )
                        )),
                        # shinyjs to hide collapsable head
                        shinyjs::useShinyjs(),
                        extendShinyjs(text = "shinyjs.hidehead = function(parm){
                                    $('header').css('display', parm);}"),
                        fluidRow(
                          valueBoxOutput("value1", width = 4),
                          valueBoxOutput("value2", width = 4),
                          valueBoxOutput("value3", width = 4)
                        ),
                        fluidRow(plotlyOutput("trendPlot"))
                      )
                      
                    )
                  )
                  
                ))

#######################
# Define Server Logic #
#######################

server <- function(input, output) {
  output$map <- renderLeaflet({
    # Leaflet dataframe selection based Rates / Numbers
    leaf_data_numbers <- data %>%
      filter(year == input$yearInput,
             crime_type == input$crimeInput) %>%
      mutate(Choice = Numbers) %>%
      mutate(rank = dense_rank(desc(Choice)))
    
    leaf_data_rates <- data %>%
      filter(year == input$yearInput,
             crime_type == input$crimeInput) %>%
      mutate(Choice = Rates) %>%
      mutate(rank = dense_rank(desc(Choice)))
    
    if (input$radioInput == 'Numbers') {
      leaf_data <- leaf_data_numbers
    } else {
      leaf_data <- leaf_data_rates
    }
    
    # -------------------------
    # Rendering interactive map
    # -------------------------
    
    leaflet(data = leaf_data, options = leafletOptions(minZoom = 4)) %>%
      addProviderTiles(providers$Hydda.Base) %>%
      addProviderTiles(providers$Stamen.TonerLite, options = providerTileOptions(opacity = 0.35)) %>%
      setView(lng = -83.82,
              lat = 37.44,
              zoom = 4) %>%
      addCircleMarkers(
        ~ long,
        ~ lat,
        radius =  ~ (Choice * 25 / max(Choice)),
        color = 'red',
        weight = 3,
        popup = ~ paste(
          city,
          "</br><b>Rank:</b>",
          rank,
          "</br><b>Crime:</b>",
          crime_type,
          "</br><b>Year:</b>",
          year,
          "</br><b>Total:</b>",
          round(Choice)
        ),
        fillOpacity = 0.5
      )
  })
  
  output$panelPlot <- renderPlot({
    leaf_data_numbers <- data %>%
      filter(year == input$yearInput,
             crime_type == input$crimeInput) %>%
      mutate(Choice = Numbers) %>%
      mutate(rank = dense_rank(desc(Choice)))
    
    leaf_data_rates <- data %>%
      filter(year == input$yearInput,
             crime_type == input$crimeInput) %>%
      mutate(Choice = Rates) %>%
      mutate(rank = dense_rank(desc(Choice)))
    
    if (input$radioInput == 'Numbers') {
      leaf_data_2 <- leaf_data_numbers
    } else {
      leaf_data_2 <- leaf_data_rates
    }
    
    
    leaf_data_2 %>%
      arrange(desc(Choice)) %>%
      slice(1:5) %>%
      ggplot(aes(
        y = Choice,
        x = reorder(city, Choice),
        fill = "red"
      )) +
      geom_bar(stat = "identity") +
      coord_flip() +
      xlab("Violent Crime Numbers") +
      theme_classic() +
      theme(
        axis.text.y = element_text(
          color = "grey20",
          size = 12,
          angle = 0,
          hjust = 1,
          vjust = 0,
          face = "plain"
        ),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        legend.position = "none",
        axis.line.x = element_blank(),
        axis.line.y = element_blank()
      )
    
  }, height = 150, width = "auto")
  
  
  # -----
  # 3 KPI
  # -----
  
  js$hidehead('none')
  
  output$value1 <- renderValueBox({
    national_average_earlier <-
      data %>% filter(year == (2015 - max(as.numeric(
        input$durationInput
      ))),
      crime_type == input$crimeTrendInput) %>%
      summarise(value = mean(Rates))
    
    
    valueBox(
      formatC(
        national_average_earlier$value,
        format = "d",
        big.mark = ','
      ),
      icon = icon("skull", lib = 'font-awesome'),
      paste((2015 - max(
        as.numeric(input$durationInput)
      )), 'National Average for', input$crimeTrendInput),
      color = 'olive'
    )
  })
  
  output$value2 <- renderValueBox({
    national_average_2015 <- data %>% filter(year == 2015,
                                             crime_type == input$crimeTrendInput)
    
    national_average_earlier <-
      data %>% filter(year == (2015 - max(as.numeric(
        input$durationInput
      ))),
      crime_type == input$crimeTrendInput)
    
    national_delta <-
      (mean(national_average_2015$Rates) - mean(national_average_earlier$Rates)) /
      mean(national_average_earlier$Rates)
    
    valueBox(
      formatC(paste(round(
        national_delta * 100, 1
      ), '%'), big.mark = ','),
      icon = icon("percentage", lib = 'font-awesome'),
      paste('Change in National Average for', input$crimeTrendInput),
      color = 'light-blue'
    )
  })
  
  output$value3 <- renderValueBox({
    national_average_2015 <- data %>%
      filter(year == 2015,
             crime_type == input$crimeTrendInput) %>%
      summarise(value = mean(Rates))
    
    valueBox(
      formatC(
        national_average_2015$value,
        format = "d",
        big.mark = ','
      ),
      icon = icon("fingerprint", lib = 'font-awesome'),
      paste('2015 National Average for', input$crimeTrendInput),
      color = "yellow",
      width = 6,
    )
  })
  
  # ---------------------------------------------
  # Line chart comparing crime in selected cities
  # ---------------------------------------------
  
  output$trendPlot <- renderPlotly({
    p <- data %>%
      arrange(year) %>%
      group_by(crime_type) %>%
      filter(city == input$cityInput,
             year >= (2015 - max(as.numeric(
               input$durationInput
             ))),
             crime_type == input$crimeTrendInput) %>%
      ggplot(aes(x = year, y = Rates, color = city)) +
      geom_path() +
      scale_colour_brewer(palette = "Set1") +
      labs(
        title = 'Comparison of Violent Crime Rates in Selected Cities',
        subtitle = '',
        y = 'Crime per 100k Population',
        legend = 'Cities'
      ) +
      theme(
        title = element_text(size = 12),
        legend.title = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_text(size = 16),
        axis.text.y = element_text(size = 16),
        legend.text = element_text(size = 10)
      )
    ggplotly(p, tooltip = c('label', 'x', 'y', 'colour'))
  })
}

# Run the application
shinyApp(ui = ui, server = server)
