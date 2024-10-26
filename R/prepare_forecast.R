#' Download Forecast data
#'
#' @param path_all_spots
#' @param interval
#' @param output_dir
#'
#' @return
#' @export
#'
#' @examples
prepare_forecast = function(path_all_spots = "~/projects/personal/r/2023/rondas/output/all_spots/all_spots.csv",
                            interval=3,
                            output_dir="~/projects/personal/r/2023/rondas/data_preprocessed/forecast") {


  # read all spots
  data_all_spots = read_csv(path_all_spots)

  # safe version of queriying data ------------------------------------------
  safe_from_json = purrr::safely(jsonlite::fromJSON)

  download_spot = function(r) {


    print(r)

    # one spot
    row = data_all_spots[r,]

    # its id
    spot_id = row$id

    #urls
    wave_url = glue(
      "https://services.surfline.com/kbyg/spots/forecasts/wave?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true&units%5BswellHeight%5D=M&units%5BwaveHeight%5D=M"
    )
    tide_url = glue(
      "https://services.surfline.com/kbyg/spots/forecasts/tides?spotId={spot_id}&days=5&cacheEnabled=true&units%5BtideHeight%5D=M"
    )
    weather_url = glue(
      "https://services.surfline.com/kbyg/spots/forecasts/weather?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true&units%5Btemperature%5D=C"
    )
    wind_url = glue(
      "https://services.surfline.com/kbyg/spots/forecasts/wind?spotId={spot_id}&days=5&intervalHours={interval}&corrected=false&cacheEnabled=true&units%5BwindSpeed%5D=KTS"
    )
    sunlight_url = glue(
      "https://services.surfline.com/kbyg/spots/forecasts/sunlight?spotId={spot_id}&days=5&intervalHours={interval}"
    )
    rating_url = glue(
      "https://services.surfline.com/kbyg/spots/forecasts/rating?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true"
    )

    urls = list(wave = wave_url, rating = rating_url)
    # tide = tide_url)
    # weather = weather_url,
    # wind = wind_url,
    # sunlight = sunlight_url)

    # get the actual data
    dd = imap(urls, function(url, nm) {
      response = safe_from_json(url)

      # if something goes wrong in fetching the json
      if (!is.null(response$error)) {
        return(NA)
      }

      # the data
      data = response$result
      if (is.null(data$data[[1]])) {
        return(NA)
      }


      data_formatted = switch(
        nm,
        "wave" = forecast_get_data_wave(data),
        "rating" = forecast_get_data_rating(data),
        "tide" = forecast_get_data_tide(data)
      )

      return(data_formatted)
    })
    dd = dd[!is.na(dd)]

    # utc offset spot
    utc_offset_spot = dd$wave$data[[1]]$utcOffset[[1]]


    # format data for each spot
    data_all_vars = list_rbind(dd)

    per_timestamp = data_all_vars %>%
      split(.$timestamp)

    timestamps_local = names(per_timestamp) %>% map_dbl(function(x)
      as.numeric(x) + (utc_offset_spot * 60 * 60))

    names(per_timestamp) = timestamps_local

    per_timestamp_variable = map(per_timestamp, function(x) {
      x %>% split(.$variable)
    }) %>% map(function(w) {
      ww = map(w, function(x)
        x %>% unnest(data))
    })

    # write out
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = T)
    }

    op = glue(here(output_dir, glue("{spot_id}.json")))
    jsonlite::write_json(per_timestamp_variable, op)

  }

  safe_download_spot = purrr::safely(download_spot)
  # for each spot get all the forecasts
  walk(seq_along(1:nrow(data_all_spots)), function(x){
    response = safe_download_spot(x)
  })
}
