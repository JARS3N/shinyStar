outliers_server<-function(){

     require(shiny)
     require(xprt)
     require(outliers)

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
          if(input$CB==TRUE){xprt::asyr_to_xl(DIR);DIR<-file.path(DIR,'export')}
          DF<-outliers::grab_many(DIR)
          svpth<-file.path(DIR,paste0(input$expnm,".csv"))
          output$session <- renderText(svpth)
          output$test1 <- renderTable({DF})
          write.csv(DF,file=svpth)
          require(Cairo)
          AVGplot<-outliers::plot_by_averages(DF,input$expnm)
          CTGplot<-outliers::plot_by_cartridge(DF,input$expnm)
          ggsave(plot =AVGplot,file.path(DIR,paste0(input$expnm,"AVGplot.png")),
                 type = "cairo-png",dpi=600)
          ggsave(plot =CTGplot,file.path(DIR,paste0(input$expnm,"CTGplot.png")),
                 type = "cairo-png",dpi=600)
        }
      })


    })


}
