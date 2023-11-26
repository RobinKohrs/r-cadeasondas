make_geo_data_of_all_spots = function(per_day_dir = "~/data/surfdata/per_day/", outfile=NULL){

  # list all per Day files
  per_day_files = dir(per_day_dir, ".*\\.Rds", full.names = T)

  # data
  n_spots = map_dbl(per_day_files, function(f){
    print(f)
    d = readRDS(f)
    if(nrow(d) == 0) return(NA)
    d = d %>% distinct(`_id`)
    nrow(d)
  })

  # file with the highest number of spots
  d = readRDS(per_day_files[which.max(n_spots)])

  # get all the spots
  spots = d %>%
    select(`_id`, name, lat, lon) %>%
    distinct(`_id`, .keep_all = T) %>%
    rename(id=`_id`)

  if (!is.null(outfile)) {
    write_csv(spots, outfile)
  }
}
