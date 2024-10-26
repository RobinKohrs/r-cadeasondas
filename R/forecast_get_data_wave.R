#' Format the wave forecast data
#'
#' @param d
#'
#' @return
#' @export
#'
#' @examples
forecast_get_data_wave = function(d){

  utc_offset = d$associated$utcOffset

  # wave dataframe
  data_wave = d$data$wave

  data_wave_unnest = data_wave %>%
    unnest(surf, names_sep = "__") %>%
    unnest(swells, names_sep = "__") %>%
    mutate(timestamp_local = timestamp + (utc_offset * 60 * 60)) %>%
    nest(data = -timestamp) %>%
    mutate(variable="wave")

  return(data_wave_unnest)

}
