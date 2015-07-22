## Load the required libraries and data
library(xlsx)
library(shiny)
library(ggplot2)


## Define UI for application that plots random distributions
shinyUI(pageWithSidebar(
    ## Application title
    headerPanel("PSLE Results"),
    
    ## Sidebar with a slider input for number of observations
    sidebarPanel (
        helpText("Create bar charts with information
                 from the Ministry of Education of Singapore."),
        
        uiOutput("year"),
        
        radioButtons("ethnicAll", "Display all ethnic options", choices=list("Yes", "No, I'll choose")),
        conditionalPanel(
            condition = "input.ethnicAll != 'Yes'",
            uiOutput("ethnic")
        )
    ),
    
    ## Show a plot of the generated distribution
    mainPanel(
        tabsetPanel(
            tabPanel("Plot", plotOutput("plot", height="550px")),
            tabPanel("Table", tableOutput("table"))
        )
    )
))