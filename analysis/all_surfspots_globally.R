library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)


# paths -------------------------------------------------------------------
paths = dir(here("output/spots_per_quadrant/"), ".*\\.json$", full.names = T)

spots = map(paths, function(p){
    d =fromJSON(p)
    d_geo = st_as_sf(d, coords=c("lon", "lat"), crs=4326)
    return(d_geo)
}) %>% bind_rows()

spots_final = spots %>%
  select(name)


spots_final %>%
  mutate(
    x = st_coordinates(.)[,1],
    y = st_coordinates(.)[,2]
  ) %>%
  st_drop_geometry() -> spots_final_csv



op = "~/projects/personal/js/rkWeb/static/data/surf_spots.geojson"
unlink(op)
write_sf(spots_final, op)

op_csv = "~/projects/personal/js/rkWeb/static/data/surf_spots.csv"
write_csv(spots_final_csv, op_csv)
