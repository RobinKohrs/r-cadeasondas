#' Prepare Monthly data
#'
#' @param daily_data_dir
#' @param monthly_data_dir
#'
#' @return
#' @export
#'
#' @examples
prepare_monthly_data = function(daily_data_dir = NULL,
                                monthly_data_dir = NULL) {

 # op dirs
  op_dir_data = here(monthly_data_dir, "data")
  if(!dir.exists(op_dir_data)){
    dir.create(op_dir_data, recursive = T)
  }

 # list all daily files
  daily_files = dir(daily_data_dir, ".*\\.csv", full.names = T, recursive = T)

  # get all the days
  days = basename(daily_files) %>% tools::file_path_sans_ext()

  # years
  years_months = days %>% str_sub(1,7)
  years_months_unique = unique(years_months)


  # get the data for each month
  walk(years_months_unique, function(ym){

    op_file_month = here(op_dir_data, glue("{ym}.csv"))
    if(file.exists(op_file_month)){
      return()
    }

    which_daily_files = which(years_months==ym)
    daily_files = daily_files[which_daily_files]

    # read all the daily files
    data_all_month = map(daily_files, data.table::fread) %>% bind_rows()

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

}
