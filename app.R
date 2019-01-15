#
# America's Safest Cities
# Authors: Mohamad Makkaoui, Talha A. Siddiqui
#

library(shiny)
library(tidyverse)
library(leaflet)



#########################
# Define User Interface #
#########################

ui <- fluidPage(

    # Application title
    titlePanel("America's Safest Cities"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

#######################
# Define Server Logic #
#######################

server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
