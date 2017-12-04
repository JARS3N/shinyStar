library(outliers)
library(shiny)
shinyServer(function(input, output) {
  observeEvent(input$UploadData, {
    outliers::upload_qc()
  })
})
