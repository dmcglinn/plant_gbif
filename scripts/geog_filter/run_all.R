## Run all filtering scripts sequentially
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Date: 04/2015
## Description:
## This script calls each of the data grooming scripts sequentially
## and thus can be used to generate all relevant data products. 
## The relevant GIS datalayers that are called must be present in the 
## directory '../gis/' 
## and the following R packages are installed: 
## 'sp','raster','rgdal','foreach','snow','snowfall','doSNOW'

dir.create('./log_files')

## Remove problematic locality field--------------------------------
script_file = './scripts/geog_filter/trim_raw_gbif.R'
log_file = './log_files/trim_raw_gbif.log'
input_file = './data/0019773-151016162008034.csv'

cmd = paste('Rscript', script_file, input_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Break up GBIF data dump into smaller files-----------------------
dir.create('./data/gbif_chunks')

script_file = './scripts/split-csv.py'
options = '-v -d'
nlines = '-n 1000000'
log_file = './log_files/chunk_gbif.log'
input_file = './data/0019773-151016162008034-trimmed.csv'

cmd = paste('python', script_file, options, nlines,
            '-o./data/gbif_chunks/chunk-', input_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Prepare remotely sensed data for queries------------------------
script_file = './scripts/geog_filter/setup_geog_data.R'
log_file = './log_files/setup_geog_data.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Filter dataset-------------------------------------------------
script_file = './scripts/geog_filter/geog_filter.R'
log_file = './log_files/geog_filter.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Query remotely sensed data--------------------------------------
script_file = './scripts/geog_filter/climate_query.R'
log_file = './log_files/climate_query.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Compile all records, drop remaining duplicates, and export-------
script_file = './scripts/geog_filter/export_all_records.R'
log_file = './log_files/export_all_records.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)

## Summarize records, output quantiles-------------------------------
script_file = './scripts/geog_filter/climate_summary.R'
log_file = './log_files/climate_summary.log'

cmd = paste('Rscript', script_file, '>', log_file, '2>&1')
system(cmd, wait=F)
