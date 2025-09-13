# run_downloader.R
# This script runs the forecast downloader in a continuous loop.

# Source the main downloader functions
source("R/download_forecasts.R")

# --- Git Configuration ---
# This is now handled by the start_downloader.sh script and the git environment
# on the deployment machine, which should be configured with a deploy key.

# --- Infinite Loop ---
while (TRUE) {
    print(paste("--- Starting forecast download cycle at", Sys.time(), "---"))

    # Run one full download cycle
    # We wrap this in a tryCatch to ensure that even if the download fails,
    # the script will not crash and will try again on the next cycle.
    tryCatch(
        {
            run_forecast_download_cycle()

            print("Download cycle finished. Committing data to Git...")

            # Add all new/changed files in the output directory
            system("git add output/")

            # Commit the changes with a timestamp
            commit_message <- paste("Update forecast data for", Sys.time())
            system(paste0("git commit -m '", commit_message, "'"))

            # Push the changes to the refactor branch
            system("git push origin refactor")

            print("Data successfully committed and pushed.")
        },
        error = function(e) {
            print(paste(
                "An error occurred during the download cycle:",
                e$message
            ))
        }
    )

    print(paste("--- Cycle finished. Sleeping for 1 hour. ---"))
    Sys.sleep(3600) # Sleep for 1 hour (3600 seconds)
}
