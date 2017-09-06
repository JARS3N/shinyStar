require(shiny)
require(PipeFish)
library(shiny)
shinyServer(function(input, output) {
  observeEvent(input$UploadData, {
    PipeFish::uploadInstQCOL()
  })
})
