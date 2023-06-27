partial_pressure_server<-function(){

      require(shiny)
      require(ggplot2)
      require(ggthemes)
      require(outliers)
      shinyServer(function(input, output) {

        output$distPlot <- renderPlot({

          selectedData <- reactive({
            data.frame(
              temp=0:40,
              PP=sapply(0:40,outliers::partial_pressure_ox,atm=input$ATM)
            )
          })
          ggplot(selectedData(),aes(temp,PP))+
            geom_line(col='red')+
            geom_point(aes(x=input$TMP,y=outliers::partial_pressure_ox(input$TMP,input$ATM)),size=3,alpha=.5,col='green')+
            theme_bw()+
            ylab('mmHg')+
            xlab('Temp(C)')+
            geom_text(aes(x=input$TMP,y=asyr::partial_pressure_ox(input$TMP,input$ATM),
                          label=round(asyr::partial_pressure_ox(input$TMP,input$ATM),3)),vjust = -0.6,
                      family = "Times New Roman",size=10)+
            ylim(c(min(selectedData()$PP),max(selectedData()$PP)+1))
        })

      })
      
}
