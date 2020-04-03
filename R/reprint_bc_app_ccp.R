reprint_bc_app<-function(){
shiny::shinyApp(shinyStar::reprint_bc_ui(),shinyStar::reprint_bc_server_ccp())
}
