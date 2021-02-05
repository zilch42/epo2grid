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
# write.csv(EPO, "EPO.csv", row.names = FALSE, na = '')
# grid2k %>% left_join(select(allMatches, grid_id, validated), by = "grid_id") %>% 
# left_join({filter(gridRelationships, relationship_type == "Parent") %>% select(-relationship_type)}, by = "grid_id") %>% 
#   rename(parent_id = related_grid_id) %>% 
#   left_join(select(gridBase, parentName = main, grid_id), by = c("parent_id" = "grid_id")) %>% 
#   write.csv("grid2k.csv", row.names = FALSE, na = '')

# load manual matches
manual <- read.xlsx("processed/grid2k manual matching.xlsx") %>% filter(!is.na(Matches)) %>% 
  distinct(grid_id, .keep_all = TRUE) %>% 
  separate_rows(Matches, sep = ";")

# add manual matches to allMatches DataFrame and clean up
load("processed/allMatches.Rdata")
allMatchesManual <- allMatches %>% filter(!is.na(EPOstandardName)) %>% 
  mutate(validated = "Checked From Algorithm") %>% 
  bind_rows({
    manual %>% select(grid_id, EPOstandardName = Matches, validated) %>% 
      left_join({grid2k %>% filter(Type == "main") %>% 
          rename(Type.x = Type)}, by = "grid_id")
    }) %>% 
  distinct(grid_id, EPOstandardName, .keep_all = TRUE) %>% 
  # cleanup name columns
  select(-Type.x, -Name) %>% 
  left_join({grid2k %>% filter(Type %in% c("lens", "main")) %>% 
      arrange(desc(Type)) %>% 
      distinct(grid_id, .keep_all = TRUE) %>% 
      select(grid_id, GridName = Name)}, by = "grid_id") %>% 
  left_join({grid2k %>% filter(!grepl("stem", Type)) %>% select(grid_id, AllGridNames = Name) %>% 
      group_by(grid_id) %>% 
      summarise(AllGridNames = paste0(AllGridNames, collapse = ", "))}, by = "grid_id") %>% 
  rename(EPOmatchedName = EPOname, EPOmatchType = Type.y) %>% 
  relocate(GridName, AllGridNames, .after = Country) %>% 
  # find EPO duplicates
  add_count(EPOstandardName)
  
# export to excel to fix duplicates
allMatchesManual %>% write.xlsx("processed/allMatchesManual.xlsx")
save(allMatchesManual, file = "processed/allMatchesManual.Rdata")

# load clean matches and join to epo data
cleanMatches <- read.xlsx("processed/allMatchesClean.xlsx") %>% 
  select(grid_id, GridName, AllGridNames, EPOstandardName, validated, n)
EPO %>% select(-gridMatch) %>% 
  left_join(cleanMatches, by = c("standardName" = "EPOstandardName")) %>% 
  write.xlsx("processed/EPO Look Up.xlsx")
