UploadDRYQC <- function() {
  require(shiny)
  #require(PipeFish)
  require(miniUI)
  library(RMySQL)
  
  ui<-miniPage(fluidPage(
    p("Add QCStats from DryQC to Database"),mainPanel(
      fileInput("file", label = "QCStats input"),
      actionButton("EXP", "Enter"),
      textOutput("session"),
      actionButton("DONE", "DONE"))
  ))
  
  server<-function(input,output,session) {
    
    stuffHappens<-  observeEvent(input$EXP,
                                 {
                                   IN<-fixShinyFileInput(input$file)
                                 if(grepl("xls",IN$name)){
                                   DF<-loadQCstats(IN$datapath)
                                   if(nrow(DF)>1){
                                     my_db <-  adminKraken::con_mysql()
                                     dbWriteTable(my_db, name="dryqcxf24",value=DF,
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
  runGadget(ui, server,viewer = dialogViewer("UploadDRYQC", width = 400 ,height = 400))
}
