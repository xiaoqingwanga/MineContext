#!/bin/bash

# Ensure we are in the directory containing this script or adjust paths accordingly
# This script assumes .env is in the same directory

if [ ! -f .env ]; then
    echo "Error: .env file not found in current directory."
    echo "Please create one using the template."
    exit 1
fi

echo "Loading environment variables from .env..."
export $(grep -v '^#' .env | xargs)

echo "Starting OpenContext..."
# Change to the project root directory so that config/config.yaml is found
cd ../../
uv run opencontext start
