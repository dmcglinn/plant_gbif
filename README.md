plants-gbif: fire regime evolution project
==========================================

This repository is for data and scripts for matching the taxon names in the [D.C. Tank phylogeny][TankTree] (see [Zanne et al 2013][Zanne-etal-2013]) with plant occurrence records in the [Global Biodiversity Information Facility (GBIF) dataset][GBIF]. This is a step in the [bigphylo][bigphylo] project that is part of the Archibald and Lehman ["The co-evolution of plants and fire and consequences for the Earth system" NESCent workshop][FireAndPlants].

Note: one thing I (Schwilk) have not cleaned up is that all of Schwilk's scripts (python or R) assume that the "scripts" directory is the working directory. McGlinn's scripts assume that "." is the working directory.

Matching GBIF occurrence records
--------------------------------

Match the taxon names with plant occurrence records in the [Global Biodiversity Information Facility (GBIF) dataset][GBIF]. 

These scripts read text files as utf-8 and immediately treat as unicode internally. All matching and comparisons work on unicode internally. All written output is encoded as utf-8. This has a slight speed penalty but is worth it and necessary as there are unicode characters in the GBIF data and some in other taxon name sources.

### Analysis steps / walkthrough ###

Much code for steps 1-2 are in the [taxon-name-utils repository](https://github.com/schwilklab/taxon-name-utils). That repository aims to create a set of general and useful name matching and synonym finding tools. The code in this `plant_gbif` repo assumes that both repositories are cloned in the same parent directory --- these scripts modify the python module search path to include the taxon-name-utils/scripts directory so that the synonym matching code will run.

#### 1. Create expanded list of canonical names ####

Our canonical names: `../../bigphylo/species/big-phylo-leaves.txt`.  We would like to search for occurrences of these species accounting for synonyms, so we use synonymize.py to expand the names list to all canonical names plus all synonyms. We use [The Plant List][TPL] data (see https://github.com/schwilklab/taxon-name-utils).

```
expand_canonical_names.sh
```

This will create a names list, `../query_names/tanknames-expanded.txt`. This expanded names list includes each name in the original list and all synonyms.

#### 2. Extract all possible name binomials in the full GBIF occurrence data ####

First, we must extract all possible taxon binomials from the full GBIF Plantae data. Schwilk downloaded the the [full GBIF Plantae data on 2017-04-20][GBIF-download] (`0082884-160910150852091.zip`). This is approximately 180 million occurrence records. This compressed zip file is not in the git repository but is referred to by the `extract_gbif_names.py` script. Other large data such as these are stored in the `/data/` directory of the repo which is ignored by git (see `.gitignore`).

```
python extract_gbif_names.py
```

This will create the names list. The current version is `../query_names/gbif-occurrences-names_170420.csv`. This is all unique binomial names in the GBIF Plantae occurrences data (426,632).

#### 3. Conduct fuzzy name matching ####

This step creates a lookup table that associates every possible taxon binomial in the full GBIF Plantae occurrence database with its match in the expanded canonical names list created in step 1. The code uses `fuzzy_match.py` from the taxon-name-utils repository to do matching based on a combination of Levenshtein distances and Jaro-Winkler distbances. See the source files for details.

We can create a lookup table that maps each name in this list to the expanded canonical names list, omitting any name that does not have a sufficiently close match according to the settings in `fuzzy_match.py`. A short python script accomplishes this:

```
python make_canonical_gbif_fuzzy_lookup.py
```

The resulting table is `../query_names/gbif_tank_lookup_170420.csv`. Raw, this results in 50494 matched names from the expanded canonical list, leaving 376138 unmatched GBIF names. The threshold distances hard-coded in the script above over-match by design. Therefore, this table requires a bit of cleaning in R to throw out a few false-positive matches. Use `scripts/clean_gbif2canonical.R`. The lookup table saved by that R script is `gbif_tank_lookup_170420_cleaned.csv`.  After manually marking additional removals (false matches), the resulting file was saved as `gbif_tank_lookup_170420_cleaned_manual.csv`. The R script above then reads in this modified version and throws away the rows marked as false positives and saves the result as `gbif-tank_lookup_final.csv`. This holds 48,767 matches of which 3,154 are fuzzy matches.

The manual step could probably be eliminated with enough special cases hard-coded in the matching script. See the comments near the bottom of that R script for the rules used in manual marking for removal.

#### 4. Extract matching records from the GBIF Plantae data ####

This step reads line by line through the 180 million GBIF occurrence records  and extracts those for which 1) there is a latitude and longitude, and 2) for which the species name matches a name in `gbif_tank_lookup_final.csv`.

```
python extract_matched_gbif_occurrences.py

```
Total records scanned = 180344517
Total matches found = 107705783

This extraction step scanned 180,344,517 records and found 107,705,783 records matching our names. The result is saved as a large comma-separated file, current version is `.data/gbif-occurrences_extracted_170420.csv`. This is our full species occurrence data.

#### 5. Data cleaning ####

This file goes to Dan McGlinn for further cleaning.

[TODO] add cleaning steps.

[bigphylo]: https://github.com/Fireandplants/bigphylo
[FireAndLants]: http://www.nescent.org/science/awards_summary.php?id=423
[GBIF]: http://www.gbif.org/
[GBIF-download]: GBIF.org (19th April 2017) GBIF Occurrence Download http://doi.org/10.15468/dl.smz7qu
[TPL]: http://www.theplantlist.org/
[TankTree]: http://datadryad.org/resource/doi:10.5061/dryad.63q27/3
[Zanne-etal-2013]: http://www.nature.com/nature/journal/v506/n7486/full/nature12872.html



