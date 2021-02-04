# loader raw and supporting data files

# load libraries
library(tidyverse)
library(magrittr)
library(openxlsx)
library(fuzzyjoin)
library(stringdist)
library(tidytext)
library(stringr)
library(corpus)

# load grid data
gridBase <- read.csv("grid/grid.csv") %>% select(grid_id= ID, main = Name, Country, -City, -State) %>% 
  mutate(main = str_to_upper(main))
gridAliases <- read.csv("grid/full_tables/aliases.csv") 
gridAcronyms <- read.csv("grid/full_tables/acronyms.csv") 
gridTypes <- read.csv("grid/full_tables/types.csv") # e.g. government, education
gridRelationships <- read.csv("grid/full_tables/relationships.csv")
gridExternal <- read.csv("grid/full_tables/external_ids.csv")

# load data to match
EPO <- read.xlsx("R/EPO Standardised Applicant Name Variants.xlsx") %>% rename(rawName = name, gridMatch = grid_id)
lens2k <- read.csv("R/Top Institutions by Patent Citations.csv") %>% mutate(Name = str_to_upper(Institution)) %>% 
  select(-Institution, grid_id = GRID, Name)

# load patentsView data 
# PVassignees <-  vroom::vroom("PatentsView/assignee.tsv", delim = "\t", 
#                              col_names = TRUE, na = c("", " ", "na", "NA", "N/A"))
# PVrawAssignees <-  vroom::vroom("PatentsView/rawassignee.tsv", delim = "\t", 
#                              col_names = TRUE, na = c("", " ", "na", "NA", "N/A"))


# -------------------------USEFUL FUNCTIONS---------------------
# manually run through matches and validate
source("R/validate.R")
source("R/match_and_save.R")

