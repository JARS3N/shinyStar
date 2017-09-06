library(shiny)

shinyUI(fluidPage(
  titlePanel("PipeFish::Outliers"),
  br(),
  mainPanel(
    textInput('expnm',"Name of Experiment", value = "OutlierAnalysis", width = NULL),
    checkboxInput("CB", label = "Export from .Asyr", value = FALSE),
    br(),
    actionButton("BB","Run Analysis"),
    br(),
    actionButton('Quit','Quit',icon=icon('remove-sign',lib='glyphicon')),
    br(),br(),
    textOutput("session"),
    tableOutput("test1")
  )

)
)
