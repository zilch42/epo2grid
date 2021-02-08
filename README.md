# EPO Applicant Name Matching

The purpose of this project is to match standardised EPO applicant names to organisation definitions provided in the Grid.ac database. The EPO performs disambiguation on patent applicant names in the the DOCDB. These names, along with the raw names, have been matched to a list of 2000 grid identifiers, selected based on patent citations. The intention was to match all of the 2000 grid identifiers, not to match all of the disambiguated applicant names. An algorithm has been used to screen for potential matches and then a manual validation process has been performed. 

## Usage

The final look up table between EPO standardised names and grid IDs can be found in [EPO Look Up v1.xlsx](EPO Look Up v1.xlsx). Lookups will need to be performed on **BOTH** the standardName and rawName columns. The raw applicant name cannot be used alone as it is not unique and the standardised name cannot be used alone because some corrections have been made to the mapping within standardised names were it was clear that multiple organisations had been disambiguated to the same standardised name. Logic will also need to be included for new data that has a matching disambiguated standardName but a different rawName that isn't yet on the look up table.

## Approach

Applicant organisation names can take many forms. Sometimes these are presented in full, sometimes abbreviated, sometimes as acronyms, sometimes misspelled, etc. The disambiguated EPO applicant names were often stemmed or abbreviated (e.g. "Univ" for University), and sometimes words were out of order (e.g. "Univ" coming first by default). The grid names were often followed by the country in brackets (where the organisation had a presence in multiple countries) and included designations like "system" (e.g. the University of California System) which is unlikely to appear in an applicant name.

Due to these many variations, a wide range of name variations were used as possible match sources. For Grid names, the following were used:

* main name
* acronyms
* aliases
* main name country removed
* the name string provided in the list of the top 2000 grid_ids (often cleaner than the name in the grid database) 
* all of the above stemmed

For EPO names, the following were used:

* disambiguated name
* raw name
* all of the above stemmed

A custom word stemmer was produced for the task and can be found in [R/Stems.csv](R/Stems.csv). English stop words were also removed.

Once the names had been prepared, a list of potential matches for each of the 2000 grid names was generated using fuzzy text matching based on the jaro-winkler algorithm. The maximum distance of 0.1 was used and the prefix factor was set to 0.1. This still produced several false positive matches for each organisation, but resulted in a small list from which the correct match could be easily chosen.

Note that fuzzy matching of the 2000 grid IDs against the entire list of EPO applicant names took approximately a week using a computing cluster and still required significant manual validation. Matching the entire grid database is not feasible using the current method. Rerunning the process should not be undertaken lightly, though it has been written so that the data is saved after each match and the process can be stopped and restarted at any point.

Manual selection was performed from each of the proposed matches. In some cases, multiple disambiguated EPO names were matched to a single grid ID, indicating some incompleteness in the EPO's disambiguation process.

Manual selection of the proposed matches from the algorithm resulted in matches for approximately 60% of the top 2000 organisations. Manual matching was then performed in Excel to try and find matches for the remaining organisations. Overall, matches were only found for 67% of the organisations on the top 2000 list. In some cases the unmatched organisations simply won't be patenting organisations, in other cases they are children of parents that have been matched, and in other cases they are old grid IDs which have been replaced by a new organisational definition and are essentially duplicates. Others still may be the result of name changes, mergers, language barriers, translation errors, etc.

For a full list of which organisations have and have not been matched see [Top2k Status.csv](Top2k Status.csv).

## Data Sources

Grid data was obtained from [https://grid.ac/downloads](https://grid.ac/downloads). The 39th release was used for this project (Release 2020-12-09). The list of 2000 grid IDs of interest was provided in CSV format [R/Top Institutions by Patent Citations.csv](R/Top Institutions by Patent Citations.csv). The grid database was filtered by grid_id to only this list. Note that some of the grid IDs that were present in the provided top 2000 list were not in the most recent version of the grid database.

EPO data was obtained from the EPO Standardised Applicant Name Variants.csv file which used to be readily updated by the EPO. This file is no longer available on their website, but is believed to just an export of the doc_std_name field from table tls206_person in PATSTAT (and should also be available in DOCDB).

## Caveats

* The EPO disambiguation process has generally been trusted as accurate so where a disambiguated applicant name has been matched to a grid identifier, (except in a few obvious cases) all of the associated raw applicant names have also been assigned to that grid ID. If the user does not trust the EPO disambiguation process, a different kind of matching process needs to be performed, relying on the entire applicant address string because the raw applicant name is often ambiguous and not enough for accurate matching. Full applicant address strings were not available in this project, so this avenue has not been considered. 
* Some institutions have a lens ID for every country where they have a presence e.g. Pfizer. It was not possible to match these to the correct country without additional data. Where this occurs, attempts have been made to use the parent. 
* Where acquisitions have occurred, these are not necessarily captured in the grid data e.g. Bristol Myers Squibb acquired Celgene in 2019. The [R/Top Institutions by Patent Citations.csv](R/Top Institutions by Patent Citations.csv) file has Celgene associated to that grid ID, but in the most recent grid dataset, that grid ID resolves to Bristol-Myers Squibb and there is no reference to Celgene anywhere in the dataset. Many patent applicant names are likely to be Celgene, but these won't match to the grid dataset without having some knowledge of these acquisitions. Interestingly, Celgene does resolve to Bristol-Myers Squibb if entered in the disambiguator tool on grid. However, the link doesn't appear in the downloadable dataset. The names contained in [R/Top Institutions by Patent Citations.csv](R/Top Institutions by Patent Citations.csv) have been included as potential match sources where they differ from the name on Grid.
* Organisations in different countries with the same name or very similar e.g. University of Newcastle in the UK and Newcastle University in Australia may produce a problem. There is no way to tell these apart from EPO applicant names alone. It is recommended to check the applicant country against the country listed in Grid so that mismatches can be checked and handled appropriately.
* The EPO disambiguation for some organisations is believed to be poor. For example, the disambiguated Name UNIV NEW MEXICO contains both the University of New Mexico and New Mexico State University which are different organisations.
* Organisations whose name appears significantly differently in different languages and has been disambiguated to different language variants may not have been matched to every disambiguated variant in the EPO data.
* The matching process was based on EPO disambiguated names as of August 2020. If the EPO disambiguation process changes the standardised name used for an organisation, this lookup table will need to be updated to reflect that.
* No guarantees are made as the accuracy of the matches. Correct matching requires some domain knowledge of the organisations involved. The author has some of this in an Australian context, but very little globally.
* Note that applicant names are not unique. I.e. the same applicant name has been disambiguated to multiple disambiguated names within the EPO database. If you match only on the raw applicant name, you may end up mapping to the wrong grid ID.
* Some of the grid IDs provided in the top 2000 file are not present in the current version of the grid database. If these grid IDs are entered as a grid URL they redirect to a different organisation (assumedly due to mergers or acquisitions etc), though these redirect linkages and not explicitly shown in the downloadable grid database. These old grid IDs have still been matched to the EPO data. It will be up to the user to decide how to deal with these cases.

## Special Cases

The following is a list of special cases found and handled differently. There are many other cases that probably need special treatment but haven't yet received it.

* Several US University Systems have been added in order to group multiple university campuses where the specific campus was not apparent from the EPO data. Specific campuses were generally matched to their own grid ID if they were present in the top 2000 list. These will need merging up to the parent organisation for proper parent counts.
* Mount Sinai Hospital (USA and Canada) is ambiguous. I assumed that Mount Sinai Hospital Corporation matched to the USA, and I went up one level to the parent grid organisation: Mount Sinai Health System, as the individual hospitals in the USA were not in the grid data.
* The parent organisations for the following were added from grid in place of multiple children who were in the top 2000 list as the EPO names were not specific enough to distinguish between them: Abbott, Bristol-Myers Squibb, Thermo Fisher
* The University of Texas health science centres (at Houston, San Antonio and Tyler) have no parent apart from the University of Texas system and have all been matched to the University of Texas health science Centre (EPO). There will therefore be duplication here.
* Soochow University (China and Taiwan) are entirely ambiguous. Matched to both.
* York University and University of York are entirely ambiguous. Matched to both.
* Univ Newcastle was assumed to be the one in the UK not Australia.
* The University of Miami and Miami University are entirely ambiguous. Generally I have gone with the University of Miami except where the raw applicant name is specifically Miami University.
* Large associations (e.g. Chinese Academy of science, Russian Academy of science, Helmholtz Association, Max Planck, Leibniz Association, etc) are problematic because they are generally not the applicant listed on patents, but they have many many children, most of which were not present in the top 2000 list, so it won't be possible to aggregate the children up to provide proper counts for these parents. I considered expanding the list of organisations to match to include all parents and children of the top 2000, but this would have expanded the list to 7500, and given that this has already taken the best part of a month it was not feasible.
* The Indian institutes of technology do not have an overarching parent, but some of the applicants in the EPO data are not associated to a specific campus. Those that were not clear were matched to the Indian Institute of technology KHARAGPUR, as it was the first one established.
* The University of Wales has some complex relationships with other universities which it has now separated from or merged with. These organisations may need reviewing.

## Final Remarks

The EPO disambiguation process is OK. It is certainly better than nothing, but is by no means perfect. In many cases applicant names are ambiguous and can't be properly matched to a disambiguated identifier. In many other cases different organisations share names that are too similar and has been disambiguated as the same organisation. Data companies spend years developing, reviewing, improving, refining and correcting name disambiguation. This work should be thought of as a good starting point, with the view that continuous improvement and correction will be required.
