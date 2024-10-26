make_historical_data_per_spot = function(
  dir_daily_data_global,
  dir_daily_data_spot
){

  # daily global files
  files_daily_global = dir(here(dir_daily_data_global, "data"), full.names = T)

  # all
  all = map(files_daily_global, data.table::fread) %>% bind_rows()

  # per id
  all_per_id = all %>% split(.$`_id`)

  walk(seq_along(all_per_id), function(i){

    print(paste0(i, "/", length(all_per_id)))

      d = all_per_id[[i]]
      name = d$name[[1]]
      name_file = name %>% janitor::make_clean_names()
      id = d$`_id`[[1]]
      path_out = here(dir_daily_data_spot, glue("{name_file}_{id}.csv"))

      dd = dirname(path_out)
      if(!dir.exists(dd)){
        dir.create(dd, recursive = T)
      }
      data.table::fwrite(d, path_out, append = T)


  })

}
