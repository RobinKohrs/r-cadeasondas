# R/proxy_api.R
library(plumber)
library(jsonlite)

#* @apiTitle Surfline Forecast API Proxy
#* @apiDescription An API to proxy requests to the Surfline API and bypass CORS issues.

#* Get surf rating for a specific spot
#* @param spotId The ID of the surf spot (e.g., 584204214e65fad6a7709c58)
#* @get /rating
function(spotId) {
    # Construct the Surfline API URL from the parameter
    url <- paste0(
        "https://services.surfline.com/kbyg/spots/forecasts/rating?spotId=",
        spotId,
        "&days=5&intervalHours=1"
    )

    # Fetch data from the Surfline API
    # jsonlite::fromJSON can directly read from a URL
    data <- jsonlite::fromJSON(url)

    # Return the data, which plumber will automatically convert to a JSON response
    return(data)
}
