cols9 <- c(
  "0" = "#2b4e77",
  "1" = "#1b9e77",
  "2" = "#d95f02",
  "3" = "#7570b3",
  "4" = "#e7298a",
  "5" = "#66a61e",
  "6" = "#e6ab02",
  "7" = "#a6761d",
  "8" = "#666666",
  "9" = "#1f78b4"
)

for(col_i in 1:36){
  ds %>%
    filter(ID %in% "1025_MaJo") %>%
    filter(Cond %in% "month") %>%
    filter(row_number() %in%  1:col_i) %>%
    group_by(stimulus) %>%
    arrange(stimulus) %>%
    arrange(ordered(stimulus, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday","Sunday"))) %>% 
    arrange(ordered(stimulus, levels = c("January", "February", "March", "April", "May","June","July","August","September","October","November","December"))) %>% # Start ggplot
    ggplot(aes(x = x_zs, y = y_zs, group = stimulus, label = stimulus, fill = stimulus)) +
    geom_polygon() +
    geom_path() +
    geom_text(aes(x = x_zs, y = y_zs), size = 2, alpha = 0.7) +
    xlim(-3,3) +
    ylim(-3,3) +
    coord_equal() +
    # scale_fill_manual(values = cols9) +
    theme_minimal() +
    guides(fill="none")
  ggsave(sprintf("Figures_Present/Col_Num_%02d.png", col_i))
  # ggsave(paste0("Figures_Present/",col_i,"Col_Num",".png"))
}


# install.packages("magick")
library(magick)

imgs <- image_read(list.files("Figures_Present", full.names=TRUE))

# imgs <- image_resize(imgs, "1400x1400!")   
imgs <- image_repage(imgs)      
# imgs <- image_coalesce(imgs) 

gif <- image_animate(imgs, fps = 2)
image_write(gif, "ID_ExConsTest.gif")