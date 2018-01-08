pKa_server<-function(){


require(shiny)
require(asyr)
require(rmarkdown)
require(xprt)
shinyServer(function(input, output, session) {

  session$onSessionEnded(function() {
    stopApp()
  })

  observeEvent(input$Quit, {
    stopApp(returnValue = invisible())
  })

  observe({
    if(input$BB > 0 ){
      DIR<-choose.dir()
      if(input$CB==TRUE){xprt::xfd_to_asyr(DIR)}
      asyr::asyr_pKa(input$pHFluor,input$MFBatch,input$Platform,DIR)
    }
  })
})


}
