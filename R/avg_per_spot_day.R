#' Break down each spot on one row per day
#'
#' @param dir_csvs
#' @param dir_daily_spot_clean
#'
#' @return
#' @export
#'
#' @examples
avg_per_spot_day = function(dir_csvs = "~/data/surfdata/per_spot/", dir_daily_spot_clean="~/data/surfdata/per_spot_clean/"){

  # data for each spot
  csvs_each_spot = dir(dir_csvs, ".*\\.csv", full.names = T)

  # do something for each spot
  walk(seq_along(csvs_each_spot), function(i){

    print(i)

    # file to spot data
    f = csvs_each_spot[[i]]

    # raw data
    d = data.table::fread(f)

    # output file for that spot
    op = glue("{dir_daily_spot_clean}/{basename(f)}")


    # only use the swell with the lowest "swell__event" ?!
    d_one_swell_per_time = d %>%
      group_by(time) %>%
      filter(case_when(
        all(is.na(swells__event)) ~ swells__swell_nr == 1,
        .default = swells__event == min(swells__event, na.rm = T)
      ))


    # for each day get the average rating, the average wave height and the average
    # water temperature
    avg_per_day_spot = d_one_swell_per_time %>%
      mutate(date = substr(time, 1, 10),
             date = as.Date(date, "%Y_%m_%d")) %>%
      group_by(date) %>%
      summarise(
        lat = first(lat),
        lon = first(lon),
        name = as.character(first(name)),
        daily_mean_swell_rating = mean(rating__value, na.rm=T),
        daily_mean_wave_height_min = mean(surf__min, na.rm=T),
        daily_mean_wave_height_max = mean(surf__max, na.rm=T),
        daily_mean_water_temperature_max = mean(waterTemp__max, na.rm=T),
        daily_mean_water_temperature_min = mean(waterTemp__min, na.rm=T),
        daily_mean_water_temperature_max = mean(waterTemp__max, na.rm=T),
        weather_per_timestamp = paste0(weather__condition, collapse = ","),
        wind_per_timestamp = paste0(wind__directionType, collapse = ","),
        n_samples_per_day = n()
      )

    data.table::fwrite(avg_per_day_spot, op)

  })





}
