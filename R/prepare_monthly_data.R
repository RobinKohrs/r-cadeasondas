#' Prepare Monthly data
#'
#' @param dir_daily_data
#' @param dir_monthly_data
#'
#' @return
#' @export
#'
prepare_monthly_data = function(dir_daily_data = NULL,
                                dir_monthly_data = NULL) {

 # op dirs
  dir_data_out = here(dir_monthly_data, "data")
  if(!dir.exists(dir_data_out)){
    dir.create(dir_data_out, recursive = T)
  }

 # list all daily files
  files_daily = dir(dir_daily_data, ".*\\.csv", full.names = T, recursive = T)

  # get all the days
  days = basename(files_daily) %>% tools::file_path_sans_ext()

  # years
  years_months = days %>% str_sub(1,7)
  years_months_unique = unique(years_months)


  # get the data for each month
  walk(years_months_unique, function(ym){

    op_file_month = here(dir_data_out, glue("{ym}.csv"))
    if(file.exists(op_file_month)){
      print(glue("{ym} exists..."))
      return()
    }

    which_daily_files = which(years_months==ym)
    files_daily_that_month = files_daily[which_daily_files]

    # read all the daily files
    data_all_month = map(files_daily_that_month, data.table::fread) %>% bind_rows()

    # for each spot find the average
    data_one_month = data_all_month %>%
      group_by(`_id`) %>%
      summarise(
        lat = first(lat),
        lon = first(lon),
        name = first(name),
        across(matches("^daily*"), function(x){round(mean(x, na.rm = T),2)}, .names = "{.col %>% str_replace('daily','monthly')}"),
        weather_per_timestamp = paste0(weather_per_timestamp, collapse = ","),
        wind_per_timestamp = paste0(wind_per_timestamp, collapse = ","),
        n_samples_per_month = sum(n_samples_per_day, na.rm = T)
      ) %>% mutate(
        wind_times=map_chr(wind_per_timestamp, function(x){
          single_wind=str_split(x, ",")[[1]] %>% table %>% as.list()
          w = imap(single_wind, function(x,y) return(glue("{y}_{x}"))) %>% paste0(collapse = ",")
          return(w)
        }),
        weather_times=map_chr(weather_per_timestamp, function(x){
          single_weather=str_split(x, ",")[[1]] %>% table %>% as.list()
          w = imap(single_weather, function(x,y) return(glue("{y}_{x}"))) %>% paste0(collapse = ",")
          return(w)
        })
      ) %>% select(-wind_per_timestamp, -weather_per_timestamp)

    write_csv(data_one_month, op_file_month)

  })

  # file with all the months available ---------------------------------------
  op_index_months = makePath(here(dir_monthly_data, "index_months.json"))
  months_unique_json = jsonlite::toJSON(years_months_unique)
  write(months_unique_json, op_index_months)

}
