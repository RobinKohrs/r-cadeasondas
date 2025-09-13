#!/bin/bash
# start_downloader.sh

# This script runs before the main R script to set up the SSH environment.

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the secret is set
if [ -z "$GIT_SSH_KEY" ]; then
  echo "Error: GIT_SSH_KEY secret not found. Cannot proceed."
  exit 1
fi

# Set up the SSH directory
echo "Configuring SSH..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Decode the private key from base64 and save it to the correct file
echo "$GIT_SSH_KEY" | base64 --decode > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# Add github.com to the list of known hosts to avoid interactive prompts
ssh-keyscan github.com >> ~/.ssh/known_hosts

echo "SSH configured successfully."

# Now, execute the main R script that was passed as an argument
exec "$@"
