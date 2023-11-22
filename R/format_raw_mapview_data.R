#' Unnest data
#'
#' @param raw_data
#' @importFrom purrr map
#' @importFrom dplyr mutate
#' @importFrom tidyr unnest
#'
#' @return
#' @export
#'
#' @examples
format_raw_mapview_data = function(raw_data){

  data = raw_data$data
  spots = data$spots

  if(length(spots) == 0){
    return(NA)
  }

  all = spots %>%
    mutate(
      swells = map(swells, function(x){
        x[["swell_nr"]]  = 1:nrow(x)
        return(x)
      })
    ) %>%
    unnest(swells, names_sep = "__") %>%
    unnest(where(is.data.frame), names_sep = "__")

  return(all)



}
