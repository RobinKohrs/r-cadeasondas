library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(stars)
library(exactextractr)


# data_spots --------------------------------------------------------------
path_spots = here("output/all_spots/all_spots.csv")
data_spots = read_csv(path_spots)
geo_spots = data_spots %>% st_as_sf(coords=c("lon", "lat"), crs=4326)


# data bathy --------------------------------------------------------------
path_bathy = here("data_raw/GEBCO_2023_sub_ice_topo.nc")
stars_bathy = stars::read_ncdf(path_bathy, proxy = T)


# for each point extract 1 degree -----------------------------------------
buffer_meter = 200000
for(i in seq_along(1:nrow(geo_spots))){
  row = geo_spots[i, ]
  id = row$id
  buffer = st_buffer(row, dist=buffer_meter)

  # write to tempfile
  tf = glue("{tempfile()}.geojson")
  write_sf(buffer, tf)

  # cropped raster path
  op_cropped_bathy_spot = makePath(here(glue("data_raw/cropped_bathy_spot/bathy_{id}.tif")))
  if(file.exists(op_cropped_bathy_spot)){
    next
  }

  # extract raster
  cmd = glue("gdalwarp -s_srs 'EPSG:4326' -of GTiff -cutline {tf} -crop_to_cutline {path_bathy} {op_cropped_bathy_spot}")
  system(cmd)

}

