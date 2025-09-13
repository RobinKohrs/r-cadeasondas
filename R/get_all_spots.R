# R/get_all_spots.R
# This script fetches a list of all surf spots from the mapview endpoint
# and saves them to a file. This only needs to be run periodically to
# update the master list of spots.

library(jsonlite)
library(glue)
library(dplyr)
library(purrr)

# --- Functions to create geographic cells ---

# Function to check if a number is a power of 4 (required for grid)
is_power_of_4 <- function(n) {
    if (n == 0) {
        return(FALSE)
    }
    while (n != 1) {
        if (n %% 4 != 0) {
            return(FALSE)
        }
        n <- n / 4
    }
    return(TRUE)
}

# Function to build a grid of cells covering the globe
build_cells <- function(n_quadrants = 16) {
    if (!is_power_of_4(n_quadrants)) {
        stop("n_quadrants must be a power of 4.")
    }

    side_length <- sqrt(n_quadrants)
    x_spacing <- 360 / side_length
    y_spacing <- 180 / side_length

    cells <- vector("list", n_quadrants)

    for (x in 1:side_length) {
        for (y in 1:side_length) {
            north <- 90 - (y - 1) * y_spacing
            south <- 90 - y * y_spacing
            west <- -180 + (x - 1) * x_spacing
            east <- -180 + x * x_spacing

            cell <- list(north = north, south = south, east = east, west = west)
            index <- ((x - 1) * side_length) + y
            cells[[index]] <- cell
        }
    }
    return(cells)
}


# --- Main Script ---

# Create a grid of 16 cells to query
grid_cells <- build_cells(16)
safe_fromJSON <- safely(fromJSON, otherwise = NULL)

# Loop through each cell, fetch spots, and combine them
all_spots_list <- map(grid_cells, function(cell) {
    url <- glue(
        "https://services.surfline.com/kbyg/mapview?south={cell$south}&west={cell$west}&north={cell$north}&east={cell$east}"
    )
    print(glue(
        "Fetching spots for cell: S={cell$south}, W={cell$west}, N={cell$north}, E={cell$east}"
    ))

    # Fetch data safely
    data <- safe_fromJSON(url)$result

    # Return just the 'spots' dataframe, which is nested under the 'data' object
    if (!is.null(data) && !is.null(data$data) && !is.null(data$data$spots)) {
        return(data$data$spots)
    } else {
        return(NULL)
    }
})

# Combine the list of dataframes into one, removing any NULLs
combined_spots_df <- bind_rows(all_spots_list)

# The API sometimes returns '_id' and sometimes 'spotId'. We need to standardize this.
# Also, ensure we only try to remove duplicates if we have data.
if (nrow(combined_spots_df) > 0) {
    if ("_id" %in% names(combined_spots_df)) {
        combined_spots_df <- rename(combined_spots_df, spotId = `_id`)
    }

    # Remove duplicate spots that may appear at cell borders, using the standardized 'spotId'
    combined_spots_df <- combined_spots_df %>%
        distinct(spotId, .keep_all = TRUE)
}

# Final check: only proceed if we have a spotId column and some data
if ("spotId" %in% names(combined_spots_df) && nrow(combined_spots_df) > 0) {
    # Select and rename the final columns
    spots_df <- combined_spots_df %>%
        as_tibble() %>%
        select(spotId, name, lon, lat)

    # Create output directory if it doesn't exist
    if (!dir.exists("output")) {
        dir.create("output")
    }

    # Save the list as a JSON file
    write_json(spots_df, "output/all_spots.json")

    print(glue(
        "Successfully saved {nrow(spots_df)} unique spots to output/all_spots.json"
    ))
} else {
    stop(
        "Could not retrieve any valid spot data from the API after checking all cells."
    )
}
