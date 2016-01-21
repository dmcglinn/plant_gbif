## Part V - Compile all records, drop remaining duplicates, and export
## Author: Dan McGlinn
## Contact: danmcglinn@gmail.com
## Description:
## read in the genus level datafiles and rbind them together without summarizing
## then export two files:
## 1) 'gbif_all_remote_data.csv' which has information on all the relevant variables
## 2) 'gbif_coords.csv' which only has the fields: spname, long, lat, and alt

library(readr)

input_dir = './data/genus_sort/'
output_dir = './data/'
file_names = dir(input_dir)
genus_files = sapply(strsplit(file_names,'-[[:digit:]]'), function(x) unlist(x)[[1]])
genus_list = sort(unique(genus_files))

for (i in seq_along(genus_list)) {
    for (j in which(genus_files %in% genus_list[i])) {
        dat_temp = read_csv(file.path(input_dir, file_names[j]))
        if(!exists('dat'))
            dat = dat_temp
        else
            dat = rbind(dat, dat_temp)
    }
    rm(dat_temp)
    ## drop duplicates
    filtering_columns = c('species', 'decimallatitude', 'decimallongitude')
    dat = subset(dat, !duplicated(dat[ , filtering_columns]))
    ## order the rows alphabetically by species name
    dat = dat[order(as.character(dat$species)), ]
    ## now begin exporting process
    subfields = c("species", "decimallongitude", "decimallatitude")
    if (i == 1) {
        write_csv(dat, file.path(output_dir, 'gbif_all_remote_data.csv'))
        write_csv(dat[ , subfields], file.path(output_dir, 'gbif_coords.csv'))
    }
    else {
        write_csv(dat, file.path(output_dir,'gbif_all_remote_data.csv'), 
                  append=TRUE)
        write_csv(dat[ , subfields], file.path(output_dir, 'gbif_coords.csv'),
                  append=TRUE) 
    }
    rm(dat)
    print(paste('Genus', genus_list[i], 'appended'))
}
