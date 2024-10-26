library(here)
library(rajudas)
library(tidyverse)
library(jsonlite)
library(glue)
library(mapview)
library(sf)
library(rmapshaper)
library(geojsonio)



# paths -------------------------------------------------------------------
w = read_sf("../../../js/2023/cadeasondas/static/data/geo/topo_sections.json")  %>%
  mutate(
    id = case_when(
      region == "nw" ~ 1,
      region == "ne" ~ 2,
      region == "sw" ~ 3,
      .default=4
    )
  ) %>% arrange(id) %>% select(-fid)

regions = w %>% split(.$region)

walk(seq_along(regions), function(i){
  region_name = names(regions)[[i]]
  region =regions[[i]]
  op = glue("../../../js/2023/mySurf/static/data/geo/topo_{region_name}.json")
  geojsonio::topojson_write(region, file=op)
})





