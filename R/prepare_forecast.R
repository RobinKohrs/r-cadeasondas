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

   # tide_url = glue("https://services.surfline.com/kbyg/spots/forecasts/tides?spotId={spot_id}&days=6&cacheEnabled=true&units%5BtideHeight%5D=M")

   # weather_url = glue("https://services.surfline.com/kbyg/spots/forecasts/weather?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true&units%5Btemperature%5D=C")

   # wind_url = glue("https://services.surfline.com/kbyg/spots/forecasts/wind?spotId={spot_id}&days=5&intervalHours={interval}&corrected=false&cacheEnabled=true&units%5BwindSpeed%5D=KTS")

   # sunlight_url = glue("https://services.surfline.com/kbyg/spots/forecasts/sunlight?spotId={spot_id}&days=5&intervalHours={interval}")

   # rating_url = glue("https://services.surfline.com/kbyg/spots/forecasts/rating?spotId={spot_id}&days=5&intervalHours={interval}&cacheEnabled=true")
   data_raw_wave  = fromJSON(wave_url)
   print(r)
  })



}
