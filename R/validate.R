# validate proposed matches

validate <- function() {
  
  # set up match dataframes and backup
  sessionMatches <- tibble()
  sessionTime <- format(Sys.time(), "%Y%m%d_%H%M%S_")
  if (file.exists("processed/allMatches.Rdata")) load("processed/allMatches.Rdata") else allMatches <- sessionMatches
  save(allMatches, file = paste0("processed/allMatches backup ", sessionTime, ".Rdata"))
  
  # load jw proposed matches and backup
  load("processed/allProposed.Rdata")
  # save(allProposed, file = paste0("processed/allProposed backup ", sessionTime, ".Rdata"))

  # loop through grid ids
  for (g in allProposed$grid_id) {
    
    # skip grid IDs that have already been checked
    if (g %in% allMatches$grid_id) next
    
    # get matches for this grid ID
    thisMatch <- allProposed$thisMatch[allProposed$grid_id == g][[1]]
    
    # handle case if no matches
    if (is.na(thisMatch)) {
      # save results
      sessionMatches %<>% add_case(grid_id = g, validated = "Checked Manually", timestamp = Sys.time())
      allMatches %<>% add_case(grid_id = g, validated = "Checked Manually", timestamp = Sys.time())
      save(sessionMatches, file = paste0("processed/Matches ", sessionTime, ".Rdata"))
      save(allMatches, file = "processed/allMatches.Rdata")
      next
    }
    
    # names
    thisGrid <- grid2k %>% filter(grid_id == g, Type == "main") %$% Name
    proposedMatches <- thisMatch$EPOstandardName
    
    # prepare responses
    response <- ""
    
    # check user input
    while (response != "done") {
      
      # print stuff
      cat(paste0("Up Next: ", thisGrid, "\n"))
      print(select(thisMatch, index, EPOstandardName))
      View(thisMatch)
      
      # get response separate
      response <- readline(prompt = "Make Selection: ") %>% strsplit("\\s|,|\\.") %>% unlist()
      
      # checks there is a response
      if (identical(response, character(0))) {
        response <- "go again"
        next
      }
      
      # undo last selection
      if (response[1] == "undo") {
        # get previous selection
        lastGrid <- allMatches %>% filter(!is.na(Name)) %>% slice_tail(n = 1) %$% grid_id
        lastName <- allMatches %>% filter(!is.na(Name)) %>% slice_tail(n = 1) %$% Name
        # confirm selection
        confirm <- readline(prompt = paste0("Are you sure you want to remove selection for ", lastName, "? (y/n): "))
        if (str_to_lower(confirm) == "y") {
          allMatches %<>% filter(grid_id != lastGrid) 
          cat(paste0(lastName, "removed.\n"))
          save(sessionMatches, file = paste0("processed/Matches ", sessionTime, ".Rdata"))
          save(allMatches, file = "processed/allMatches.Rdata")
        }
        response <- "go again"
        next
      }
      
      # check an EPO name
      if (response[1] == "check") {
        # check a number is provided
        if (!is.na(as.numeric(response[2]))) {
          EPOall %>% filter(EPOstandardName == proposedMatches[as.numeric(response[2])]) %>% View()
          readline(prompt = "Press enter to continue:")
          next
          response <- "go again"
        } else {
          warning("Please include index of organisation to check.\n", immediate. = TRUE)
          next
      }}
      
      # convert response to vector
      selection <- response %>% as.numeric()
      
      # make sure responses are numeric
      if (anyNA(selection)) {
        warning("Some selections are not numeric\n", immediate. = TRUE)
        response <- "go again"
        next
      }
      
      # make no matches. Check manually
      if (selection == 0) {
        thisMatch %<>% filter(index == 1) %>% 
          mutate(index = NA, EPOstandardName = NA, Type.y = NA, EPOname = NA, distance = NA, 
                 NumMatches = NA, validated = "Check Manually", timestamp = Sys.time())
        response <- "done"
        break
      }
      
      # check selection is within range
      if (all(selection %in% thisMatch$index)) {
        # assign selections
        thisMatch %<>% filter(index %in% selection) %>% 
          mutate(validated = "TRUE", timestamp = Sys.time())
        response <- "done"
        break
      } else { 
        # warn and go again
        warning("Selections are not within valid range\n", immediate. = TRUE)
        response <- "go again"
      } 
      
    }
    
    # save results
    sessionMatches %<>% bind_rows(thisMatch)
    allMatches %<>% bind_rows(thisMatch)
    save(sessionMatches, file = paste0("processed/Matches ", sessionTime, ".Rdata"))
    save(allMatches, file = "processed/allMatches.Rdata")

  }
}

