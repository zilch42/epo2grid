# make matches and save
# matching takes a really long time so save after each one

match_and_save <- function() {
  
  # set up match dataframes
  sessionProposed <- tribble(~grid_id, ~thisMatch)
  sessionTime <- format(Sys.time(), "%Y%m%d_%H%M%S_")
  if (file.exists("processed/allProposed.Rdata")) load("processed/allProposed.Rdata") else allProposed <- sessionProposed
  if (file.exists("processed/allMatches.Rdata")) load("processed/allMatches.Rdata") else allMatches <- tibble(grid_id = NA)
  
  # loop through grid ids
  for (g in unique(grid2k$grid_id)) {
  
    # skip grid IDs that have already been checked
    if (g %in% allMatches$grid_id) next
    if (g %in% allProposed$grid_id) next
    
    # get matches for this grid ID
    thisMatch <- grid2k %>% filter(grid_id == g) %>% 
      stringdist_inner_join(EPOall, by = c("Name" = "EPOname"), 
                            method = "jw", max_dist = 0.1, distance_col = "distance", p = 0.1)
    
    # if matches were found, process
    if (nrow(thisMatch) > 0) {
      thisMatch %<>%  mutate(validated = NA) %>% 
        add_count(EPOstandardName, name = "NumMatches") %>% 
        arrange(distance) %>% 
        distinct(EPOstandardName, .keep_all = TRUE) %>% 
        relocate(PatentApps, validated, .after = last_col()) %>% 
        add_column(index = 1:nrow(.), .before = "EPOstandardName")
    } else thisMatch <- NA
    
    # save results
    sessionProposed %<>% add_row(grid_id = g, thisMatch = list(thisMatch))
    allProposed %<>% add_row(grid_id = g, thisMatch = list(thisMatch))
    save(sessionProposed, file = paste0("processed/Proposed ", sessionTime, ".Rdata"))
    save(allProposed, file = "processed/allProposed.Rdata")
    
  }
}