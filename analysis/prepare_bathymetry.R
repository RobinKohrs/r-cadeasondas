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

  str_extract_all(basename(p), "[0-9]+")

})

