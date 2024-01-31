forecast_get_data_tide = function(d){

  # tides dataframe
  data_tides = d$data$tides %>%
    nest(data = -timestamp) %>%
    mutate(variable = "tide")


  return(data_tides)

}
