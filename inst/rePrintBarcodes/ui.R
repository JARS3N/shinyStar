library(shiny)

shinyUI(fluidPage(
  titlePanel("Reprint Barcodes to XL for Labels"),
  selectInput("Lot", "Select Lot",c('N/A'),selected=FALSE, multiple = FALSE)
)
)
