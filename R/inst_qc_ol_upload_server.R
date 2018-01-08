inst_qc_ol_upload_server<-function(){

    require(outliers)
    require(shiny)
    shinyServer(function(input, output) {
      observeEvent(input$UploadData, {
        outliers::upload_qc()
      })
    })

}
