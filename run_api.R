# run_api.R

# Load the plumber library
library(plumber)

# "Plumb" the API definition file
# This loads the API endpoints from R/proxy_api.R
pr <- plumb("R/proxy_api.R")

# Run the API, listening on host 0.0.0.0 to be accessible inside the container
# You can access it at http://localhost:8000
pr$run(host = "0.0.0.0", port = 8000)
