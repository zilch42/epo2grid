# Testing Sandbox

# investigate epo name abbreviation
EPO %>% unnest_tokens(word, name) %>% group_by(word) %>%
  tally() %>% arrange(desc(n)) %>% head(100) %>% View()

# Check matches between grid and provided data names
lens2k %>% left_join(grid, by = "grid_id") %>% filter(Type == "main") %>% 
  mutate(Match = ifelse(Name.x == Name.y, TRUE, FALSE)) %>% filter(!Match) %>% View()

# try fuzzy join on standard name
grid %>% filter(grid_id %in% lens2k$grid_id) %>% fuzzy_left_join(EPO, by = c("Name", "standardName")) %>% View()if