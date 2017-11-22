
  require(shiny)

  fluidPage(
    p("Add QCStats from DryQC to Database"),
    mainPanel(
      fileInput("file", label = "QCStats input"),
      actionButton("EXP", "Enter"),
      textOutput("session"),
      actionButton("DONE", "DONE")
    )
  )
  
  
