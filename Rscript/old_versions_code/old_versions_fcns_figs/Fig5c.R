Fig5c<-function(SampledData,OriginalData) {
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
  OAdiv_All<-as.numeric(OAdiv[2])
  OAdiv_All
  
  probAll<-sum(SampledData$InvSimp>OAdiv_All)/1000*100
  probAll
  
  pDiv_all<-ggplot(SampledData, aes(x=InvSimp)) + 
    geom_histogram(bins=30, colour="black", fill="white")+
    geom_vline(aes(xintercept=OAdiv_All),
               color="darkblue", linetype="dashed", size=1)+
    annotate("text", x = 11.5, y = 145,label =(paste(probAll,"%",sep="")))+
    # geom_label(label="0% bootstrap PW values >\nObserved OA Diversity",
    #            x=11.5,y=135,label.padding = unit(0.55, "lines"), # Rectangle size around label
    #            label.size = 0.5,color = "darkblue", fill="white")+
    xlab("Author Geographic Diversity")+
    ylab("Frequency")+
    ggtitle("C) all authors")+
    scale_x_continuous(breaks = c(7:13),limits=c(7,13))+
    scale_y_continuous(expand = c(0,0),limits = c(0,150))
  pDiv_all<-pDiv_all+
    theme_classic()+ 
    theme(
      axis.text.x = element_text(size=18),
      axis.text.y = element_text(size=18),
      axis.title.x=element_text(colour="black", size = 24, vjust=-0.5),
      axis.title.y=element_text(colour="black", size = 24, hjust=0.5),
      plot.title = element_text(colour="black", size = 24, vjust=3),
      plot.margin =unit(c(1,1,1,1.5), "lines")  
    )
  pDiv_all
  return(pDiv_all)
  
}