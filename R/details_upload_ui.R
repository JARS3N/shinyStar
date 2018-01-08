details_upload_ui<-function(){


    require(shiny)
    shinyUI(fluidPage(
      h3("Machine Vision Data Upload"),
      p('Select the directory which contains all the individual Cartridge directories'),
      shiny::actionButton("SelectDir","Select Main Lot Directory"),
      fluidRow(h5("Status:")),
      fluidRow(textOutput("status")),
      fluidRow(textOutput("status2")),
      fluidRow(textOutput("status3")),
      fluidRow(textOutput("status4")),
      fluidRow(textOutput("status5"))
    )
    )

}
