Fig5f<-function(SampledData,OriginalData) {
  library(ggplot2)
  library(tidyr)
  library(dplyr)
  # SampledData<-SubsampledPW.results_First
  # OriginalData<-OriginalData
  vars<-list(SampledData[1],OriginalData)
  SampledData<-as.data.frame(vars[1])
  OriginalData<-as.data.frame(vars[2])
  
  source("./Rscript/functions/DivRichCalc.R")
  OAdiv<-DivRichCalc(OriginalData,"author_all","OA")
  OArich_All<-as.numeric(OAdiv[1])
  OArich_All
  probAll<-sum(SampledData$Richness>OArich_All)/1000*100
  probAll
  
  prich_All<-ggplot(SampledData, aes(x=Richness)) +
    geom_histogram(bins=30, colour="black", fill="white")+
    geom_vline(aes(xintercept=OArich_All),
               color="darkblue", linetype="dashed", size=1)+
    annotate("text", x =84.5, y = 245,label =(paste(probAll,"%",sep="")))+
    # geom_label(label="Observed OA Richness (--%)", x=85,y=230,
    #            label.padding = unit(0.55, "lines"), # Rectangle size around label
    #            label.size = 0.5,color = "darkblue", fill="white")+
    xlab("Author Geographic Richness")+
    ylab("Frequency")+
    ggtitle("F) all authors")+
    scale_y_continuous(expand = c(0,0),limits = c(0,250))+
    scale_x_continuous(breaks = seq(50,90, by=5),limits=c(50,90))
  prich_All<-prich_All+
    theme_classic()+ 
    theme(
      axis.text.x = element_text(size=18),
      axis.text.y = element_text(size=18),
      axis.title.x=element_text(colour="black", size = 24, vjust=-0.5),
      axis.title.y=element_text(colour="black", size = 24, hjust=0.5,),
      plot.title = element_text(colour="black", size = 24, vjust=3),
      plot.margin =unit(c(1,1,1,1.5), "lines")  
    )
  prich_All
  
  return(prich_All)
  
}