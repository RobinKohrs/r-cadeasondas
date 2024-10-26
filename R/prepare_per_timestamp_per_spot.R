#' Format all the data
#'
#' @param dir_name
#' @import tidyverse
#' @import stringr
#' @import glue
#' @import data.table
#' @import janitor
#'
#' @return
#' @export
#'
#' @examples
prepare_per_timestamp_per_spot = function(dir_data_raw, dir_data_timestamp){

  # files that are there already
  per_spot_timestamp_files = dir(dir_data_timestamp, ".*\\.csv")

  # per timestamp file
  per_timestamp_files = dir(dir_data_raw, ".*\\.Rds", full.names=T)

  # if summarise each timestamp for each spot for the first time
  if(length(per_spot_timestamp_files) == 0){
    files = per_timestamp_files
  }else{
     # find the last raw data file
    files = per_timestamp_files[length(per_timestamp_files)]
  }



  # for each day
  walk(seq_along(files), function(j){

    f = files[[j]]

    # date
    bn = basename(f)
    date_str = str_extract(bn, "\\d+_\\d+_\\d+_\\d+")

    # data
    d = readRDS(f)

    per_id = d %>%
      split(.$`_id`)

    walk(seq_along(per_id), function(i){
      # cat(glue("{j}: {i}\r"))

      spot = per_id[[i]]
      id = spot$`_id`[[1]]
      name = spot$name[[1]] %>% janitor::make_clean_names()
      name = glue("{name}_{id}")

      path_spot = glue("{dir_data_timestamp}/{name}.csv")

      spot[["time"]] = date_str

      d_spot = spot %>%
        select(time, lat, lon, name, conditions__value, rating__key, rating__value, matches("^surf|waveHeight|wind__|waterTemp|swells__|weather__"))

      d_spot_one_swell = d_spot %>%
        filter(case_when(
          all(is.na(swells__event)) ~ swells__swell_nr == 1,
          .default = swells__event == min(swells__event, na.rm = T)
        ))


      data.table::fwrite(d_spot_one_swell, path_spot, append = T)
    })
  })
}
