# R/download_forecasts.R
# This script contains the functions to download and process surf forecasts.

library(jsonlite)
library(glue)
library(dplyr)
library(purrr)
library(future)
library(furrr)

# --- Configuration ---
SPOTS_FILE <- "output/all_spots.json"
OUTPUT_DIR <- "output/forecasts_by_spot"
# Set a limit for testing. Set to NA to run for all spots.
SPOT_LIMIT <- NA

# --- Functions ---

# A safe version of fromJSON that will return NULL if there's an error
safe_fromJSON <- safely(fromJSON, otherwise = NULL)

# Function to get and save the forecast for a single spot
get_and_save_spot_forecast <- function(spot_id, spot_name) {
    print(glue("Fetching forecast for: {spot_name} ({spot_id})"))
    output_path <- file.path(OUTPUT_DIR, paste0(spot_id, ".json"))

    # Construct URLs
    rating_url <- glue(
        "https://services.surfline.com/kbyg/spots/forecasts/rating?spotId={spot_id}&days=5&intervalHours=3"
    )
    surf_url <- glue(
        "https://services.surfline.com/kbyg/spots/forecasts/surf?spotId={spot_id}&days=5&intervalHours=3"
    )

    # Fetch data safely
    rating_data <- safe_fromJSON(rating_url)$result
    surf_data <- safe_fromJSON(surf_url)$result

    if (is.null(rating_data) || is.null(surf_data)) {
        warning(glue("Failed to fetch data for spotId: {spot_id}"))
        return(NULL)
    }

    # Extract and combine the relevant forecast data
    combined_df <- tryCatch(
        {
            tibble(
                timestamp = rating_data$data$rating$timestamp,
                rating_key = rating_data$data$rating$rating$key,
                rating_value = rating_data$data$rating$rating$value,
                min_surf = surf_data$data$surf$surf$min,
                max_surf = surf_data$data$surf$surf$max
            ) %>%
                mutate(
                    spotId = spot_id,
                    spotName = spot_name,
                    download_timestamp = Sys.time(), # Add the time of the request
                    .before = 1
                )
        },
        error = function(e) {
            warning(glue(
                "Error processing data for spotId: {spot_id}. Details: {e$message}"
            ))
            return(NULL)
        }
    )

    if (!is.null(combined_df)) {
        write_json(combined_df, output_path)
    }

    return(spot_id) # Return the spot_id on success for tracking
}

# --- Main function to run one full download cycle ---
run_forecast_download_cycle <- function() {
    # Set up parallel processing
    plan(multisession)

    # Create the output directory if it doesn't exist
    if (!dir.exists(OUTPUT_DIR)) {
        dir.create(OUTPUT_DIR, recursive = TRUE)
    }

    all_spots <- fromJSON(SPOTS_FILE)

    if (!is.na(SPOT_LIMIT)) {
        print(glue(
            "Applying test limit: fetching data for {SPOT_LIMIT} spots only."
        ))
        all_spots <- head(all_spots, SPOT_LIMIT)
    }

    processed_spots <- future_map2(
        all_spots$spotId,
        all_spots$name,
        get_and_save_spot_forecast,
        .options = furrr_options(
            packages = c("jsonlite", "glue", "dplyr", "tibble")
        )
    )

    successful_downloads <- length(purrr::compact(processed_spots))

    print(glue(
        "Successfully downloaded forecasts for {successful_downloads} spots."
    ))
    print(glue("Individual forecast files saved to: {OUTPUT_DIR}"))

    # Return the number of successful downloads
    return(successful_downloads)
}
