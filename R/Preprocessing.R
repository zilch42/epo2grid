# cleaning and preprocessing of data prior to matching

# dictionary for stemming
dictionary <- read.csv("R/Stems.csv") %>% mutate(Term = str_to_upper(Term), 
                                                 Stem = str_to_upper(Stem))

# combine grid name types
grid <- gridBase %>% 
  left_join(gridAliases, by = "grid_id") %>% 
  left_join(gridAcronyms, by = "grid_id") %>% 
  pivot_longer(cols = c("main", "alias", "acronym"), names_to = "Type", values_to = "Name") %>% 
  filter(!is.na(Name)) %>% 
  distinct() %>% 
  mutate(Name = trimws(str_to_upper(Name)))%>% 
  as.data.frame() %>% 
  mutate(text = Name)

# remove country in brackets
grid %<>% bind_rows({
  grid %>% filter(Type == "main", grepl(".*\\)$", Name)) %>% 
    mutate(Type = "main no country", Name = gsub("\\s*\\([^\\)]+\\)\\s*$","",Name))
})

# add lens name if it doesn't match any other name
grid %<>% bind_rows({
  lens2k %>% left_join(grid, by = "grid_id") %>% 
    filter(!(Name.x %in% Name.y)) %>% 
    select(grid_id, Name = Name.x, Country, Type) %>% 
    mutate(Type = "lens") %>% 
    distinct()
})

# add parent-child status
grid %<>% left_join({
  gridRelationships %>% select(-grid_id) %>% 
    filter(relationship_type %in% c("Parent", "Child")) %>% 
    arrange(relationship_type) %>% 
    distinct(related_grid_id, .keep_all = TRUE)}, 
  by = c("grid_id" = "related_grid_id"))

# filter grid dataset to lens2k and related
# related <- gridRelationships %>% filter(grid_id %in% grid2k$grid_id) %$% related_grid_id %>% unique()
# grid2k <- grid %>% filter(grid_id %in% unique(c(lens2k$grid_id, related))) %>% 
#   mutate(top2k = ifelse(grid_id %in% lens2k$grid_id, TRUE, FALSE))
# filter grid dataset to lens2k (overwrite)
grid2k <- grid %>% filter(grid_id %in% lens2k$grid_id)

# stem names
grid2k %<>% bind_rows({
  # stem text
  a <- as_corpus_frame(grid2k)
  text_filter(a)$map_case <- FALSE
  text_filter(a)$drop_punct <- TRUE
  text_filter(a)$drop <- str_to_upper(stopwords_en)
  text_filter(a)$stemmer <- new_stemmer(dictionary$Term, dictionary$Stem)
  b <- sapply(text_tokens(a), paste, collapse = " ")
  # add stemmed text
  grid2k %>% add_column(stemmed = b) %>% filter(Name != stemmed) %>% 
    mutate(Type = paste0(Type, " stemmed"), Name = stemmed) %>% 
    select(-stemmed) %>% 
    return()
}) %>% select(-text)

# load EPO counts
EPOcounts <- read.csv("PATSTAT/counts1.csv", sep = ";") %>% rename(PatentApps = NumberOfPatentApplications)

# combine EPO names and add counts
EPOall <- EPO %>% left_join(EPOcounts, by = c("standardName" = "doc_std_name")) %>% 
  rename(clean = standardName, dirty = rawName) %>% 
  mutate(EPOstandardName = clean) %>% 
  pivot_longer(cols = c("clean", "dirty"), names_to = "Type", values_to = "EPOname") %>% 
  select(-gridMatch) %>% 
  distinct() %>% 
  as.data.frame()
  
# clean and stem EPO
EPOall %<>% bind_rows({
  # stem text
  a <- as_corpus_frame(EPOall %>% mutate(text = EPOname))
  text_filter(a)$map_case <- FALSE
  text_filter(a)$drop_punct <- TRUE
  text_filter(a)$drop <- str_to_upper(stopwords_en)
  text_filter(a)$stemmer <- new_stemmer(dictionary$Term, dictionary$Stem)
  b <- sapply(text_tokens(a), paste, collapse = " ")
  # add stemmed text
  EPOall %>% add_column(stemmed = b) %>% filter(EPOname != stemmed) %>% 
    mutate(Type = paste0(Type, " stemmed"), EPOname = stemmed) %>% 
    select(-stemmed) %>% 
    return()
})

rm(EPOcounts)
