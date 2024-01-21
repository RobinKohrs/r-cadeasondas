library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)


# paths -------------------------------------------------------------------
paths = dir("~/geodata/naturalEarth/ne_10m_bathymetry_all/", ".*\\.shp$", full.names = T)


# read data ---------------------------------------------------------------
data = map(paths, function(p){
  d = read_sf(p)
  return(d)
})

depths = map(data, ~.x$depth[[1]]) %>% unlist
names(data) = depths

data_order = data[order(as.numeric(names(data)))]


imap(seq_along(data_order), function(i){

 shallow = data_order[[i]] %>% st_make_valid()
 deep = data_order[[i+1]] %>% st_make_valid()

 curr = st_difference(shallow, deep)


})
