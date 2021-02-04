# EPO Applicant Name Matching

The purpose of this project is to match standardised EPO applicant names to organisation definitions provided in the Grid.ac database. The EPO performs disambiguation on patent applicant names in the the DOCDB. These names, along with the raw names, have been matched to a list of 2000 grid identifiers, selected based on patent citations. The intention was to match all of the 2000 grid identifiers, not to match all of the disambiguated applicant names. An algorithm has been used to screen for potential matches and then a manual validation process has been performed. 

The EPO disambiguation process has been trusted as accurate so where a disambiguated applicant name has been matched to a grid identifier, all of the associated raw applicant names have also been assigned to that grid ID. If the user does not trust the EPO disambiguation process, a different kind of matching process needs to be performed, relying on the entire applicant address string. The raw applicant name is often ambiguous and not enough for accurate matching. Full applicant address strings were not available in this project, so this avenue has not been considered.

## Approach

Applicant organisation names can take many forms. Sometimes these are presented in full, sometimes abbreviated, sometimes as acronyms, sometimes misspelled, etc. The disambiguated EPO applicant names were often stemmed or abbreviated (e.g. Univ for University), and sometimes words were out of order (e.g. Univ coming first or last by default). The grid names were often followed by the country in brackets (where the organisation had a presence in multiple countries) and included designations like "system" (e.g. the University of California System) which is unlikely to appear in an applicant name.

Due to these many variations, a wide range of name variations were used as possible match sources. For Grid names, the following were used:

* main name
* acronyms
* aliases
* main name country removed
* the name provided in the list of the top 2000 grid_ids (often cleaner than the name in the grid database) 
* all of the above stemmed

For EPO names, the following were used:

* disambiguated name
* raw name
* all of the above stemmed

A custom word stemmer was produced for the task and can be found in [R/Stems.csv](R/Stems.csv). English stop words were also removed.

Once the names had been prepared, a list of potential matches for each of the 2000 grid names was generated using fuzzy text matching based on the jaro-winkler algorithm. The maximum distance of 0.1 was used, which still produced several false positive matches, but a small enough list to enable easy manual selection. The prefix factor was set to 0.1.

Note that fuzzy matching of the 2000 grid IDs against the entire list of EPO applicant names took approximately a week using a computing cluster. Matching the entire grid database is not feasible using the current method. Rerunning the process should not be undertaken lightly, though it has been written so that the data is saved after each match and the process can be stopped and restarted at any point.

Manual selection was performed from each of the proposed matches. In some cases, multiple disambiguated EPO names were matched to a single grid ID. This would suggest some incompleteness in the EPO disambiguation process.

## Data Sources

Grid data was obtained from [https://grid.ac/downloads](https://grid.ac/downloads). The 39th release was used for this project (Release 2020-12-09). The list of 2000 grid IDs of interest was provided in CSV format [R/Top Institutions by Patent Citations.csv](R/Top Institutions by Patent Citations.csv). The grid database was filtered by grid_id to only this list.

EPO data was obtained from the EPO Standardised Applicant Name Variants.csv file which used to be readily updated by the EPO. This file is no longer available on their website, but is essentially just an export of the doc_std_name field from table tls206_person in PATSTAT (and should also be available in DOCDB).

## Caveats

* Some institutions have a lens ID for every country where they have a presence e.g. Pfizer. It may not be possible to match these to the correct country without additional data. Where this occurs, attempts have been made to use the parent
* Where acquisitions have occurred, these are not necessarily captured in the grid data e.g. Bristol Myers Squibb acquired Celgene in 2019. The [R/Top Institutions by Patent Citations.csv](R/Top Institutions by Patent Citations.csv) file has Celgene associated to that grid ID, but in the most recent grid dataset, that grid ID resolves to Bristol-Myers Squibb and there is no reference to Celgene anywhere in the dataset. Many patent applicant names are likely to be Celgene, but these won't match to the grid dataset without having some knowledge of these acquisitions. Interestingly, Celgene does resolve to Bristol-Myers Squibb if entered in the disambiguator tool on grid. However, the link doesn't appear in the downloadable dataset. The names contained in [R/Top Institutions by Patent Citations.csv](R/Top Institutions by Patent Citations.csv) have been included as potential match sources where they differ from the name in Grid.
* Organisations in different countries with the same name or very similar e.g. University of Newcastle in the UK and Newcastle University in Australia may produce a problem. There is no way to tell these apart from EPO applicant names alone. It is recommended to check the applicant country against the country listed in Grid so that mismatches can be checked and handled appropriately.
* The EPO disambiguation for some organisations is believed to be poor. For example, the disambiguated Name UNIV NEW MEXICO contains both the University of New Mexico and New Mexico State University which are different organisations.
* Organisations whose name appears significantly differently in different languages and has been disambiguated to different language variants may not have been matched to every disambiguated variant in the EPO data.
* Umbrella organisations (e.g. the Russian Academy of Sciences) may prove problematic as patent applicants are likely to be the child institutes of RAS rather than RAS; however, these child institutes may not all be matched themselves if they weren't contained in the top 2000 list of grid_ids.
* The matching process was based on EPO disambiguated names as of August 2020. If the EPO disambiguation process changes the standardised name used for an organisation, this lookup table will need to be updated to reflect that.
* No guarantees are made as the accuracy of the matches. Correct matching requires some domain knowledge of the organisations involved. The author has some of this in an Australian context, but very little globally.
* The University of Wales has some complex relationships with other universities which it has now separated from or merged with. These organisations may need reviewing.
* Note that applicant names are not unique. I.e. the same applicant name has been disambiguated to multiple disambiguated names within the EPO database. If you match only on the raw applicant name, you may end up mapping to the wrong grid ID. If your data includes the disambiguated EPO names, it would be recommended to match on both the raw applicant name and the disambiguated name.
* Some of the grid IDs provided in the top 2000 file are not present in the current version of the grid database. If these grid IDs are entered as a grid URL they redirect to a different organisation (assumedly due to mergers or acquisitions etc), though these redirect linkages and not explicitly shown in the downloadable grid database. These old grid IDs have still been matched to the EPO data. It will be up to the user to decide how to deal with these cases.

## Things to check
Russian Academy of sciences
University of Paris sud = University of Paris saclay
University of Sheffield needs matching to University of Sheffield minors
UC_Davic etc
Ulvac and 
University (coll) London
India Institute of tech top level?
Dow kids
Uni SA and Flinders
Leibniz Association - too many children
INDIAN INST TECHNOLOGY
