n_OA_plots <- function(AllData, n_countries) {
  # n_countries<-20
  AllData$Journal <- as.factor(AllData$Journal)
  AllData$Code <- as.factor(AllData$Code)
  n_by_pair <- AllData %>%
    filter(ArticleType == "OA") %>%
    group_by(refID) %>%
    slice(1) %>%
    group_by(pair_key, Code, JrnlType) %>%
    summarize(n = n()) %>%
    arrange(Code) %>%
    spread(JrnlType, n) %>%
    replace_na(list(OA = 0, PW = 0)) %>%
    mutate(total_n = OA + PW)

  top_countries <- n_by_pair %>%
    group_by(Code) %>%
    summarize(n = sum(total_n)) %>%
    arrange(desc(n)) %>%
    slice(1:n_countries) %>%
    select(Code)

  top_n_by_pair <- n_by_pair %>%
    filter(Code %in% top_countries$Code)
  # top_n_by_pair$total_n<-as.factor(top_n_by_pair$total_n)
  top_n_by_pair$Code <- droplevels(top_n_by_pair$Code)
  jrnl.names <- AllData %>%
    filter(JrnlType == "OA") %>%
    select(Journal, pair_key) %>%
    distinct() %>%
    arrange(pair_key) %>%
    dplyr::rename("Mirror" = "Journal")
  top_n_by_pair <- left_join(top_n_by_pair, jrnl.names)
  # top_n_by_pair<- top_n_by_pair %>% mutate(OAperc=OA/total_n*100,PWperc=PW/total_n*100)
  top_n_by_pair$Mirror <- droplevels(top_n_by_pair$Mirror)

  plot_data <- top_n_by_pair %>%
    group_by(Code) %>%
    summarize(nPW = sum(PW), nOA = sum(OA)) %>%
    mutate(perc_pw = nPW / (nPW + nOA) * 100, perc_oa = nOA / (nPW + nOA) * 100)

  Codes <- AllData %>%
    group_by(refID) %>%
    slice(1) %>%
    ungroup() %>%
    select(First_Author_Country, Code, IncomeGroup, Region) %>%
    unique()

  plot_data <- left_join(plot_data, Codes)

  plot_data$IncomeGroup <- as.factor(plot_data$IncomeGroup)
  levels(plot_data$IncomeGroup)[levels(plot_data$IncomeGroup) == 
                                  "Low"] <- "Low"
  levels(plot_data$IncomeGroup)[levels(plot_data$IncomeGroup) == 
                                  "Lower middle"] <- "Lower-middle"
  levels(plot_data$IncomeGroup)[levels(plot_data$IncomeGroup) == 
                                  "Upper middle"] <- "Upper-middle"
  levels(plot_data$IncomeGroup)[levels(plot_data$IncomeGroup) == 
                                  "High"] <- "High"
  plot_data$IncomeGroup <- ordered(plot_data$IncomeGroup,
    levels = c("Low", "Lower-middle", "Upper-middle", "High")
  )

  plot_data$color <- NA
  plot_data$color[plot_data$IncomeGroup == "Low"] <- "'#084594'"
  plot_data$color[plot_data$IncomeGroup == "Lower-middle"] <- "'#4292C6'"
  plot_data$color[plot_data$IncomeGroup == "Upper-middle"] <- "'#9ECAE1'"
  plot_data$color[plot_data$IncomeGroup == "High"] <- "'#F7FBFF'"


  color.labels <- c("Low" = "#084594", "Lower-middle" = "#4292C6",
                    "Upper-middle" = "#9ECAE1", "High" = "#F7FBFF")

  library(RColorBrewer)
  library(ggrepel)


  # p1<-ggplot(plot_data, aes(x=nOA,
  #                           y=nPW,
  #                           color=IncomeGroup,
  #                           fill=IncomeGroup,
  #                           label=Code)) +
  #   geom_point(size=8,
  #              color="black",
  #              shape=21,
  #              position=position_dodge(width=0.2)) +
  #   geom_abline(intercept = 0,
  #               slope = 1,
  #               color="darkgray",
  #               size=1.5,
  #               linetype="dashed") +
  #   scale_fill_manual(values=c("#F7FBFF","#9ECAE1","#4292C6","#084594"),
  #                     name="National Income Category",
  #                     breaks=c("High", "Upper-middle","Lower-middle","Low"))+
  #   scale_y_continuous(limits = c(0, 350),breaks = seq(0,340, by=20),expand=c(0,0.1))+
  #   scale_x_continuous(limits = c(0, 250),breaks = seq(0,240, by=20),expand=c(0,0.1))
  #
  #
  # p1<-p1+
  #   theme_classic()+
  #
  #   geom_text_repel(segment.color = "black",
  #                   color="black",
  #                   size=8,
  #                   box.padding = 0.4,
  #                   max.overlaps = Inf) +
  #
  #   labs(x = "No. of articles in Mirror journals",
  #        y = "No. of OA articles in Parent journals")+
  #   theme(
  #     # legend.position = "right",
  #     axis.text.x = element_text(size=20),
  #     axis.text.y = element_text(size=20),
  #     axis.title.x=element_text(colour="black", size = 24, vjust=-0.5),
  #     axis.title.y=element_text(colour="black", size = 24, vjust=-0.5,
  #                               margin = margin(t = 0, r = 20, b = 0, l = 0)),
  #     plot.title = element_text(size=8),
  #     legend.text = element_text(colour="black", size = 16, vjust=0.5),
  #     legend.title = element_text(size=20),
  #     legend.position=c(0.9, 0.2),
  #     plot.margin =unit(c(1.5,1.5,1.5,1.5), "lines")
  #     )
  # p1


  p1 <- ggplot(plot_data, aes(
    x = perc_pw,
    y = perc_oa,
    color = IncomeGroup,
    fill = IncomeGroup,
    label = Code
  )) +
    geom_point(
      size = 4,
      color = "black",
      shape = 21,
      position = position_dodge(width = 0.2)
    ) +
    geom_abline(
      intercept = 0,
      slope = 1,
      color = "darkgray",
      size = 1.5,
      linetype = "dashed"
    ) +
    scale_fill_manual(
      values = c("#F7FBFF", "#9ECAE1", "#4292C6", "#084594"),
      name = "National Income Category",
      breaks = c("High", "Upper-middle", "Lower-middle", "Low")
    ) +
    scale_y_continuous(limits = c(0, 100), 
                       breaks = seq(0, 100, by = 10),
                       expand = c(0, 0.1)) +
    scale_x_continuous(limits = c(0, 100),
                       breaks = seq(0, 100, by = 10),
                       expand = c(0, 0.1))


  p1 <- p1 +
    theme_classic() +

    geom_text_repel(
      segment.color = "black",
      color = "black",
      size = 5,
      box.padding = 0.15,
      max.overlaps = 20
    ) +

    labs(
      x = "OA Articles in Parent journals (%)",
      y = "Articles in Mirror journals (%)"
    ) +
    theme(
      # legend.position = "right",
      axis.text.x = element_text(size = 20),
      axis.text.y = element_text(size = 20),
      axis.title.x = element_text(colour = "black", size = 24, vjust = -0.5),
      axis.title.y = element_text(
        colour = "black", size = 24, vjust = -0.5,
        margin = margin(t = 0, r = 20, b = 0, l = 0)
      ),
      plot.title = element_text(size = 8),
      legend.text = element_text(colour = "black", size = 16, vjust = 0.5),
      legend.title = element_text(size = 20),
      legend.position = c(0.85, 0.5),
      plot.margin = unit(c(1.5, 1.5, 1.5, 1.5), "lines")
    )
  p1
  return(p1)
}
