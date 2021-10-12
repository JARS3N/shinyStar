upload_wetqc_server<-function () {
  require(shiny)
  require(RMySQL)
  require(asyr)
  require(XML)
  require(DT)
  require(dplyr)
  shinyServer(function(input, output, session) {
    session$onSessionEnded(function() {
      stopApp()
    })

    
    clean_selections <-
      DT::renderDataTable(
        NULL,
        selection = list(selected = NULL),
        server = F,
        options = list(dom = "t"),
        rownames = FALSE
      )
    
    output$foo <- clean_selections
    observeEvent(input$Quit, {
      stopApp(returnValue = invisible())
    })
    
    observeEvent(input$goButton, {
      output$MSG <- renderText("Ready")
      if (input$goButton > 0) {
        output$MSG <- renderText("Select Directory")

        DIR <- choose.dir()

        output$MSG <- renderText("Munging Data...")

        files <- list.files(path = DIR,
                            pattern = "asyr|xflr",
                            full.names = TRUE)
      
        procd <-
          lapply(lapply(files, asyr::new), function(u) {
            u$calibration <- merge(u$calibration, u$wetqc())
            u
          })
        
      
        
       
        DATA <- lapply(procd, function(u) {
          df<-u$calibration
          df$Lot <-  as.character(u$lot)
          df$sn <- as.numeric(u$sn)
          df$Inst <- as.numeric(u$Inst)
          df$pH.IntialReferenceDelta <- NULL
          df$O2.IntialReferenceDelta <- NULL
          df[order(df$Well),]
        }) 
        
  
        output$foo2 <- DT::renderDataTable(dplyr::bind_rows(DATA))
        ######################################################################
        
        sum_tbl <- asyr::wetQC_meta_summary_tbl(procd)
        if (exists("sum_tbl")) {
          sum_tbl$use <- T
          output$foo <- DT::renderDataTable(
            sum_tbl,
            selection = list(selected = which(sum_tbl$valid ==
                                                FALSE)),
            server = F,
            options = list(dom = "t",
                           pageLength = nrow(sum_tbl)),
            rownames = F
          )
        }
        ##
        observeEvent(input$foo_rows_selected, {
          sum_tbl
          sum_tbl$use <- T
          sum_tbl$use[input$foo_rows_selected] <- F
          output$foo <- DT::renderDataTable(
            sum_tbl,
            selection = list(selected = input$foo_rows_selected),
            server = F,
            options = list(dom = "t", pageLength = nrow(sum_tbl)),
            rownames = FALSE
          )
          last <- input$foo_rows_selected
        })
        #
        observeEvent(input$desel, {
          sum_tbl$use <- T
          output$foo <- output$foo <- DT::renderDataTable(
            sum_tbl,
            selection = list(selected = NULL),
            server = F,
            options = list(dom = "t", pageLength = nrow(sum_tbl)),
            rownames = FALSE
          )
        })
############
        observeEvent(input$exprt, {
          the_is <- input$foo_rows_selected
          if (!is.null(input$foo_rows_selected)) {
            DATA_2 <- DATA[-1 * input$foo_rows_selected]
          }
          else {
            DATA_2 <- DATA
          }
          OUT <- do.call("rbind", DATA_2)
          OUT <- OUT[order(OUT$sn, OUT$Well, method = "radix"),]
          export_names <- setNames(paste0(
            paste0(
              DIR,
              "\\",
              "WetQC_Lot_",
              paste0(unique(OUT$Lot),
                     collapse = "_")
            ),
            c(".csv", ".rds")
          ), c("csv",
               "rds"))
          write.csv(OUT, export_names["csv"], row.names = F)
          saveRDS(procd, export_names["rds"])
        })
#########
        observeEvent(input$upload, {
          asyr::upload_process_summary(sum_tbl)
          the_is <- input$foo_rows_selected
          if (!is.null(input$foo_rows_selected)) {
            DATA_UP <- DATA[-1 * input$foo_rows_selected]
          }
          else {
            DATA_UP <- DATA
          }
          asyr::UploadsCC(DATA_UP)
        })
      }
    })
  })
}
