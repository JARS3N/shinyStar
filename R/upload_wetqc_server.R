upload_wetqc_server <- function (){
        require(shiny)
        require(RMySQL)
        require(asyr)
        require(XML)
        require(DT)
        require(dplyr)
        shinyServer(function(input, output, session) {
            E <- new.env()
            
            observeEvent(input$Quit, {
                stopApp(returnValue = invisible())
            })
            session$onSessionEnded(function() {
                stopApp()
            })
            clean_tbls <-function(){
                DT::renderDataTable(
                    NULL,
                    selection = list(selected = NULL),
                    server = F,
                    options = list(dom = "t"),
                    rownames = FALSE
                )}

            observeEvent(input$goButton, {
                
                output$MSG <- renderText("Ready")
                if (input$goButton > 0) {
                    output$MSG <- renderText("Select Directory")
                    E$DIR <- utils::choose.dir()
                    output$MSG <- renderText("Munging Data...")
                    E$files <-
                        list.files(
                            path = E$DIR,
                            pattern = "asyr|xflr",
                            full.names = TRUE
                        )
                    E$procd <-
                        lapply(lapply(E$files, asyr::new), function(u) {
                            u$calibration <- merge(u$calibration, u$wetqc())
                            u
                        })
                    E$DATA <- lapply(E$procd, function(u) {
                        df <- u$calibration
                        df$Lot <-
                            paste0(as.character(u$type),
                                   as.character(u$lot))
                        df$sn <- as.numeric(u$sn)
                        df$Inst <- as.numeric(gsub("[A-Z]","",u$Inst))
                        df$O2.LED <- as.character(df$O2.LED)
                        df$pH.Status <- as.character(df$O2.LED)
                        df$pH.IntialReferenceDelta <- NULL
                        df$O2.IntialReferenceDelta <- NULL
                        df[order(df$Well),]
                    })
                    #init values{
                    E$dim_data <- seq_along(E$DATA)
                    E$index <- E$dim_data
                    E$Truth <- rep(T, length(E$DATA))
                    ############}
                    output$foo2 <-DT::renderDataTable(dplyr::bind_rows(E$DATA))
                    E$sum_tbl <- asyr::wetQC_meta_summary_tbl(E$procd)
 
                        E$sum_tbl$use <- T
                        output$foo <- DT::renderDataTable(
                            E$sum_tbl,
                            selection = list(selected = which(
                                E$sum_tbl$valid ==
                                    FALSE
                            )),
                            server = F,
                            options = list(
                                dom = "t",
                                pageLength = nrow(E$sum_tbl)
                            ),
                            rownames = F
                        )
                }
            })
            observeEvent(input$foo_rows_selected, 
                         ignoreNULL = !is.null(E$sum_tbl),
                         ignoreInit = T, {
                E$Out <- E$Truth
                E$Out[input$foo_rows_selected] <- F
                E$index <- E$dim_data[E$Out]
                E$sum_tbl$use <- E$Out
                
                output$foo <-
                    DT::renderDataTable(
                        E$sum_tbl,
                        selection = list(selected = input$foo_rows_selected),
                        server = F,
                        options = list(
                            dom = "t",
                            pageLength = nrow(E$sum_tbl)
                        ),
                        rownames = FALSE
                    )
                if(is.null(E$sum_tbl)){
                    output$foo <- clean_tbls 
                }
            })
            
            
            observeEvent(input$exprt, {
                E$OUT <- E$DATA[E$index] %>% dplyr::bind_rows()
                E$OUT <-
                    E$OUT[order(E$OUT$sn, E$OUT$Well, method = "radix"),]
                E$export_names <- setNames(paste0(
                    paste0(
                        E$DIR,
                        "\\",
                        "WetQC_Lot_",
                        paste0(unique(E$OUT$Lot), collapse = "_")
                    ),
                    c(".csv", ".rds")
                ), c("csv", "rds"))
                write.csv(E$OUT, E$export_names["csv"], row.names = F)
                saveRDS(E$procd, E$export_names["rds"])
                
            })
            observeEvent(input$upload, {
                asyr::upload_process_summary(E$sum_tbl[E$index,])
                lapply(E$DATA[E$index], asyr::wet_qc_upload)
                E <- NULL
                E <-new.env()
                output$foo<-clean_tbls()
                output$foo2<-clean_tbls()
            })
        })
    }
