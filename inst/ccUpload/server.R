library(shiny)
library(RMySQL)
library(asyr)
library(XML)
#library(shinyjs)


shinyServer(function(input, output, session) {
  ###########
  session$onSessionEnded(function() {
    stopApp()
  })
  ###########
  #  starting conditions
  ###########
  clean_selections <- DT::renderDataTable(
    NULL,
    selection = list(selected = NULL),
    server = F,
    options = list(dom = 't'),
    rownames = FALSE
  )
  output$foo <- clean_selections

  ###########
  observeEvent(input$Quit, {
    stopApp(returnValue = invisible())
  })
  observeEvent(input$goButton, {
    output$MSG <- renderText("Ready")
    if (input$goButton > 0) {
      output$MSG <- renderText("Select Directory")
      DIR <- choose.dir()

      output$MSG <- renderText("Munging Data...")

      procd <- lapply(lapply(
        list.files(
          path = DIR,
          pattern = 'asyr',
          full.names = TRUE
        ),
        XML::xmlTreeParse,
        useInternalNodes = T
      ),
      asyr::process)
      DATA <- lapply(procd, extract_wetQC)
      output$foo2 <- DT::renderDataTable(do.call('rbind', DATA))
      sum_tbl <- asyr::process_summary(procd)
      sum_tbl <<- sum_tbl[order(sum_tbl$sn, method = 'radix'),]
      if (exists('sum_tbl')) {
        sum_tbl$use <- T
        output$foo <- DT::renderDataTable(
          sum_tbl,
          selection = list(selected = which(sum_tbl$valid == FALSE)),
          server = F,
          options = list(dom = 't', pageLength = nrow(sum_tbl)),
          rownames = F
        )
      }
      # DF<- do.call('rbind',lapply(procd,asyr::extract_wetQC))
      observeEvent(input$foo_rows_selected, {
        sum_tbl
        sum_tbl$use <- T
        sum_tbl$use[input$foo_rows_selected] <- F
        # sum_tbl$use[sum_tbl$valid == FALSE] <- F
        output$foo <- DT::renderDataTable(
          sum_tbl,
          selection = list(selected = input$foo_rows_selected),
          server = F,
          options = list(dom = 't', pageLength = nrow(sum_tbl)),
          rownames
          = FALSE
        )
        last <- input$foo_rows_selected
      })#observeEvent

      observeEvent(input$desel, {
        sum_tbl$use <- T
        output$foo <-  output$foo <- DT::renderDataTable(
          sum_tbl,
          selection = list(selected = NULL),
          server = F,
          options = list(dom = 't', pageLength = nrow(sum_tbl)),
          rownames = FALSE
        )
      })
      # START --- observeEvent export csv
      observeEvent(input$exprt, {
        the_is <- input$foo_rows_selected
        if (!is.null(input$foo_rows_selected)) {
          DATA_2 <- DATA[-1 * input$foo_rows_selected]
        } else{
          DATA_2 <- DATA
        }

        OUT <- do.call('rbind', DATA_2)
        OUT <- OUT[order(OUT$sn, OUT$Well, method = 'radix'), ]
        names <-
          paste0(DIR, "\\", "WetQC_Lot_", unique(OUT$Lot), ".csv")
        write.csv(OUT, names, row.names = F)
        saveRDS(procd, paste0(DIR, "\\", "WetQC_Lot_", unique(OUT$Lot), ".rds"))
      })
      # END ---observeEvent export csv

      observeEvent(input$upload, {
        # upload summary table
        asyr::upload_process_summary(sum_tbl)
        the_is <- input$foo_rows_selected
        if (!is.null(input$foo_rows_selected)) {
          DATA_UP <- DATA[-1 * input$foo_rows_selected]
        } else{
          DATA_UP <- DATA
        }
        asyr::UploadsCC(DATA_UP)
      })#upload
    }
  })
})
