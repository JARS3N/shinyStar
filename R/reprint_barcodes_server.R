reprint_barcodes_server<-function(){

library(shiny)
library(dplyr)
dir<-"/mnt/LSAG/Seahorse Bioscience Chicopee/SH Consumables Labeling"
outfl<-'CartridgeDatabase.xlsx'
my_db <-adminKraken::con_dplyr()
Q<-my_db %>%
  tbl('barcodelotview') %>% 
  select(Lot_Num) %>% 
  distinct() %>% 
  collect() %>% 
  .$Lot_Num
shinyServer(function(input, output,session) {
  session$onSessionEnded(function() {
    stopApp()
  })
  
  
  updateSelectInput(session,'Lot',choices=c("N/A",Q))
  
  observeEvent(input$Lot,{
    if(input$Lot!="N/A"){
      lotn<- substr(input$Lot,2,nchar(input$Lot))
      lotl<-substr(input$Lot,1,1)
      DF<-  my_db %>%
        tbl('barcodelotview') %>%
        filter(Lot_Num_Input==lotn) %>%
        filter(Cart_type==lotl) %>%
        arrange(.,Serial_Num) %>%
        collect() %>% 
        list('Matrix'=.)

      library(openxlsx)
      write.xlsx(DF,file=file.path(dir,outfl))
      
    }
  })
}
