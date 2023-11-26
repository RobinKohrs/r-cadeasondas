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
format_data_per_spot = function(dir_raw_data, dir_spots_raw=NULL, last_file=NULL){

  # files
  if(!is.null(last_file)){
    files = list(last_file)
  }else{
    files = dir(dir_raw_data, ".*\\.Rds", full.names = T)
    output_files = dir(dir_spots_raw, "*", full.names = T)
    unlink
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

      # path_spot = glue("~/data/surfdata/per_spot/{name}.csv")
      path_spot = glue("{dir_spots_raw}/{name}.csv")

      spot[["time"]] = date_str

      d_spot = spot %>%
        select(time, lat, lon, name, conditions__value, rating__key, rating__value, matches("^surf|waveHeight|wind__|waterTemp|swells__|weather__"))

      data.table::fwrite(d_spot, path_spot, append = T)
    })
  })
}
