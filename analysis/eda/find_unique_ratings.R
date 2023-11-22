library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)



# get spots overview ------------------------------------------------------

url = glue("https://services.surfline.com/kbyg/mapview?south=0&west=-90&north=90&east=0")
url2 = glue("https://services.surfline.com/kbyg/mapview?south=-90&west=-180&north=90&east=180")
data_raw = fromJSON(url)
spots = data_raw$data$spots

# unique ratings ----------------------------------------------------------

ratings = map(seq_along(400:500), function(r){
  row = spots[r, ]
  spotId = row[1,1]
  #get forecast rating
  url = glue("https://services.surfline.com/kbyg/spots/forecasts/rating?spotId={spotId}&days=5&intervalHours=3&cacheEnabled=true")
  rating_raw = fromJSON(url)
  d = rating_raw$data$rating$rating
  return(d)

})

# where are the biggest waves ---------------------------------------------
ten_highest = spots %>% unnest(surf) %>%
  arrange(desc(max)) %>%
  slice_head(n=10)

