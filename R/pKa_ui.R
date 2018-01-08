pKa_ui<-function(){

require(shiny)

shinyUI(fluidPage(
  titlePanel("seastar::pKa from asyr files"),
  br(),
  mainPanel(
    textInput('pHFluor',"pH Fluorophore", value = "Fluorophore_Validation_pKa", width = NULL),
    textInput('MFBatch',"Multi Fluor Batch", value = "NA", width = NULL),
    selectInput("Platform", label = "Platform",
                choices = list("96" = 1, "24" = 2, "XFp"=3),
                selected = 1),
    checkboxInput("CB", label = "Export from .XFD to .asyr", value = FALSE),
    br(),
    actionButton("BB","Run Analysis"),
    br(),
    actionButton("Quit", "Quit"),
    br(),
    textOutput("session"),
    tableOutput("test1")
  )

)

}
