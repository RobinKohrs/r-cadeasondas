#' Format the wave forecast data
#'
#' @param d
#'
#' @return
#' @export
#'
#' @examples
forecast_get_data_wave = function(d){

  # wave dataframe
  data_wave = d$data$wave

  data_wave_unnest = data_wave %>%
    unnest(surf, names_sep = "__") %>%
    unnest(swells, names_sep = "__") %>%
    nest(data = -timestamp) %>%
    mutate(variable="wave")

  return(data_wave_unnest)

}
