library(shiny)
library(PipeFish)
shinyServer(function(input, output,session) {
  session$onSessionEnded(function() {
    stopApp()
  })
  observeEvent(input$send,{
    print("ok")
    dir <- choose.dir()
    if(input$CB==TRUE){PipeFish::XLSXos(dir)}
    if (!is.na(dir)) {
      fls<-list.files(path=dir,full.names = T,pattern = 'xlsx')
      lapply(
        lapply(fls,
               PipeFish::mungeLL),
        PipeFish::UPLOADLL
        )
      message("complete")
    }else{
      message('no directory selected')
    }
  }


  )

})
