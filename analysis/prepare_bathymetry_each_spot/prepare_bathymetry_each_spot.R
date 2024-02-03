library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(stars)


# data_spots --------------------------------------------------------------
path_spots = here("output/all_spots/all_spots.csv")
data_spots = read_csv(path_spots)
geo_spots = data_spots %>% st_as_sf(coords=c("lat", "lon"), crs=4326)


# data bathy --------------------------------------------------------------
path_bathy = here("data_raw/GEBCO_2023_sub_ice_topo.nc")
stars_bathy = stars::read_ncdf(path_bathy, proxy = T)


# for each point extract 1 degree -----------------------------------------
buffer_degreees = 1

