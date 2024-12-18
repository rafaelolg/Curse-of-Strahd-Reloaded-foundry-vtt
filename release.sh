#!/usr/bin/env bash

# Extract the current tag name if available, otherwise use the current branch name.
# First, try to get the latest tag name; if none is found, fallback to the current branch.
TAG_NAME=$(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD)

# Set a default release title if none is provided.
RELEASE_TITLE="${1:-Release $TAG_NAME}"

# Check if module.json exists.
if [ ! -f module.json ]; then
    echo "Error: module.json file not found in the current directory."
    exit 1
fi

# Create a zip of all files in the repository excluding the .git folder and the release zip itself.
ZIP_NAME="release-$TAG_NAME.zip"
rm -f "$ZIP_NAME"
zip -r "$ZIP_NAME" . -x "*.git*" "$ZIP_NAME"

# Create a GitHub release using the GitHub CLI.
# Make sure you are authenticated with 'gh auth login' and have the required permissions.
gh release create "$TAG_NAME" \
    "$ZIP_NAME" \
    "module.json" \
    --title "$RELEASE_TITLE" \
    --notes "Release created automatically by the script."

echo "Release $TAG_NAME created successfully!"
