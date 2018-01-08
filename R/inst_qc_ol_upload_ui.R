inst_qc_ol_upload_ui<-function(){

require(shiny)
shinyUI(fluidPage(
  p("Export Folder of asyr files to Excel"),mainPanel(
    actionButton("EXP", "Export"),
    br(),br(),br(),
    actionButton("Quit", "Quit"),
    textOutput("session"))
))

}
