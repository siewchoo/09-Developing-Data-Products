## Load the required libraries and data
library(xlsx)
library(reshape2)
library(ggplot2)
library(scales)

## App assumes that you have downloaded the data file
##      http://data.gov.sg/Agency_Data/MOE/0301180000000011808D.xlsx
## and placed it in the same directory as this script.
## When the app starts up on the Shiny server, a read-only copy of the dataset will be loaded.
## This happens only once and the dataset then becomes visible across all user sessions.
psle <- read.xlsx("0301180000000011808D.xlsx", sheetIndex = 1, colIndex = 1:6, rowIndex = 3:21)

psle <- psle[-1, ]                                  ## Remove redundant "Percent" row.
colnames(psle) <- c("Year", colnames(psle)[-1])     ## Rename column 1's column names from NA to year.
psle <- melt(psle, id="Year")                       ## Make the dataset long and narrow.
colnames(psle) <- c("Year", "Ethnic", "Percent")    ## Tidy up the column names.

psle$Year <- as.integer(psle$Year)                  ## Convert variable to integer.
psle$Percent <- as.numeric(psle$Percent)            ## Convert variable to decimal.

shinyServer(function(input, output, session) {
    
    ethnicOptions <- levels(psle$Ethnic)  
    
    ## Sync the 'Ethnic option' radio buttons and checkbox selection.
    observe({
        if (input$ethnicAll == 'Yes')
            updateCheckboxGroupInput(session=session, inputId="ethnic", selected="Overall")
        else {
            if (length(input$ethnic) == length(ethnicOptions))
                updateRadioButtons(session, "ethnicAll", selected="Yes")
            else
                return
        }
    })
    
    ## Contruct the 'Year' dropdown box and its selection list.
    output$year <- renderUI({
        yearOptions <- c("All", sort(unique(psle$Year)))
        selectInput("year", "Choose a year to display", yearOptions)
    })

    ## Construct the 'Ethnic option' checkboxes.
    output$ethnic <- renderUI({        
        checkboxGroupInput("ethnic", "Display for:", choices=ethnicOptions, selected="Overall")
    })
        
    outputData <- reactive({
        if (is.null(input$year))
            return()
        
        ## Extract the relevant observations from the dataframe.
        if (grepl(input$year, "all", ignore.case=T)) {
            if (grepl(input$ethnicAll, "yes", ignore.case=T))
                psle
            else
                psle[psle$Ethnic %in% input$ethnic, ]            
        }
        else {
            if (grepl(input$ethnicAll, "yes", ignore.case=T))
                psle[psle$Year==input$year, ]
            else
                psle[psle$Year==input$year & psle$Ethnic %in% input$ethnic, ]
        }
    })
    
    ## Output the table entries.
    output$table <- renderTable({
        outputData()
    })
    
    ## Output the plot.
    output$plot <- renderPlot({
        if (is.null(input$year))
            return()

        ## Prepare the axis and the tick parameter values.
        lowerLimit <- round(min(outputData()$Percent)-5, -1)
        upperLimit <- round(max(outputData()$Percent)+5, -1)
        yAxisBy <- 5
        diff <- upperLimit-lowerLimit
        if (diff <= 10)
            yAxisBy <- 1
        else {
            if (diff <= 30)
                yAxisBy <- 2
        }
        
        if (grepl(input$year, "all", ignore.case=T)) {
            ## Create line chart.
            p <- ggplot(outputData(), aes(x=Year, y=Percent, colour=Ethnic, group=Ethnic)) + 
                        geom_point(size=3)+ geom_line() +
                        scale_x_continuous(breaks=seq(min(outputData()$Year), max(outputData()$Year), by=1)) +
                        theme(axis.text.x = element_text(angle=30, hjust=1)) +
                        scale_y_continuous(breaks=seq(lowerLimit, upperLimit, by=yAxisBy))
        }
        else {
            ## Create histogram.
            p <- ggplot(outputData(), aes(x=as.character(Year), y=Percent, fill=Ethnic, group=Ethnic)) + 
                        geom_bar(stat="identity", position="dodge") 
        }
    
        p <- p + labs(x="Year", y="Percentage (%)") +
                 coord_cartesian(ylim=c(lowerLimit, ifelse(upperLimit>100, 100, upperLimit)))
        print(p)
    })
})