Fig3_region<-function(DataSet,AuPosition,JrnlType) {
  # DataSet<-AllData
  # DataSet<-sole_author_pubs
  # AuPosition<-"author_first"
  # JrnlType<-"OA"
  vars<-list(DataSet,AuPosition,JrnlType)
  #   
    if ((vars[2]=="author_first")==TRUE & (vars[3]=="OA"|vars[3]=="PW")==TRUE) {
    
      AllGeo<-DataSet %>%
        group_by(DOI) %>% 
        filter(AuthorNum == 1) %>%
        filter(JrnlType==vars[3]) 
  
  } else if ((vars[2]=="author_last")==TRUE & (vars[3]=="OA"|vars[3]=="PW")==TRUE) {
    
    AllGeo <-DataSet %>%
      group_by(DOI) %>%
      filter(AuthorNum == max(AuthorNum)) %>%
      filter(AuthorNum>1) %>% 
      # filter(JrnlType=="OA")
      filter(JrnlType==vars[3])
    
  } else {
    stop("Please enter 'author_first' or 'author_last' for b and
         either OA or PW for c")
    
  }

    

    AllGeo<-AllGeo %>% 
      filter(Country != "NA" & Code != "NA") %>%
      ungroup() %>% 
      select(Country, Code,Region,IncomeGroup) %>%
      add_count(Code) %>% 
      group_by(Country) %>% 
      slice(1) %>%
      arrange(desc(n)) %>% 
      filter(Region!= "NA") %>%
      ungroup() %>%
      mutate(perc=n/sum(n)*100)
    sum(AllGeo$perc)
    
    AllGeo$perc<-round(AllGeo$perc,2)
    AllGeo<-arrange(AllGeo,desc(AllGeo$perc))
    AllGeo<- transform(AllGeo,Code = reorder(Code,perc))
    AllGeo$Region<-as.factor(AllGeo$Region)
    AllGeo$Region<-droplevels(AllGeo$Region)
    levels(AllGeo$Region)
    
    cutoff = 25 # This is how many countries you want on the chart, all the rest will be in "OTHER"
    AllGeo2<-arrange(AllGeo, desc(perc)) %>% select(Code,n,perc, Region)
    most.common.authors<-slice(AllGeo, 1:cutoff)
    lst.common.authors<-slice(AllGeo, (cutoff+1):nrow(AllGeo)) 
    # lst.common.authors$Code<-"all others"
    # lst.common.authors$IncomeGroup<-"all others"
    lst.common.authors<-lst.common.authors %>% 
      group_by(Region) %>% 
      summarize(n=sum(n),perc=sum(perc),n_countries=n_distinct(Code)) 
    
    lst.common.authors$Code<-paste(lst.common.authors$n_countries,lst.common.authors$Region,sep = " ", collapse = NULL)
    # lst.common.authors$Code<-paste(lst.common.authors$n_countries,lst.common.authors$IncomeGroup,"income countries", sep = " ", collapse = NULL)
    # lst.common.authors$Code<-gsub("income countries","",lst.common.authors$Code)
    # 
    lst.common.authors$Region<- ordered(lst.common.authors$Region, 
                                  levels = c("East Asia & Pacific",
                                             "Latin America & Caribbean",
                                             "Sub-Saharan Africa",
                                             "Middle East & North Africa",
                                             "South Asia",
                                             "Europe & Central Asia",
                                             "North America"))
    lst.common.authors <-arrange(lst.common.authors,desc(n_countries))
    most.common.authors<-bind_rows(most.common.authors, lst.common.authors)
    most.common.authors$Code<-as.factor(most.common.authors$Code)
    
    # This is needed to put them in order in the plot with OTHER at the end of the graph
    order<-rev(seq(1:nrow(most.common.authors))) #REV is what makes it go tyop to bottom if flipped coordinates
    most.common.authors$Code <- factor(most.common.authors$Code,most.common.authors$Code[levels = order])
    # rm(order,AllGeo,lst.common.authors)
    most.common.authors
    
    
    # Figure 
    if (((vars[3]=="OA")==TRUE) & ((vars[2]=="author_first")==TRUE)) {
      # # title_text=paste("Fig. 3a: Country in which the first",
      # "author of open access articles is based.",sep=" ")
      label_x="First author country"
    } else if (((vars[3]=="PW")==TRUE) & ((vars[2]=="author_first"))==TRUE){
      # title_text=paste("Fig. 3b: Country in which the first",
      #                  "author of paywalled articles is based.",sep=" ")
      label_x="First author country"
    } else if (((vars[3]=="OA")==TRUE) & ((vars[2]=="author_last")==TRUE)) {
      # title_text=paste("Fig. 3c: Country in which the last",
      #                  "author of open access articles is based.",sep=" ")
      label_x="Last author country"
    } else if (((vars[3]=="PW")==TRUE) & ((vars[2]=="author_last")==TRUE)){
      # title_text=paste("Fig. 3d: Country in which the last",
      #                  "author of paywalled articles is based.",sep=" ")
      label_x="Last author country"
    } else {
      stop("Please enter 'author_first' or 'author_last' for b and
         either OA or PW for c")
      }
    
    plot3<-ggplot(most.common.authors, aes(x=Code,y=perc, fill=Region))+
      geom_bar(stat = "identity")+
      # geom_text(size = 3, position = position_stack(vjust = 0.5))+
      xlab(label_x) +
      ylab("Percentage of Articles")+
      coord_flip()+
      scale_fill_brewer(palette="Set2")
      # scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9", "#009E73"), 
      #                    name="National Income Category",
      #                    breaks=c("High", "Upper middle","Lower middle","Low"))
      # # 
    
    plot3<-plot3+
      theme_light()+
      # labs(title = “Main title”, subtitle = “My subtitle”, caption = title_text)+
      # labs(title = title_text,size=10)+
      theme(
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8),
        axis.title.x=element_text(colour="black", size = 12, vjust=-0.5),
        axis.title.y=element_text(colour="black", size = 12, hjust=0.5,vjust=0.5,angle = 90),
        plot.title = element_text(size=8),
        legend.text = element_text(colour="black", size = 8, vjust=0.5),
        legend.title = element_text(size=8),
        legend.position="right",
        # legend.key.height = unit(1,"lines"),
        plot.margin =unit(c(1,1,1,1.5), "lines")  
      )
    plot3  
    
  

  return(plot3)
  
}