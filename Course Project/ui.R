shinyUI(
    
    navbarPage("Performance of PSLE Students Scoring A* to C in Standard Mathematics",
        tabPanel("App",
            
            sidebarPanel (
                helpText("View charts or table entries relating to performance of Singapore primary school leavers."),
                
                uiOutput("year"),
                
                radioButtons("ethnicAll", "Display all ethnic options", choices=list("Yes", "No, I'll choose")),
                conditionalPanel(
                    condition = "input.ethnicAll != 'Yes'",
                    uiOutput("ethnic")
                )
            ),
            
            mainPanel(
                tabsetPanel(
                    tabPanel("Plot", plotOutput("plot", height="550px")),
                    tabPanel("Table", tableOutput("table"))
                )
            )
        ),
        tabPanel("Help",
            mainPanel(
                includeMarkdown("help.md")
            )
        )
    )
)