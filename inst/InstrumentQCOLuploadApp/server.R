require(shiny)
require(PipeFish)
library(shiny)
shinyServer(function(input, output) {
  observeEvent(input$UploadData, {
    outliers::upload_qc()
  })
})
