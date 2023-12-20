#' Create one file for the ~8k spots per day
#'
#' @description
#' includes Wave height, wave rating...
#'
#' @import jsonlite
#' @param dir The directory where the data is saved
#'
#' @return
#' @export
#'
#' @examples
prepare_daily_data = function(raw_data_timestamp=NULL, daily_data_dir = NULL){


  # files -------------------------------------------------------------------
  raw_files = dir(raw_data_timestamp, ".*\\.Rds", full.names = T)

  # find all the present days -----------------------------------------------
  dates = str_sub(basename(raw_files), 1, 10)
  dates_unique = unique(dates)


  # for each date get the data for each spot --------------------------------
  walk(dates_unique, function(d){

    op_that_date = makePath(here(daily_data_dir, "data", glue("{d}.csv")))
    if(file.exists(op_that_date)) return()

    # files for that date with all timestampts
    files_that_date = raw_files[str_which(dates, d)]

    # read all the data
    data_one_day = map(files_that_date, function(f){
      bn = basename(f) %>% tools::file_path_sans_ext()
      d = readRDS(f) %>%
        mutate(timestamp = bn)
    }) %>% bind_rows

    single_swell_per_spot_timestamp = data_one_day %>%
      group_by(`_id`, timestamp) %>%
      distinct(.keep_all = T) %>%
        filter(case_when(
          all(is.na(swells__event)) ~ swells__swell_nr == 1,
          .default = swells__event == min(swells__event, na.rm = T)
        ))

    rm(data_one_day)
    data_per_day_spot = single_swell_per_spot_timestamp %>%
      mutate(date = str_sub(timestamp, 1, 10)) %>%
      group_by(`_id`, date) %>%
      summarise(
        lat = first(lat),
        lon = first(lon),
        name = as.character(first(name)),
        daily_mean_swell_rating = mean(rating__value, na.rm = T),
        daily_mean_wave_height_min = mean(surf__min, na.rm = T),
        daily_mean_wave_height_max = mean(surf__max, na.rm = T),
        daily_mean_water_temperature_max = mean(waterTemp__max, na.rm =
                                                  T),
        daily_mean_water_temperature_min = mean(waterTemp__min, na.rm =
                                                  T),
        daily_mean_water_temperature_max = mean(waterTemp__max, na.rm =
                                                  T),
        weather_per_timestamp = paste0(weather__condition, collapse = ","),
        wind_per_timestamp = paste0(wind__directionType, collapse = ","),
        n_samples_per_day = n()
      )
    rm(single_swell_per_spot_timestamp)

    write_csv(data_per_day_spot, op_that_date)
  })



  # file with all the dates available ---------------------------------------
  op_index_days = makePath(here(daily_data_dir, "index_days.json"))
  dates_unique_json = jsonlite::toJSON(dates_unique)
  write(dates_unique_json, op_index_days)





}
