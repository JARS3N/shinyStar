
  library(shiny)
  library(ggplot2)
  library(ggthemes)
 shinyUI(fluidPage(
      titlePanel("Partial Pressure O2"),
      sidebarLayout(
        sidebarPanel(width=2,
                     numericInput('TMP','Target Temp(C)',value=37,min=0,max=40),
                     numericInput('ATM','atm(mmHg)',value=760)
        ),
        mainPanel(
          plotOutput("distPlot")
        )
      )
    ))

  
  
  
