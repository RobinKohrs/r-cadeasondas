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
buffer_meter = 50000
library(furrr)
plan(multisession, workers=6)
walk(seq_along(1:nrow(geo_spots)), function(i){

  print(i)
  row = geo_spots[i, ]
  id = row$id
  op_cropped_bathy_spot = makePath(here(glue("data_preprocessed/bathys_per_spot/bathy_{id}.tif")))

  if(file.exists(op_cropped_bathy_spot)){
    return()
  }

  buffer = st_buffer(row, dist=buffer_meter)

  # write to tempfile
  tf = glue("{tempfile()}.geojson")
  write_sf(buffer, tf)

  # cropped raster path

  # extract raster
  cmd = glue("gdalwarp -s_srs 'EPSG:4326' -of GTiff -cutline {tf} -crop_to_cutline {path_bathy} {op_cropped_bathy_spot}")
  system(cmd)
})

# , .options = furrr_options(packages = c("rajudas", "here", "glue", "sf"), globals = c("path_bathy", "stars_bathy", "geo_spots", "buffer_meter")))


# create the contour polygons ---------------------------------------------






