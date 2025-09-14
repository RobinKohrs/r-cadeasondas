# Use the official Rocker R image
FROM rocker/r-ver:4.4.2

# Install system dependencies: git, ssh client, and git-lfs
RUN apt-get update -qq && apt-get install -y git openssh-client git-lfs && git lfs install

# Install the R packages
RUN R -e "install.packages(c('plumber', 'jsonlite', 'glue', 'dplyr', 'purrr', 'furrr'))"

# --- Set up SSH and Clone Repo ---
# This section ensures that we clone the repository correctly with LFS support.

# This argument will be populated by the GIT_SSH_KEY secret during the build process.
ARG GIT_SSH_KEY

# Set up the SSH directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
# Decode the private key and set permissions
RUN echo "$GIT_SSH_KEY" | base64 --decode > /root/.ssh/id_ed25519 && chmod 600 /root/.ssh/id_ed25519
# Add github.com to known hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts


# --- Clone the repository into the container ---
# Replace 'YOUR_USERNAME/YOUR_REPO.git' with your actual repository URL
RUN git clone git@github.com:YOUR_USERNAME/YOUR_REPO.git /app

# Set the working directory
WORKDIR /app

# Run git lfs pull to download the large files
RUN git lfs pull

# Make the startup script executable
RUN chmod +x ./start_downloader.sh

# Expose port 8000 for the API
EXPOSE 8000

# The CMD is now much simpler as the repo is already in place.
# We just need to run the startup script.
CMD ["./start_downloader.sh", "Rscript", "run_downloader.R"]
