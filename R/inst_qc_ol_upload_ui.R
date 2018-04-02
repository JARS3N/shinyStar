inst_qc_ol_upload_ui<-function(){

require(shiny)
shinyUI(fluidPage(
 p("select Directory of xlsx files to upload"),
  mainPanel(
    actionButton("UploadData", "UploadData"),
    br(),br(),br(),
    actionButton("Quit", "Quit"),
    textOutput("session"))
))

}
