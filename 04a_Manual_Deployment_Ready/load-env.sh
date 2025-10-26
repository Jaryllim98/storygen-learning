#!/bin/bash
#
# Description:
#   This script loads environment variables from a .env file into the current shell session.
#
# Usage:
#   source load-env.sh

# --- Exit on error ---
set -e

# --- Check if .env file exists ---
if [ ! -f ".env" ]; then
  echo "Error: .env file not found."
  exit 1
fi

# --- Load environment variables ---
echo "Loading environment variables from .env..."
export $(grep -v '^#' .env | xargs)

echo "Environment variables loaded successfully."
