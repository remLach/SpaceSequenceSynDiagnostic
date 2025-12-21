# One issue is that I am not shure if I classified correctly the ID (i.e. Ctl vs Syn) in Ward2:
ds_Ward_Q <- ds_Q %>% filter(dataSource %in% c("Ward2","Ward"))


ds_Q %>% 
  filter(dataSource %in% c("Ward2","Ward")) %>%
  ggplot(aes(x = `questionnaire score`)) +
  geom_histogram() +
  facet_wrap(~ group + dataSource)


# The second issue is that area is very bad for Ward1 as a feature:

###  Ward Data
ds_syn       <- read_excel("raw_synaesthetes_consistency_anon.xlsx")
ds_syn$group <- "Syn"
ds_ctl       <- read_excel("raw_controls_consistency_anon.xlsx")
ds_ctl$group <- "Ctl"

ds_Q_syn       <- read_excel("raw_synaesthetes_questionnaire_anon.xlsx")
ds_Q_syn$group <- "Syn"
ds_Q_ctl       <- read_excel("raw_controls_questionnaire_anon.xlsx")
ds_Q_ctl$group <- "Ctl"

# Merge wards datafiles:
ds <- merge(ds_syn,ds_ctl, all = TRUE)
ds_Q <- merge(ds_Q_syn,ds_Q_ctl, all = TRUE)

# Ward only uses those who completed the Questionnaire (i.e. N = 215+252 = 467)
ds <- ds %>% 
  filter(session_id %in% unique(ds_Q$session_id))

ds$ID <- ds$session_id
ds_Q$ID <- ds_Q$session_id


# Define area calculation function
triangle_area <- function(x, y) {
  if(length(x) != 3 | length(y) != 3) return(NA)
  area <- abs(
    x[1]*y[2] + x[2]*y[3] + x[3]*y[1] -
      x[1]*y[3] - x[2]*y[1] - x[3]*y[2]
  ) / 2
  return(area)
}

ds <- ds %>%  
  group_by(ID) %>%
  mutate(x_zs = scale(x), y_zs = scale(y))

## Compute triangle area by group:
ds <- ds %>%  
  group_by(ID, stimulus) %>%
  mutate(triangle_area = triangle_area(x_zs, y_zs)) %>%
  ungroup()

## Summarize By ID:
ds_ID <- ds %>%
  ungroup() %>% group_by(ID) %>%
  summarize(Area = mean(triangle_area, na.rm = TRUE))  %>%
  select(ID,Area)

## Merge
ds_Q <- merge(ds_Q,ds_ID,by = "ID")
rm(tmp_perID)
feature_direction <- c("moreCtl")

pROC::roc(group ~ Area, ds_Q, 
          direction= ">",
          percent=TRUE,
          # arguments for ci
          ci=TRUE, boot.n=100, ci.alpha=0.9, stratified=FALSE,
          # arguments for plot
          plot=FALSE, auc.polygon=TRUE, max.auc.polygon=TRUE, grid=TRUE,
          print.auc=TRUE, show.thres=TRUE, print.thres = "best", print.thres.best.method="youden")


ROC_out <- Comp_ROC(ds_Q, "group", "Area","ID", "moreCtl")


# Area issue

tmp <- ds_Q %>% filter(Area > 40000)


ds %>% 
 filter(ID  %in%  tmp$ID) %>%
  group_by(stimulus) %>%
  arrange(stimulus) %>%
  arrange(ordered(stimulus, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday","Sunday"))) %>% arrange(ordered(stimulus, levels = c("January", "February", "March", "April", "May","June","July","August","September","October","November","December"))) %>% # Start ggplot
  ggplot(aes(x = x_zs, y = y_zs, group = stimulus, label = stimulus, fill = stimulus)) +
  geom_text(aes(x = 4, y = 4.5, label = dataSource), size = 1) + 
  geom_text(aes(x = 3.7, y = 5.5, label = c("Criteria:  Ques   Perim  Area    Area_zs     validPerm")), size = 2) + 
  geom_point(aes(x = 5 -2, y = 5, color = passGroup), size = 0.5) + 
  geom_point(aes(x = 5 -1.5, y = 5, color =pass_Perimeter_zs), size = 0.5) + 
  geom_point(aes(x = 5 -1., y = 5, color =pass_Area), size = 0.5) +
  geom_point(aes(x = 5 -0.5, y = 5, color =pass_Area_zs), size = 0.5) +
  geom_point(aes(x = 5 + 0.2, y = 5, color =pass_isValid_M_perm_ID), size = 0.5) + # SynLine is developed later in the code.
  geom_polygon(alpha = 0.4) +
  geom_text(aes(x = X_mean_zs+0.1, y = Y_mean_zs+0.1), colour = "black", size = 0.5) +
  geom_path(aes(x = X_mean_zs, y = Y_mean_zs, group = 1)) +
  geom_path(aes(x = x_zs, y = y_zs, group = repetition), alpha = 0.2) +
  geom_text(aes(x = x_zs+0.1, y = y_zs+0.1), size = 0.5, alpha = 0.5) +
  facet_wrap_paginate( ~ ID+ Cond)
  theme_minimal()