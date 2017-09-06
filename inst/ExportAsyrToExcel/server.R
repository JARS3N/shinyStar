library(shiny)
library(PipeFish)
shinyServer(function(input,output,session) {

  session$onSessionEnded(function() {
    stopApp()
  })


  observeEvent(input$Quit, {
    stopApp(returnValue = invisible())
  })
  stuffHappens<-  observeEvent(input$EXP,
                               {fldr<-choose.dir()
                               PipeFish::Outandsave(fldr)
                               output$session <- renderText("Script Complete")
                               })
})
