library(shiny)
library(lightleak)
library(xprt)
shinyServer(function(input, output,session) {
  session$onSessionEnded(function() {
    stopApp()
  })
  observeEvent(input$send,{
    print("ok")
    dir <- choose.dir()
    if(input$CB==TRUE){xprt::asyr_to_xl(dir)}
    if (!is.na(dir)) {
      fls<-list.files(path=dir,full.names = T,pattern = 'xlsx')
      lapply(
        lapply(fls,
               lightleak::munge),
        lightleak::upload
        )
      message("complete")
    }else{
      message('no directory selected')
    }
  }


  )

})
