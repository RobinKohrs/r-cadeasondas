prepare_forecast = function(path_all_spots = "~/projects/personal/r/2023/rondas/output/all_spots/all_spots.csv",
                            interval=3) {


  # read all spots
  data_all_spots = read_csv(path_all_spots)

  # for each spot get all the forecasts
  walk(seq_along(1:nrow(data_all_spots)), function(r){

   # one spot
   row = data_all_spots[r,]

   # its id
   spot_id = row$id

   #urls
   wave_url = glue("https://services.surfline.com/kbyg/spots/forecasts/wave?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true&units%5BswellHeight%5D=M&units%5BwaveHeight%5D=M")
   tide_url = glue("https://services.surfline.com/kbyg/spots/forecasts/tides?spotId={spot_id}&days=5&cacheEnabled=true&units%5BtideHeight%5D=M")
   weather_url = glue("https://services.surfline.com/kbyg/spots/forecasts/weather?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true&units%5Btemperature%5D=C")
   wind_url = glue("https://services.surfline.com/kbyg/spots/forecasts/wind?spotId={spot_id}&days=5&intervalHours={interval}&corrected=false&cacheEnabled=true&units%5BwindSpeed%5D=KTS")
   sunlight_url = glue("https://services.surfline.com/kbyg/spots/forecasts/sunlight?spotId={spot_id}&days=5&intervalHours={interval}")
   rating_url = glue("https://services.surfline.com/kbyg/spots/forecasts/rating?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true")

   urls = list(
     wave = wave_url,
     rating = rating_url,
     tide = tide_url,
     # weather = weather_url,
     # wind = wind_url,
     # sunlight = sunlight_url
   )

   # get the actual data
   imap(urls, function(url, nm) {

     response = save_from_json(url)

     # if something goes wrong in fetching the json
     if (!is.null(response$error)) {
       return(NA)
     }

     # the data
     data = response$result

     data_formatted = switch(
       nm,
       "wave" = forecast_get_data_wave(data),
       "rating" = forecast_get_data_rating(data),
       "tide" = forecast_get_data_tide(data)
     )


   })
  })

}






