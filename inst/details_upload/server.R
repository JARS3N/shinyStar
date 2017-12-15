library(RMySQL)
shinyServer(function(input, output,session) {
  output$status<-renderText('Waiting')
  output$status2<-renderText('')
  output$status3<-renderText('')
  output$status4<-renderText('')

  observeEvent(input$SelectDir,{
    output$status<-renderText('...working')
    DATA <- details::parse_directory()
    message("pulled data from details.xml files")

    inDat <-unique(DAT$Lot)
    status2<-paste0("checking for ",inDat  ," and related sn in database")
    output$status2<-renderText({status2})
    message(status2)
    # inDB is vector of unique combinations of lot_sn
    inDB<- details::check_presence(inDat)
    if(nrow(inDB)==0){

      status3<- paste0(inDat," new to database")
      output$status3<-renderText(status3)
      message(status3)
      details::write(DATA)
    }else{
      FIN<-DATA[!mapply(
        `&&`,
        DATA$Lot %in% inDB$Lot,
        DATA$sn %in% inDB$sn,
        SIMPLIFY = T
      ),
      ]
      if(nrow(FIN)>0){

        details::write(DATA[newCtgs,])
        status4<-paste0(inDat," completed to database")
        output$status4<-renderText("Nothing new to Upload")
      }else{
        output$status4<-renderText("Nothing new to Upload")
        message('Nothing new to Upload')
      }
    }

    output$status5<-renderText("Task Complete\n ready for next Lot")
    message("Task Complete")
    Sys.sleep(3)
  })#end obsereEvent
})
