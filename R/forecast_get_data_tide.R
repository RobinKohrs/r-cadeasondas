forecast_get_data_tide = function(d){

  # tides dataframe
  data_tides = d$data$tides %>%
    mutate(timestamp_local = timestamp + (utc_offset * 60 * 60)) %>%
    nest(data = -timestamp) %>%
    mutate(variable = "tide")


  return(data_tides)

}
