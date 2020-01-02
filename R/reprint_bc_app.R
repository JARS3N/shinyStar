reprint_bc_app<-function(){
shiny::shinyApp(shinyStar::reprint_barcodes_ui(),shinyStar::reprint_barcodes_server())
}
