library(here)
library(rajudas)
library(tidyverse)
library(jsonlite)
library(glue)
library(mapview)
library(sf)



# world coordinates -------------------------------------------------------
world_coords = list(
  nw = list(
    north = 90,
    east = 0,
    south = 0,
    west = -180
  ),
  sw = list(
    north = 0,
    east = 0,
    south = -90,
    west = -180
  ),
  ne = list(
    north = 90,
    east = 180,
    south = 0,
    west = 0
  ),
  se = list(
    north = 0,
    east = 180,
    south = -90,
    west = 0
  )
)



#####
## Raw data
#####

raw_data = map(seq_along(world_coords), function(i){

  coords = world_coords[[i]]
  url = glue("https://services.surfline.com/kbyg/mapview?south={coords$south}&west={coords$west}&north={coords$north}&east={coords$east}")
  raw_data = fromJSON(url)
  return(raw_data)

})

names(raw_data)=names(world_coords)


#####
## Clean Data
#####

info = map(seq_along(raw_data), function(i){

  d = raw_data[[i]]
  region = names(raw_data)[[i]]

  data = d$data
  spots = data$spots

  info_subset = spots %>%
    select(
    name,
     id = `_id`,
     subregionId,
     lon,
     lat
    ) %>%
    mutate(region=region)
  return(info_subset)
}) %>% bind_rows()




#####
## write out the data per quadrant
#####
per_region = info %>% split(.$region)
walk(seq_along(per_region), function(j){
  info_json = per_region[[j]] %>% toJSON(pretty = T)
  region = names(per_region)[[j]]
  op = makePath(here(glue(
    "output/spots_per_quadrant/region_{region}.json"
  )))
  write(info_json, op)
})

























