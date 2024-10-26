#' Title
#'
#' @param d
#'
#' @return
#' @export
#'
#' @examples
forecast_get_data_tide = function(d){

  utc_offset = d$associated$utcOffset

  # tides dataframe
  data_tides = d$data$tides %>%
    mutate(timestamp_local = timestamp + (utc_offset * 60 * 60)) %>%
    nest(data = -timestamp) %>%
    mutate(variable = "tide")


  return(data_tides)

}
