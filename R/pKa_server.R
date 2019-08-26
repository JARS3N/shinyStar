pKa_server<-function() {
  D<-new.env()
  sort_pka_data <- function(fls, nms, ph, mf) {
    lapply(fls, asyr::new) %>%
      lapply(., function(u) {
        u$wetqc() %>%
          mutate(Lot = paste0(u$type, u$lot), sn = u$sn)
      }) %>%
      setNames(., nms) %>%
      dplyr::bind_rows() %>%
      mutate(., pHbatch = ph,
             mfbatch = mf)
  }
  
  require(shiny)
  require(asyr)
  require(rmarkdown)
  require(xprt)
  library(dplyr)
  shinyServer(function(input, output, session) {
    session$onSessionEnded(function() {
      stopApp()
    })
    
    observeEvent(input$Quit, {
      unlink(list.files(pattern = "temp.pdf$|Rmd$|csv$"))
      stopApp(returnValue = invisible())
    })
    
    
    observeEvent(input$filein, {
      unlink(list.files(pattern = "temp.pdf$|Rmd$|csv$"))
              D$Dat <- sort_pka_data(input$filein$datapath,
                           input$filein$names,
                           input$pHFluor,
                           input$MFBatch)
    })
    
    output$BB <- downloadHandler(
      filename = function() {
        paste0(input$pHFluor,
               "-",
               input$MFBatch,
               "-",
               unique(D$Dat$Lot),
               "_pka.pdf")
      },
      content = function(file) {

       # cat("does Dat(a) exist?: ")
        #print(exists('Dat'))
       # print(head(Dat))
        write.csv(D$Dat, "data.csv")
        template <-
          readLines(system.file("rmd/pKaTemplate.Rmd", package = "shinyStar"))
        alt_tempalte <-
          gsub("XLOTX",
               input$pHFluor,
               gsub("XBATCHX", input$MFBatch, template))
        writeLines(text = alt_tempalte,
                   con =  "temp.Rmd",
                   sep = "\n")
        rmarkdown::render("temp.Rmd", output_file = file)
        rm(D)
      }
    )
    
  })
}

