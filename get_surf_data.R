library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(lubridate)


# get the cells -----------------------------------------------------------
cells = rondas::get_cells(4*4*4)

# safe version of queriying data ------------------------------------------
safe_fromJSON = purrr::safely(fromJSON)

# get data ----------------------------------------------------------------
regions_data = vector("list", length(length(cells)))

for(i in seq_along(cells)){
  print(i)

  # cell
  cell = cells[[i]]

  #url
  url = glue("https://services.surfline.com/kbyg/mapview?south={cell$south}&west={cell$west}&north={cell$north}&east={cell$east}")

  # raw data
  raw_data = safe_fromJSON(url)

  if(!is.null(raw_data$error)){
    next
  }

  raw_data = raw_data$result



  # formt raw mapview data
  formatted_data = rondas::format_raw_mapview_data(raw_data)

  # regions data
  regions_data[[i]] = formatted_data


}


# filter out nas ----------------------------------------------------------
regions_data = regions_data[!is.na(regions_data)]


# bind --------------------------------------------------------------------
all = bind_rows(regions_data) %>%
  select(-where(is.list))

# create path -------------------------------------------------------------
time_id = format(Sys.time(), "%Y_%m_%d_%H")
# h = Sys.time() %>% lubridate::hour()
# if(h > 13){
#   time_id = glue("{time_id}_a")
# }else{
#   time_id = glue("{time_id}_m")
# }

op = glue("~/data/surfdata/per_day/{time_id}.Rds")
if(file.exists(op)){
  unlink(op)
}

if(!dir.exists(dirname(op))){
  dir.create(dirname(op), recursive = T)
}

saveRDS(all, op)

# format data per spot ----------------------------------------------------
per_spot_files = dir("~/data/surfdata/per_spot/", "*")
if (length(per_spot_files) > 0) {
  rondas::format_data_per_spot("~/data/surfdata/per_day/", last_file = op)
} else{
  rondas::format_data_per_spot("~/data/surfdata/per_day/")
}













