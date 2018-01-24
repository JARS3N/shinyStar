coef_server_app<-function(){
require(shiny)
require(seastar)
require(asyr)
require(dplyr)
require(ggplot2)
require(ggthemes)

shinyServer(function(input, output) {

observeEvent(input$dirsel,{
seldir<- choose.dir()

  A<- list.files(path=seldir,pattern='asyr',full.names=T) %>%
    lapply(.,XML::xmlTreeParse,useInternalNodes=T) %>%
    lapply(.,asyr::process) %>%
    lapply(.,asyr::extract_wetQC) %>%
    dplyr::bind_rows()

  #########
  gain_and_led_table<-
    filter(A,!is.na(Target)) %>%
    group_by(.,Target) %>%
    summarise(.,pH_LED_AVG=mean(pH.LED,),
              O2_LED_AVG=mean(O2.LED),
              Gain_AVG=mean(Gain,na.rm=T),
              Gain_SD=sd(Gain),
              Gain_minus3SD=Gain_AVG-(3*Gain_SD),
              Gain_plus3SD=Gain_AVG+(3*Gain_SD)
    )

  #########
  ksv_f0<-filter(A,!is.na(KSV)) %>%
    summarize(.,AVG_KSV=mean(KSV),AVG_F0=mean(F0),
              Median_ksv=median(KSV),Median_F0=median(F0)
    )

  #############
  gaindat<-filter(A,!is.na(Target))

  gain_lm<-lm(Gain~Target,data=gaindat)
  SUM_LM<-summary(gain_lm)
  coeffs<-data.frame(
    vars=c("rsquared",
           "slope",
           "intercep",
           "Gain"),
    val=c(round(SUM_LM$r.squared,6),
          round(coef(gain_lm)[2],6),
          round(coef(gain_lm)[1],6),
          (median(A$Target,na.rm = T) *coef(gain_lm)[2])+coef(gain_lm)[1])
  )


  coeffplot<-ggplot(gaindat,aes(Target,Gain))+
    geom_point(alpha=.2)+
    geom_smooth(method='lm')+
    theme_bw()+
    ggtitle(label=unique(A$Lot),subtitle=
              paste0("Rsquared: ",round(SUM_LM$r.squared,6),"\n",
                     "eq: Gain = (Target * ",round(coef(gain_lm)[2],6),") +",round(coef(gain_lm)[1],6)
              )
    )


  write.csv(A,file.path(seldir,"data.csv"),row.names = F)
  write.csv(gain_and_led_table,file.path(seldir,"gain_and_led_table.csv"),row.names = F)
  write.csv(ksv_f0,file.path(seldir,"ksv_f0.csv"),row.names = F)
  write.csv(coeffs,file.path(seldir,"coeffs.csv"),row.names=F)
  ggsave(file.path(seldir,"coeffplot.png"),coeffplot,width=10,height=6)

})

})
}
