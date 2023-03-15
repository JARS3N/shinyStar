pKa_ui<-function(){
require(shiny)
shinyUI(
  fluidPage(
    titlePanel("seastar::pKa from asyr files"),
    br(),
    mainPanel(
      textInput('pHFluor',"pH Fluorophore", value = "Fluorophore_Validation_pKa", width = NULL),
      textInput('MFBatch',"Multi Fluor Batch", value = "NA", width = NULL),
      br(),
      shiny::fileInput("filein","upload asyr/xflr files",multiple=T),
      #actionButton("BB","Run Analysis"),
      shiny::downloadButton("BB","generate pdf"),
      br(),
      actionButton("Quit", "Quit"),
      br(),
      textOutput("session"),
      tableOutput("test1")
    )
    
  )
)
}
