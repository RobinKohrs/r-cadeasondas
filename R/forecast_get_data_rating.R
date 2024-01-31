forecast_get_data_rating = function(d){

  # tides dataframe
  data_rating = d$data$rating %>%
    unnest(rating, names_sep = "__") %>%
    nest(data = -timestamp) %>%
    mutate(variable = "rating")

  return(data_rating)

}
