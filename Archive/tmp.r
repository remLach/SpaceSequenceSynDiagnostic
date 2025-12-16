## Define function to compute ROC:
Comp_ROC <- function(data, group_col, feature, ID){
  
  if(sum(unique(data[[group_col]]) != c("Syn","Ctl"))){
    warning("group order must be Syn Ctl")
    break
  }
  
  ################ ROC analyses ################ 
  
  ROC_here <- pROC::roc(data[[group_col]] ~ data[[feature]], data, 
                        percent=TRUE,
                        # arguments for ci
                        ci=TRUE, boot.n=100, ci.alpha=0.9, stratified=FALSE,
                        # arguments for plot
                        plot=TRUE, auc.polygon=TRUE, max.auc.polygon=TRUE, grid=TRUE,
                        print.auc=TRUE, show.thres=TRUE, print.thres = "best", print.thres.best.method="youden")
  
  # Best threshold using Youden's J
  best_coords <- pROC::coords(ROC_here, "best", 
                              ret = c("threshold", "sensitivity","specificity","ppv","npv"), 
                              best.method = "youden")
  
  
  auc_val <- as.numeric(pROC::auc(ROC_here))
  ci_auc  <- ci.auc(ROC_here)
  
  new_row <- data.frame(
    Feature   = feature,
    AUC        = round(auc_val, 4),
    threshold  = as.numeric(best_coords[["threshold"]]),
    sensitivity= as.numeric(best_coords[["sensitivity"]]),
    specificity= as.numeric(best_coords[["specificity"]]),
    ppv        = as.numeric(best_coords[["ppv"]]),
    npv        = as.numeric(best_coords[["npv"]]),
    ci_low     = as.numeric(ci_auc[1]),
    ci_high    = as.numeric(ci_auc[3]),
    stringsAsFactors = FALSE
  )
  
  ################ Contingency table ################ 
  
  data$diagnosis <- ifelse(data[[feature]] >= best_coords$threshold,  "Ctl","Syn")
  tab_counts <- table(data[[group_col]], data$diagnosis)
  
  tab_percent <- prop.table(tab_counts, margin = 1) * 100
  
  result <- matrix(
    paste0(tab_counts, " (", round(tab_percent, 1), "%)"),
    nrow = nrow(tab_counts),
    dimnames = dimnames(tab_counts)
  )
  
  ################ General description ################ 
  
  Descr_table <- data %>%
    group_by(!!sym(group_col)) %>%
    summarize(n = length(unique(!!sym(ID))), Mean = mean(!!sym(feature)), SD = sd(!!sym(feature)))
  
  ################ Return tables ################ 
  return(list(ROC_properties = new_row, Coningency_table =result, Descr_table = Descr_table))
  
}


Comp_ROC(ds_rothen_ID, "group", "triangle_area_GA_Rothen","ID")