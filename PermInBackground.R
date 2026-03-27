ds <- readRDS("ds.rds")

library(dplyr)
library(sf)

# Takes about 40 minutes on my machine. So pre-saved the output. 
set.seed(42)

ds <- ds %>%
  group_by(stimulus) %>%
  arrange(stimulus) %>%
  arrange(ordered(stimulus, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday","Sunday"))) %>%
  arrange(ordered(stimulus, levels = c("January", "February", "March", "April", "May","June","July","August","September","October","November","December"))) %>%
  ungroup() %>%
  group_by(ID, group, Cond, repetition) %>%
  mutate(StimOrder = 1:length(stimulus))

# First define output matrix:
n_perms <- 500
perm_names <- paste0("n_perm", sprintf("%03d", 1:n_perms))  # X001 … X100

ds_perm <-  as.data.frame(
  matrix(NA_real_, nrow = length(unique(ds$ID)), ncol = n_perms,
         dimnames = list(unique(ds$ID), perm_names))
)

ds_perm_pp <-  as.data.frame(
  matrix(NA_real_, nrow = length(unique(ds$ID)), ncol = n_perms,
         dimnames = list(unique(ds$ID), perm_names))
)

ID_list <- unique(ds$ID)
total = length(ID_list)*n_perms
pb <- txtProgressBar(min = 0, max = total, style = 3)
k <- 0


for(Perm_n in 1:n_perms){
  perm_here <- perm_names[Perm_n]
  for(ID_n in 1:length(unique(ds$ID))){
    
    ################ Extract data per ID: ################
    ds_ID <- ds %>%
      filter(ID %in% ID_list[ID_n]) %>%
      select(ID, group, stimulus, Cond, nLineCross, repetition, StimOrder,x_zs,y_zs,SelfInter)
    
     ################ Apply permutation (sample) across repetitions################
     ds_ID <- ds_ID %>%
      group_by(stimulus) %>%
      mutate(repetition_perm = sample(repetition)) 
    
    ################ Pass to sf ################
    ds_ID_segm <- ds_ID %>%
      group_by(ID, stimulus) %>%
      arrange(stimulus) %>%
      arrange(ordered(stimulus, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday","Sunday"))) %>% 
      arrange(ordered(stimulus, levels = c("January", "February", "March", "April", "May","June","July","August","September","October","November","December"))) %>%
      filter(!is.nan(x_zs), !is.nan(y_zs)) %>% # sf hates NaN! Not needed anymore, NaN's are managed above in the code.
      ungroup() %>%
      arrange(ID) %>%
      mutate(
        group = as.character(group),
        ID     = as.character(ID),
        Cond      = as.character(Cond),
        repetition_perm     = as.integer(repetition_perm)
      ) %>%
      group_by(ID, Cond, repetition_perm,group) %>%
      summarise(
        geometry = st_sfc(st_linestring(as.matrix(cbind(x_zs, y_zs)))), # preserves order
        .groups = "drop"
      ) %>%
      st_as_sf(crs = NA) 
    
    ################ Convert to poly and compute validity ################
    ds_ID_poly               <- st_cast(ds_ID_segm, "POLYGON")
    ds_ID_poly$isValidStructPerm <- st_is_valid(ds_ID_poly, geos_method = "valid_structure")
    
    ds_ID_poly <- ds_ID_poly  %>%
      mutate(isValidStructPerm = mean(isValidStructPerm, na.rm = TRUE)) %>%
      filter(row_number() == 1)
    
    ds_ID_poly <- ds_ID_poly %>%
      mutate(
        area = st_area(geometry),
        perim = st_length(st_boundary(geometry)),
        pp = as.numeric((4 * pi * area) / (perim^2))
      )  %>%
      filter(row_number() == 1)
    
    if(is.na(ds_ID_poly$pp)){
          ds_ID_poly$pp <- 0
        }
    
    ################ save the permuted results ################
        if(!rownames(ds_perm[ID_n,]) == ID_list[ID_n]){
      warning("ID names do not match")
    }
    
    ds_perm[ID_n,Perm_n] <- ds_ID_poly$isValidStructPerm
    ds_perm_pp[ID_n,Perm_n] <- ds_ID_poly$pp
    k <- k + 1
    setTxtProgressBar(pb, k)
  }
}

# Now average the permutations: 
ds_perm$ID <-rownames(ds_perm)
ds_perm$group <- ds_perm$ID  %in% ds_Q$ID[ds_Q$group == "Ctl"] # is true if Ctl
ds_perm$group[ds_perm$group]  <- "Ctl"
ds_perm$group[ds_perm$group == "FALSE"] <- "Syn"

ds_perm_pp$ID <-rownames(ds_perm_pp)
ds_perm_pp$group <- ds_perm_pp$ID  %in% ds_Q$ID[ds_Q$group == "Ctl"] # is true if Ctl
ds_perm_pp$group[ds_perm_pp$group]  <- "Ctl"
ds_perm_pp$group[ds_perm_pp$group == "FALSE"] <- "Syn"

write.csv2(ds_perm, "permuted_isValid.csv")
write.csv2(ds_perm_pp, "permuted_pp.csv")