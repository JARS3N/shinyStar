upload_dryqc_server<-function(){

      require(shiny)
      require(dryqc)
      require(RMySQL)
      require(adminKraken)

      function(input,output,session) {

        stuffHappens<-  observeEvent(input$EXP,
                                     {
                                       IN<-fixShinyFileInput(input$file)
                                       if(grepl("xls",IN$name)){
                                         DF<-load_qc_stats(IN$datapath)
                                         if(nrow(DF)>1){
                                           my_db <- con_mysql()
                                           dbWriteTable(my_db, name="dryqcxf24",value=as.data.frame(DF),
                                                        append=TRUE,overwrite = FALSE,row.names=FALSE)
                                           dbDisconnect(my_db)
                                           output$session <- renderText("Script Complete,Data Uploaded")
                                         }else{
                                           output$session <- renderText("Error:No Data Added")
                                         }

                                       }else{
                                         output$session <- renderText("Needs to be an Excel File.")
                                       }


                                     })
        observeEvent(input$DONE, {
          stopApp(returnValue = invisible())
        })
      }

}
