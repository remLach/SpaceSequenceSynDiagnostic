# INITIALIZE POSTER. Run this file: 
# IN: code and data. 
# OUT: .html and .pdf poster.

# First, you will need all the necessary packages to be installed:
# Note: some packages are only necesseary for the Ms and not for the poster. 

# Whith this I can render the poster on my machine:

########### Pre-requisits: #############
# From sessionInfo(): 
# R version 4.5.2 (2025-10-31)
# Platform: aarch64-apple-darwin20
# Running under: macOS Tahoe 26.4.1
# 
# Matrix products: default
# BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib 
# LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
# 
# locale:
# [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
# 
# time zone: Europe/Zurich
# tzcode source: internal
# 
# attached base packages:
# [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
#  [1] pROC_1.19.0.1       sf_1.0-21           tidyr_1.3.2         dplyr_1.2.1        
#  [5] readxl_1.4.5        readr_2.2.0         gt_1.3.0            corrplot_0.95      
#  [9] cowplot_1.2.0       ggforce_0.5.0       ggVennDiagram_1.5.6 ggalluvial_0.12.5  
# [13] ggridges_0.5.7      ggplot2_4.0.1       pakret_0.3.0        RColorBrewer_1.1-3 
# [17] magick_2.9.1       
# 
# loaded via a namespace (and not attached):
#  [1] tidyselect_1.2.1   colorize_0.2.1     farver_2.1.2       S7_0.2.0           fastmap_1.2.0     
#  [6] tweenr_2.0.3       pagedown_0.23      bayestestR_0.17.0  promises_1.5.0     digest_0.6.39     
# [11] mime_0.13          estimability_1.5.1 lifecycle_1.0.5    posterdown_1.0     rsvg_2.7.0        
# [16] processx_3.8.7     magrittr_2.0.5     compiler_4.5.2     rlang_1.2.0        sass_0.4.10       
# [21] tools_4.5.2        utf8_1.2.6         yaml_2.3.12        knitr_1.51         labeling_0.4.3    
# [26] classInt_0.4-11    xml2_1.5.2         mapproj_1.2.11     websocket_1.4.4    KernSmooth_2.23-26
# [31] withr_3.0.2        purrr_1.2.1        grid_4.5.2         polyclip_1.10-7    datawizard_1.3.0  
# [36] xtable_1.8-4       e1071_1.7-16       colorspace_2.1-2   emmeans_1.10.7     scales_1.4.0      
# [41] MASS_7.3-65        pals_1.10          dichromat_2.0-0.1  insight_1.4.5      cli_3.6.5         
# [46] mvtnorm_1.3-3      rmarkdown_2.31     generics_0.1.4     otel_0.2.0         rstudioapi_0.17.1 
# [51] tzdb_0.5.0         parameters_0.28.3  DBI_1.2.3          cachem_1.1.0       proxy_0.4-27      
# [56] maps_3.4.2.1       effectsize_1.0.2   cellranger_1.1.0   vctrs_0.7.2        jsonlite_2.0.0    
# [61] bookdown_0.46      hms_1.1.4          servr_0.32         jquerylib_0.1.4    units_0.8-7       
# [66] glue_1.8.0         gtable_0.3.6       later_1.4.8        tibble_3.3.1       pillar_1.11.1     
# [71] htmltools_0.5.9    R6_2.6.1           evaluate_1.0.5     papaja_0.1.3       httpuv_1.6.17     
# [76] bslib_0.10.0       class_7.3-23       Rcpp_1.1.1         xfun_0.57          fs_2.0.1          
# [81] tinylabels_0.2.5   pkgconfig_2.0.3 

############## Render: ##################
# Second, run both lines (asjust directory name):

# to HMTL:
rmarkdown::render("Poster_Amsterdam/Poster_V5_nocaptions.Rmd")
# then to .pdf:
pagedown::chrome_print("Poster_Amsterdam/Poster_V5_nocaptions.html", output = "Poster_Amsterdam/Poster_V5_nocaptions.pdf")

# That should be it. I can't guarantee it will always wotk, but I really hope it does! 
# Have fun! (To add some randomness: I recommend the film Project Hail Mary).
