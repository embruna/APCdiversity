RegionPlot<-function(DataSet,Subsampled_Countries,countries) {
  # DataSet<-bootstrap_results
  # Subsampled_Countries<-bootstrap_results_countries
    # countries<-"All"
  library(tidyverse)
  library(RColorBrewer)
  library(ggExtra)
  library(egg)
  
vars<-list(DataSet,Subsampled_Countries,countries)
  
DataSet<-as.data.frame(vars[1])
Subsampled_Countries<-as.data.frame(vars[2])
countries<-vars[3]
  Subsampled_Countries$Region<-as.factor(Subsampled_Countries$Region) 
  Subsampled_Countries$Region<-as.factor(Subsampled_Countries$Region) 
  Subsampled_Countries$Code<-as.factor(Subsampled_Countries$Code) 
  Subsampled_Countries$Country<-as.factor(Subsampled_Countries$Country) 
  Subsampled_Countries$IncomeGroup <- ordered(Subsampled_Countries$IncomeGroup, 
                                 levels = c("Low","Lower middle","Upper middle","High"))
  
  Subsampled_Countries$Region <- ordered(Subsampled_Countries$Region, 
                                         levels =c("South Asia",
                                                   "North America",
                                                   "Sub-Saharan Africa",
                                                   "Latin America & Caribbean",
                                                   "Middle East & North Africa",
                                                   "East Asia & Pacific",
                                                   "Europe & Central Asia")) 
  
  Subsampled_Region_summary<-Subsampled_Countries %>% 
    group_by(author,Dataset,replicate,Region) %>% 
    summarize(n=n()) %>% 
    mutate(perc=n/sum(n)*100) 
  
  PW_medians<-Subsampled_Region_summary %>% 
    group_by(author,Dataset,replicate,Region) %>% 
    summarise(median=median(perc))
  PW_medians$JrnlType<-"PW"
  
  ###################################
  ###################################
  # OA 
  ###################################
  ###################################
  
  one_author_pubs_ALL<-read_csv(file="./data_clean/sole_author_pubs_ALL_first_author.csv")
  coauthor_pubs_ALL<-read_csv(file="./data_clean/coauthor_pubs_ALL_first_author.csv")
  one_author_pubsNOCHNUSA<-read_csv(file="./data_clean/one_author_pubsNOCHNUSA.csv")
  coauthor_pubsNOCHNUSA<-read_csv(file="./data_clean/coauthor_pubsNOCHNUSA.csv")
  
  
  
  coauthor_pubs_ALL_first<-coauthor_pubs_ALL
  coauthor_pubs_ALL_first$author<-"author_first"
  
  coauthor_pubsNOCHNUSA_first<-coauthor_pubsNOCHNUSA
  coauthor_pubsNOCHNUSA_first$author<-"author_first"
  # 
  # coauthor_pubs_ALL_first<-coauthor_pubs_ALL %>% 
  #   group_by(DOI) %>% 
  #   filter(AuthorNum == 1)
  # coauthor_pubs_ALL_first$author<-"author_first"
  #   
  # coauthor_pubsNOCHNUSA_last<-coauthor_pubsNOCHNUSA %>% 
  #   group_by(DOI) %>% 
  #   filter(AuthorNum == max(AuthorNum)) %>%
  #   filter(AuthorNum>1)
  # coauthor_pubsNOCHNUSA_last$author<-"author_last"
  # 
  # coauthor_pubsNOCHNUSA_first<-coauthor_pubsNOCHNUSA %>% 
  #   group_by(DOI) %>% 
  #   filter(AuthorNum == 1) 
  # coauthor_pubsNOCHNUSA_first$author<-"author_first"
  
  AllPubs<-bind_rows(one_author_pubs_ALL,
                     one_author_pubsNOCHNUSA,
                     coauthor_pubs_ALL_first,
                     coauthor_pubsNOCHNUSA_first)
  
  AllPubs<-AllPubs %>% drop_na(Region)
  
  levels(as.factor(AllPubs$author))
  
  OAData<-AllPubs %>% filter(JrnlType=="OA")
  
  OA_percs<-OAData %>% 
    group_by(author,Dataset,Region) %>% 
    summarize(n=n()) %>% 
    mutate(perc=n/sum(n)*100)

  
  OA_percs$Region <- ordered(OA_percs$Region, 
                                         levels=levels(Subsampled_Countries$Region))
                 
Subsampled_Region_summary_plot<-Subsampled_Region_summary %>% 
    filter(author!="author_all")
  
  
  
  
# author.labels <- c(author_first = "First Authors", author_last = "Last Authors", solo= "Single Authors")
  author.labels <- c(author_first = "First Authors", solo= "Single Authors")
  color.labels<-c("Low"= "#A6CEE3", 'Lower middle'="#1F78B4",'Upper middle'="#B2DF8A",'High'="#33A02C")
  Subsampled_Region_summary_plot$author<-as.factor(Subsampled_Region_summary_plot$author)
  Subsampled_Region_summary_plot$author<-ordered(Subsampled_Region_summary_plot$author, levels = c("solo", "author_first", "author_last","author_all"))
  
  # DATA SELECTION FOR Figure 
  if (((vars[3]=="All")==TRUE)) {
    fig_data<-Subsampled_Region_summary_plot  %>% filter(Dataset=="All Countries")
    label_data<-OA_percs %>% filter(Dataset=="All Countries")
  } else if (((vars[3]=="no_CHN_USA")==TRUE)) {
    fig_data<-Subsampled_Region_summary_plot  %>%filter(Dataset=="CHN & USA excluded")
    label_data<-OA_percs %>% filter(Dataset=="CHN & USA excluded")
  } else {
    stop("Please enter 'All' or 'no_CHN_USA' ")
  }
  
  fig_data<-fig_data %>% drop_na(Region)
  
  Region<-OA_percs$Region
  
  Region<-recode_factor(Region,"South Asia"="South\nAsia",
                        "North America"="North\nAmerica",
                        "Sub-Saharan Africa"="Sub-Saharan\nAfrica",
                        "Latin America & Caribbean"="Latin America &\nCaribbean",
                        "Middle East & North Africa"="Middle East &\nNorth Africa",
                        "East Asia & Pacific"="East Asia &\nPacific",
                        "Europe & Central Asia"="Europe &\nCentral Asia",
                        .default = levels(Region))

  OA_percs$Region<-Region  
  
    
  Region<-fig_data$Region
  Region<-recode_factor(Region,"South Asia"="South\nAsia",
                        "North America"="North\nAmerica",
                        "Sub-Saharan Africa"="Sub-Saharan\nAfrica",
                        "Latin America & Caribbean"="Latin America &\nCaribbean",
                        "Middle East & North Africa"="Middle East &\nNorth Africa",
                        "East Asia & Pacific"="East Asia &\nPacific",
                        "Europe & Central Asia"="Europe &\nCentral Asia",
                        .default = levels(Region))
fig_data$Region<-Region  

Region<-label_data$Region
Region<-recode_factor(Region,"South Asia"="South\nAsia",
                      "North America"="North\nAmerica",
                      "Sub-Saharan Africa"="Sub-Saharan\nAfrica",
                      "Latin America & Caribbean"="Latin America &\nCaribbean",
                      "Middle East & North Africa"="Middle East &\nNorth Africa",
                      "East Asia & Pacific"="East Asia &\nPacific",
                      "Europe & Central Asia"="Europe &\nCentral Asia",
                      .default = levels(Region))

label_data$Region<-Region 

fig_data$author <- factor(fig_data$author,levels = c("solo","author_first"))

label_data$author <- factor(label_data$author,levels = c("solo","author_first"))


  RegionPlot<-ggplot(fig_data,aes(x=perc,fill=Region)) +
    geom_histogram(bins=100,color="black", size=0.5, position = 'identity') +
    scale_fill_brewer(palette = "PRGn")+
    ylab("Frequency") + 
    xlab("Percentage of authors in each region")+
    scale_y_continuous(limits = c(0, 850),breaks = seq(0,800, by=200),expand=c(0,0.1))+
    scale_x_continuous(limits = c(0, 60),breaks = seq(0,60, by=15),expand=c(0,01))+
    facet_grid(cols = vars(author), 
               rows=vars(Region),
               # scales=("free_y"),
               labeller=labeller(author = author.labels))+
    geom_hline((aes(yintercept=-Inf)), color="black") + 
    geom_vline((aes(xintercept=-Inf)), color="black") + 
    coord_cartesian(clip="off")+
    # xlim(-5,80)+
    # ylim(-5,1300)+
    # scale_x_continuous(breaks = seq(0,100, by=10),expand = c(0, 0))+
    # scale_y_continuous(breaks = seq(0,700, by=150),expand = c(0.0, 0))+
    # brewer.pal(4, "paired") gets the hex codes from palette
    # coord_flip()+
    ## OA POINTS LINES AND LABELS
    geom_segment(data = label_data,
                 aes(x = perc,
                     y = as.numeric(Region)+.7,
                     xend = perc, 
                     yend = 600), 
                 linetype="solid", color="red")+
    geom_text(data = label_data,
              aes(x=perc,
                  y=610,
                  label = "OA"),color="red", size=10)
  RegionPlot
  
  RegionPlot<-RegionPlot+
    theme_classic()+
    theme(
      axis.text.x = element_text(size=20),
      axis.text.y = element_text(size=20),
      axis.title.x=element_text(colour="black", size = 25, vjust=-0.5),
      axis.title.y=element_text(colour="black", size = 25, vjust=2),
      strip.text.x = element_text(size = 30,margin = margin(5,0,3,0, "lines")),
      strip.text.y = element_text(size = 30, angle=0),
      strip.background.x = element_rect(fill = NA, colour = NA),
      strip.background.y = element_rect(fill = NA, colour = NA),
      panel.spacing.x =unit(1, "lines"), 
      panel.spacing.y=unit(2,"lines"),
      legend.position = "none",
      legend.text = element_text(size=20),
      plot.margin =unit(c(3,1,1,1.5), "lines")   #plot margin - top, right, bottom, left
    )    
  facet_labels<-c("A","B","C","D","E","F","G","H","I","J","K","L","M","N")
  RegionPlot<-tag_facet(RegionPlot,open="", close="", tag_pool=facet_labels,vjust=0.5,hjust=-1,size=10)
  RegionPlot   
  
  
  #######################################################
  #######################################################
  #######################################################
  # REGION P_hat
  #######################################################
  #######################################################
  label_data<-ungroup(label_data)
  P_Hat<-label_data
  P_Hat$P_Hat<-NA
  
  ##########
  # All countries, coauthored, South Asia
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="South\nAsia") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="South\nAsia") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="South\nAsia" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, coauthored, N AM
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="North\nAmerica") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="North\nAmerica") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="North\nAmerica" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, coauthored, SS Africa
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Sub-Saharan\nAfrica") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Sub-Saharan\nAfrica") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Sub-Saharan\nAfrica" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, coauthored, LatAM Carib
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Latin America &\nCaribbean") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Latin America &\nCaribbean") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Latin America &\nCaribbean" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, coauthored, ME North Af
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Middle East &\nNorth Africa") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Middle East &\nNorth Africa") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Middle East &\nNorth Africa" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, coauthored, East Asia Pac
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="East Asia &\nPacific") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="East Asia &\nPacific") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="East Asia &\nPacific" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, coauthored, Europe Cent Asia
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Europe &\nCentral Asia") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="author_first") %>% 
    filter(Region=="Europe &\nCentral Asia") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Europe &\nCentral Asia" &
                P_Hat$author=="author_first" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  
  ###########
  ###########
  ###########
  # Solo
  ###########
  ###########
  ###########
  
  ###########
  # All countries, solo, South Asia
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="South\nAsia") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="South\nAsia") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="South\nAsia" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, solo, na am
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="North\nAmerica") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="North\nAmerica") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="North\nAmerica" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, solo, SS Africa
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Sub-Saharan\nAfrica") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Sub-Saharan\nAfrica") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Sub-Saharan\nAfrica" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, Solo, LatAm Carrib
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Latin America &\nCaribbean") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Latin America &\nCaribbean") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Latin America &\nCaribbean" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, solo, mid east n afr
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Middle East &\nNorth Africa") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Middle East &\nNorth Africa") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Middle East &\nNorth Africa" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, solo, E asia pac
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="East Asia &\nPacific") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="East Asia &\nPacific") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="East Asia &\nPacific" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  ##########
  # All countries, solo, europe C asia
  crit<-label_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Europe &\nCentral Asia") %>% 
    select(perc)
  
  perc<-fig_data %>% 
    filter(Dataset=="All Countries") %>% 
    filter(author=="solo") %>% 
    filter(Region=="Europe &\nCentral Asia") %>% 
    ungroup() %>% 
    tally(perc<crit$perc) %>% 
    mutate(perc_belowOA = n/1000)
  perc_belowOA<-perc$perc_belowOA
  perc_belowOA
  
  
  
  P_Hat$P_Hat[P_Hat$Region=="Europe &\nCentral Asia" &
                P_Hat$author=="solo" & 
                P_Hat$Dataset=="All Countries"]<-perc_belowOA
  ###########
  
  
  Region<-P_Hat$Region
  Region<-recode_factor(Region,"South\nAsia"="South Asia",
                        "North\nAmerica"="North America",
                        "Sub-Saharan\nAfrica"="Sub-Saharan Africa",
                        "Latin America &\nCaribbean"="Latin America & Caribbean",
                        "Middle East &\nNorth Africa"="Middle East & North Africa",
                        "East Asia &\nPacific"="East Asia & Pacific",
                        "Europe &\nCentral Asia"="Europe & Central Asia",
                        .default = levels(Region))
  P_Hat$Region<-Region 
  
  P_Hat <- P_Hat %>% dplyr::rename("OA_perc"="perc", 
                                   "Author"="author",
                                   "Countries"="Dataset") %>% 
    select(-n) 
  
  
  P_Hat$Author<-gsub("author_first","First",P_Hat$Author)
  P_Hat$Author<-gsub("solo","Single",P_Hat$Author)
  
  
  
  
  return(list(RegionPlot,P_Hat))
 
  
  
   
}