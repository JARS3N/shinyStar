
partial_pressure_ui<-function(){
require(shiny)
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
    
  }
