# manually run through matches and validate
validate <- function() {
  # set up temporary data frame
  df <- matches
  
  # loop through matched names
  for (x in unique(df$standardName)) {
    EPOmatch <- df %>% filter(standardName == x) %>% select(standardName, rawName)
    proposedMatches <- df %>% filter(standardName == x) %$% grid_id %>% unique()
    gridMatches <- grid %>% filter(grid_id %in% proposedMatches)
    
    # prints stuff
    cat(paste0("Up Next: ", x, "\n"))
    
    # Max number of rows
    rows <- max(22, nrow(EPOmatch))
    
    # prepare DataFrame for viewing
    viewdf <- EPOmatch %>% mutate(x0 = "")
    
    # add extra blank rows if needed
    if (nrow(viewdf) < rows) viewdf[(nrow(viewdf)+1):rows, ] <- ""
    
    # add each matched grid ID
    i <- 1
    for (g in proposedMatches) {
      # actual match string
      matchString <- df %>% filter(standardName == x, grid_id == g) %$% Match %>% unique()
      
      # prepare and rotate columns
      thisMatch <- gridMatches %>% filter(grid_id == g)
        # pivot_wider(names_from = Type, values_from = Name) %>% 
        # mutate(index = i, matchedOn = matchString)
      matchColumn <- bind_rows(
        {thisMatch %>% select(-Type, -Name) %>% 
            pivot_longer(cols = c("grid_id", "Country", "relationship_type"), names_to = "x", values_to = "y") %>% 
            distinct()}, 
        {thisMatch %>% select(x = Type, y = Name)}) %>% 
        add_case(x = "matchedOn", y = matchString, .before = 1) %>% 
        add_case(x = "index", y = as.character(i), .before = 1) %>% 
        add_column(blank = "")
  
      # flag actual match type
      matchColumn %<>% mutate(x = if_else(y == matchString, paste0(x, "*"), x, missing = x))
  
      # rename columns with index
      names(matchColumn) <- c(paste0("Info ", i), paste0("Match ", i), paste0("x", i))
      
      # add extra blank rows if needed
      if (nrow(matchColumn) < rows) matchColumn[(nrow(matchColumn)+1):rows, ] <- ""
      
      # index for next grid match
      i <- i + 1
      
      # connect to data frame
      viewdf %<>% bind_cols(matchColumn)
    }
    
    # show DataFrame to user
    View(viewdf)
    
    # prepare responses
    possible <- c(1:length(proposedMatches), "x")
    response <- ""
    
    # wait for input
    while (!(response %in% possible)) {
      response <- readline(prompt = "Make Selection: ")  
    }
    
    if (response == "x") {
      # not validated
      matches$validated[matches$standardName == x] <- FALSE
    } else {
      # match accepted
      matches$validated[matches$standardName == x] <- TRUE
      matches$grid_id[matches$standardName == x] <- proposedMatches[response]
      # clear other parameters from grid match. Look up later
      matches$Country[matches$standardName == x] <- NA
      matches$Type[matches$standardName == x] <- NA
      matches$Match[matches$standardName == x] <- NA
      matches$relationship_type[matches$standardName == x] <- NA
    }
    
  }
}