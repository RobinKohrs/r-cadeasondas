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
prepare_daily_data = function(dir_raw_download=NULL, dir_daily_data = NULL, process_old_days=F){


  # files -------------------------------------------------------------------
  raw_files = dir(dir_raw_download, ".*\\.Rds", full.names = T)

  # prepared files ----------------------------------------------------------
  dir_daily_data_data = here(dir_daily_data, "data")
  path_daily_data_dates = here(dir_daily_data, "index_days.json")
  files_daily_data = dir(dir_daily_data_data, ".*\\.csv$", full.names = T)
  basenames_old_files = basename(files_daily_data) %>% tools::file_path_sans_ext()


  # find all the present days -----------------------------------------------
  dates = str_sub(basename(raw_files), 1, 10)
  dates_unique = unique(dates)


  # for each date get the data for each spot --------------------------------
  walk(dates_unique, function(d){
    print(d)
    today = Sys.Date() %>% str_replace_all("-", "_")


    # output file
    op_that_date = makePath(here(dir_daily_data, "data", glue("{d}.csv")))

    # if its not from today
    if(d != today){
      if(d %in% basenames_old_files && !process_old_days){
        print(glue("Already computed all data for: {d}"))
        return()
      }
    }


    # files for that date with all timestampts
    files_that_date = raw_files[str_which(dates, d)]
    print(glue("processing: {length(files_that_date)} files for {d}"))

    # read all the data
    data_one_day = map(files_that_date, function(f){
      bn = basename(f) %>% tools::file_path_sans_ext()
      d = readRDS(f) %>%
        mutate(timestamp = bn)
    }) %>% bind_rows

    if(!"_id" %in% names(data_one_day)) {
      return()
    }


    # for each spot and each timestamp take only one swell (the one with the
    # smallest swells_event number)
    single_swell_per_spot_timestamp = data_one_day %>%
      group_by(`_id`, timestamp) %>%
      distinct(.keep_all = T) %>%
        filter(case_when(
          all(is.na(swells__event)) ~ swells__swell_nr == 1,
          .default = swells__event == min(swells__event, na.rm = T)
        ))

    rm(data_one_day)
    # summarise per spot and day
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
        n_samples_per_day = n(),
        .groups = "drop"
      )
    rm(single_swell_per_spot_timestamp)

    write_csv(data_per_day_spot, op_that_date)
  })



  # file with all the dates available ---------------------------------------
  op_index_days = makePath(here(dir_daily_data, "index_days.json"))

  time_here = Sys.time() %>% ymd_hms
  time_utc = Sys.time() %>% with_tz("UTC") %>% ymd_hms
  diff_utc_min = difftime(time_utc, time_here) %>% as.numeric() %>% round(0)

  raw_files  %>% data.frame(file = .) %>%
    mutate(
      date_time = basename(file) %>% tools::file_path_sans_ext(),
      date = date_time %>% str_sub(1, 10),
      hour = date_time %>% str_sub(12, 13)
    ) %>%
    group_by(date) %>%
    summarise(n = n(),
              latest_hour = last(hour), ) %>%
    mutate(
      latest_time = as.POSIXct(
        glue('{str_replace_all(date, "_", "-")} {latest_hour}:00:00'),
        tz = Sys.timezone()
      ),
      timezone = Sys.timezone(),
      diff_to_utc_min = diff_utc_min
    ) %>% select(-latest_hour) -> df_times



  dates_unique_json = jsonlite::toJSON(df_times)
  write(dates_unique_json, op_index_days)



}
