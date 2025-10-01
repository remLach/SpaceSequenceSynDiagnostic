
# ROC info


Comp_ROC <- function(dataAll, data, group_col, test_col, Cond_col, test_n){
  
  ROC_here <- roc(data[[group_col]] ~ data[[test_col]], data, 
                  percent=TRUE,
                  # arguments for ci
                  ci=TRUE, boot.n=100, ci.alpha=0.9, stratified=FALSE,
                  # arguments for plot
                  plot=TRUE, auc.polygon=TRUE, max.auc.polygon=TRUE, grid=TRUE,
                  print.auc=TRUE, show.thres=TRUE)
  
  # Best threshold using Youden's J
  best_coords <- coords(ROC_here, "best", ret = c("threshold", "sensitivity", "specificity","ppv","npv"), best.method = "youden")
  knitr::kable(best_coords)
  
  ci_auc  <- ci.auc(ROC_Cons)
  
  All_ROC[test_n,] <- c("Consistency_zs", round(ROC_Cons$auc,4), best_coords,as.numeric(ci_auc[1]),as.numeric(ci_auc[2]))
  
  
  
  data$diagnosis <- ifelse(data[[test_col]] >= best_coords$threshold, "Syn", "Ctl")
  tab_counts <- table(data[[group_col]], data$diagnosis)
  # Convert to %
  tab_percent <- prop.table(tab_counts, margin = 1) * 100
  
  result <- matrix(
    paste0(tab_counts, " (", round(tab_percent, 1), "%)"),
    nrow = nrow(tab_counts),
    dimnames = dimnames(tab_counts)
  )
  
  return(knitr::kable(result))
}
