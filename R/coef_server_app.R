{
  require(shiny)
  require(seastar)
  require(asyr)
  require(dplyr)
  require(ggplot2)
  require(ggthemes)
  require(writexl)
  shinyServer(function(input, output) {
    observeEvent(input$dirsel, {
      E <- new.env()
      E$seldir <- choose.dir()
      message("now get files")
      E$fl <- list.files(
        path = E$seldir,
        pattern = "(asyr|xflr)$",
        full.names = T
      )
      message("now read objects")
      E$asyrs <-
        purrr::map(setNames(E$fl, basename(E$fl)), asyr::new)
      message("raw data")
      E$data$raw <- purrr::map_df(E$asyrs, function(u) {
        u$wetqc() %>%
          mutate(
            .,
            Target = NULL,
            O2_target = u$O2_coefs$target,
            pH_target = u$pH_coefs$target,
            Lot = paste0(u$type, u$lot),
            sn = u$sn
          )
      }, .id = 'file')
      E$median_target <- median(E$data$raw$pH_target)
      E$Lot <- unique(E$data$raw$Lot)
      ## KSV
      message("ksv data")
      E$data$ksv <- filter(E$data$raw, !is.na(KSV)) %>%
        summarize(
          .,
          AVG_KSV = mean(KSV),
          AVG_F0 = mean(F0),
          Median_ksv = median(KSV),
          Median_F0 = median(F0)
        )
      ### GAIN
      message("profile gain data")
      gain_lm <- lm(Gain ~ pH_target, data = E$data$raw)
      
      SUM_LM <- summary(gain_lm)
      
      E$data$coeffs <- data.frame(
        vars = c("rsquared", "slope",
                 "intercep", "Gain"),
        val = c(
          round(SUM_LM$r.squared,
                6),
          round(coef(gain_lm)[2], 6),
          round(coef(gain_lm)[1],
                6),
          (E$median_target * coef(gain_lm)[2]) + coef(gain_lm)[1]
        )
      )
      
      E$plot$pH_lm <-
        filter(E$data$raw, is.na(KSV)) %>%
        ggplot(., aes(pH_target, Gain)) +
        geom_point(alpha = 0.2) +
        geom_smooth(method = "lm") +
        theme_bw() +
        ggtitle(
          label = unique(E$data$raw$Lot),
          subtitle = paste0(
            "Rsquared: ",
            round(SUM_LM$r.squared,
                  6),
            "\n",
            "eq: Gain = (Target * ",
            round(coef(gain_lm)[2],
                  6),
            ") +",
            round(coef(gain_lm)[1], 6)
          )
        )
      ##### LED & Gain table
      message("set tables")
      E$data$gain_led_table <-
        filter(E$data$raw,!is.na(pH_target)) %>%
        filter(., !is.na(Gain)) %>%
        group_by(., pH_target) %>%
        summarise(
          .,
          pH_LED_AVG = mean(pH.LED),
          O2_LED_AVG = mean(O2.LED),
          Gain_AVG = mean(Gain,
                          na.rm = T),
          Gain_SD = sd(Gain),
          Gain_minus3SD = Gain_AVG -
            (3 * Gain_SD),
          Gain_plus3SD = Gain_AVG + (3 *
                                       Gain_SD)
        )
      
      ### Save output
      message("save outputs")
      writexl::write_xlsx(x = E$data,
                          path = file.path(file.path(
                            E$seldir,
                            paste0(E$Lot, "_coefficient_summary.xlsx")
                          )))
      ggsave(
        file.path(E$seldir, "coeffplot.png"),
        E$plot$pH_lm,
        width = 10,
        height = 6
      )
      message("done,kill object")
      E <- NULL
    })
  })
}
