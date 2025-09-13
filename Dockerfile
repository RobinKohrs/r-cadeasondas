# Use the official Rocker R image
FROM rocker/r-ver:4.4.2

# Install system dependencies: git and ssh client
RUN apt-get update -qq && apt-get install -y git openssh-client

# Install the R packages your API needs
RUN R -e "install.packages(c('plumber', 'jsonlite', 'glue', 'dplyr', 'purrr', 'furrr'))"

# Create a directory inside the container for our app
WORKDIR /app

# Copy the R source files and the runner scripts into the container
COPY R/ ./R/
COPY run_api.R .
COPY run_downloader.R .
COPY start_downloader.sh .

# Make the startup script executable
RUN chmod +x ./start_downloader.sh

# Expose port 8000 for the API
EXPOSE 8000

# This command will be run when the container starts
# We use the start script to set up SSH before running the main R script
CMD ["./start_downloader.sh", "Rscript", "run_downloader.R"]
