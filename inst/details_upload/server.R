### look for sns of lot in DB
checkforDBPresence<-function(u){
  conn<- adminKraken::con_mysql()
  qry_str<-paste0('select DISTINCT(sn) from mvdata where Lot="',u,'";')
  qry<-dbSendQuery(conn,qry_str)
  qry_res<-dbFetch(qry)
  dbDisconnect(conn)
  qry_res$Lot<-u
  qry_res
}
###### write data.frame to database
writeDFtoDB <-function(DATA){
  con <- adminKraken::con_mysql()
  dbWriteTable(con, name="machinevisiondata",value= DATA,
               append=TRUE,overwrite = FALSE,row.names=FALSE)
  message("wrote to table")
  dbDisconnect(con)
  message("disconnect")
}

##### APP BELOW

library(RMySQL)
shinyServer(function(input, output,session) {
  output$status<-renderText('Waiting')
  output$status2<-renderText('')
  output$status3<-renderText('')
  output$status4<-renderText('')

  observeEvent(input$SelectDir,{
    output$status<-renderText('...working')
    DATA <- asyr::parse_dirOfDetails
    message("pulled data from details.xml files")

    inDat <-unique(DAT$Lot)
    # inDB is vector of unique combinations of lot_sn
    inDB<- checkforDBPresence(inDat)

    status2<-paste0("checking for ",inDat  ," and related sn in database")
    output$status2<-renderText({status2})
    message(status2)
    inDB<- checkforDBPresence(inDat)
    if(nrow(inDB)==0){

      status3<- paste0(inDat," new to database")
      output$status3<-renderText(status3)
      message(status3)
      writeDFtoDB(DATA)
    }else{
      FIN<-DATA[!mapply(
        `&&`,
        DATA$Lot %in% inDB$Lot,
        DATA$sn %in% inDB$sn,
        SIMPLIFY = T
      ),
      ]
      if(nrow(FIN)>0){

        writeDFtoDB(DATA[newCtgs,])
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
