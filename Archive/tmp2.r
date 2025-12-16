tmp <- ds %>%
  filter(ID %in% IDEx)  %>%
  select(nLineCross, stimulus, Cond, repetition, x_zs,y_zs,y,x)

tmp %>%
  filter(Cond %in% "number") %>%
  group_by(stimulus) %>%
  arrange(stimulus) %>%
  arrange(ordered(stimulus, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday","Sunday"))) %>% 
  arrange(ordered(stimulus, levels = c("January", "February", "March", "April", "May","June","July","August","September","October","November","December"))) %>%
  ungroup()  %>%
  group_by(ID, Cond,repetition) %>%
  mutate(nLineCross2 = (count_self_intersections(x_zs,y_zs, verbose = FALSE))) %>%
  ggplot(aes(x = x_zs, y = y_zs, group = stimulus, label = nLineCross2, fill = stimulus)) +
  geom_path(aes(x = x_zs, y = y_zs, group = repetition), alpha = 0.2) +
  geom_text(aes(x = 0, y = 2)) +
  facet_grid( ~ repetition) +
  theme_minimal()


tmp %>%
  filter(Cond %in% "number") %>%
  group_by(stimulus) %>%
  arrange(stimulus) %>%
  arrange(ordered(stimulus, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday","Sunday"))) %>% 
  arrange(ordered(stimulus, levels = c("January", "February", "March", "April", "May","June","July","August","September","October","November","December"))) %>%
  ungroup()  %>%
  group_by(ID, Cond,repetition) %>%
  mutate(nLineCross2 = (count_self_intersections(x_zs,y_zs, verbose = FALSE))) %>%
  ggplot(aes(x = x, y = y, group = stimulus, label = nLineCross2, fill = stimulus)) +
  geom_path(aes(x = x, y = y, group = repetition), alpha = 0.2) +
  geom_text(aes(x = 0, y = 2)) +
  facet_grid( ~ repetition) +
  theme_minimal()