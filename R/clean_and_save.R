#' clean up and save
#'
#' @param matches current matche sdata.frame
#' @param match.type string label for match type algorithm used
#'
#' @return none. saves some .Rdata files to /processed

clean_and_save <- function(matches = matches, match.type) {
  # clean up and select validated
  matches %<>% filter(validated) %>% select(-Country, -Type, -Match, -relationship_type)
  
  # save this set of matches
  save(matches, file = paste0("processed/", match.type, " matches ", Sys.time(), ".Rdata"))
  
  # Get other processed files
  files <- list.files("processed/", pattern = "^processed.*.Rdata")
  
  # If none, create the first one, otherwise append
  if (length(files) == 0) save(matches, file = paste0("processed/processed ", Sys.time(), ".Rdata")) else {
    # flowed most recent process file
    processed <- load(paste0("processed/", sort(files, decreasing = TRUE)[1]))
    # append new matches
    new <- bind_rows(processed, matches)
    save(new, file = paste0("processed/processed ", Sys.time(), ".Rdata"))
  }
}