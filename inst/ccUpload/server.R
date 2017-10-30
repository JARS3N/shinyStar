library(shiny)
library(RMySQL)
library(asyr)
library(XML)


shinyServer(function(input, output,session) {

  session$onSessionEnded(function() {
    stopApp()
  })


  observeEvent(input$Quit, {
    stopApp(returnValue = invisible())
  })
  observe({
    output$MSG <- renderText("Ready")
    if(input$goButton > 0){
      output$MSG <- renderText("Select Directory")
      DIR<-choose.dir();
      output$MSG <- renderText("Munging Data...")

      DF<- do.call('rbind',
                   lapply(
                     lapply(
                       lapply(
                         list.files(path=DIR,pattern='asyr',full.names=TRUE),
                         XML::xmlTreeParse,
                         useInternalNodes=T
                       ),
                       asyr::process
                       ),
                     asyr::extract_wetQC
                   )
      )
    

      output$DF<-shiny::renderDataTable(DF)
      output$MSG <- renderText("Communicating with Database")
      output$MSG <- renderText("Writing to Database")
      asyr::UploadsCC(DF)
      output$MSG <- renderText("Complete")
    }})
