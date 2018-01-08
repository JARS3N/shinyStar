reprint_barcodes_server<-function(){

        require(shiny)
        require(RMySQL)
        require(openxlsx)
        conn<- adminKraken::con_mysql()
        query<-paste0("SELECT DISTINCT(Lot_Num) from barcodelotview;")
        send<-dbSendQuery(conn,query)
        Lots<-dbFetch(send)
        dbDisconnect(conn)


        shinyServer(function(input, output,session) {
          session$onSessionEnded(function() {
            stopApp()
          })


          updateSelectInput(session,'Lot',choices=c("N/A",Lots$Lot_Num))

          observeEvent(input$Lot,{
            if(input$Lot!="N/A"){
              lotn<- substr(input$Lot,2,nchar(input$Lot))
              lotl<-substr(input$Lot,1,1)

            q_str<-paste0('SELECT * from barcodelotview where Lot_Num_Input="',lotn,
                          '" AND Cart_type="',lotl,'" ORDER BY Serial_Num;')
            conn<- adminKraken::con_mysql()
            q<-dbSendQuery(conn,q_str)
            DF<-dbFetch(q)
            dbDisconnect(conn)
              dir<-"//lexnas03a-vs1-nas-s1lkq.agilent.com/LSAG/Seahorse Bioscience Chicopee/SH Consumables Labeling"
              outfl<-'CartridgeDatabase.xlsx'
              write.xlsx(DF,file=file.path(dir,outfl))
            print(DF)
            }
          })



        })


}
