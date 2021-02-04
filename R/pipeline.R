#processing pipeline

# load data
source("R/Load.R")

# clean and prepare data
source("R/Preprocessing.R")

# find matches with jaro-winkler
# match_and_save()

# manually select and validate matches
# validate()

# exports for checking in Excel
write.csv(EPO, "EPO.csv", row.names = FALSE, na = '')
write.csv(EPOall, "EPOall.csv", row.names = FALSE, na = '')
allMatches %<>% mutate(validated = ifelse(is.na(Country), "No Matches", validated)) 
# grid organisations
grid2k %>% left_join(select(allMatches, grid_id, validated), by = "grid_id") %>% 
  left_join({filter(gridRelationships, relationship_type == "Parent") %>% select(-relationship_type)}, by = "grid_id") %>% 
  rename(parent_id = related_grid_id) %>% 
  left_join(select(gridBase, parentName = main, grid_id), by = c("parent_id" = "grid_id")) %>% 
  write.csv("grid2k.csv", row.names = FALSE, na = '')
# epo matches
EPO %>% distinct() %>% nrow()
left_join(select(allMatches, grid_id, EPOstandardName), by = "EPOstandardName") %>% 
  left_join(grid2k, by = "grid_id") %>% 
  pivot_wider(names_from = Type.y, values_from = Name, values_fill = NA, values_fn = list(Name  = ~paste(., collapse = ";"))) %>% nrow()
  select(-`NA`) %>% 
  write.csv("EPO matched jw.csv", row.names = FALSE, na = '')
