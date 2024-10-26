#' Title
#'
#' @param d
#'
#' @return
#' @export
#'
#' @examples
forecast_get_data_rating = function(d){
  utc_offset = d$data$rating$utcOffset[[1]]

  # tides dataframe
  data_rating = d$data$rating %>%
    unnest(rating, names_sep = "__") %>%
    mutate(timestamp_local = timestamp + (utc_offset * 60 * 60)) %>%
    nest(data = -timestamp) %>%
    mutate(variable = "rating")

  return(data_rating)

}
