tmpID <- ds %>% 
  filter(ID %in% c("10_AS")) %>% 
  select(stimulus, x ,y, x_zs,y_zs) %>%
  filter(stimulus == "9")


# "10_AS"     "2002_PaKr" "PP15" 
ds <- ds %>%
  group_by(ID) %>% # Not by Cond, so to avoid NaN's
  mutate(x_zs = scale(x)) %>%
  mutate(y_zs = scale(y))

# 10_AS, 2002_PaKr,PP15 
ds %>%
  filter(is.na(x_zs)) %>%
  select(ID,stimulus,x,y)