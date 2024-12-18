#!/usr/bin/env bash


increment_version() {
    local old_version=$1
    # Strip the leading 'v' if present to parse numbers easily
    local version_number="${old_version#v}"
    
    # Split version into MAJOR, MINOR, PATCH
    IFS='.' read -r major minor patch <<< "$version_number"
    
    # If for some reason it doesn't split correctly, default to 0.1.0
    if [ -z "$major" ] || [ -z "$minor" ] || [ -z "$patch" ]; then
        major=0
        minor=1
        patch=0
    fi
    
    # Increment the patch version
    patch=$((patch + 1))

    # Return the new version with a leading 'v'
    echo "v${major}.${minor}.${patch}"
}



# Extract the current tag name if available, otherwise use the current branch name.
# First, try to get the latest tag name; if none is found, fallback to the current branch.
# Determine the last tag; if none, use 'v0.1.0'
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.1.0")

# Increment the version to create a new tag
NEW_TAG=$(increment_version "$LAST_TAG")


# Set a default release title if none is provided.
RELEASE_TITLE="${1:-Release $TAG_NAME}"

# Check if module.json exists.
if [ ! -f module.json ]; then
    echo "Error: module.json file not found in the current directory."
    exit 1
fi
sed -i "s/$LAST_TAG/$NEW_TAG/g" module.json
git add module.json
git commit -m 'Release $NEW_TAG'
git tag "$NEW_TAG"
git push origin "$NEW_TAG"


# Create a zip of all files in the repository excluding the .git folder and the release zip itself.
ZIP_NAME=build/curse-of-strahd-reloaded.zip
rm -f "$ZIP_NAME"
mkdir -p build
zip -r "$ZIP_NAME" . -x "*.git*" "$ZIP_NAME"





# Create a GitHub release using the GitHub CLI.
# Make sure you are authenticated with 'gh auth login' and have the required permissions.
gh release create "$TAG_NAME" \
    "$ZIP_NAME" \
    "module.json" \
    --title "$RELEASE_TITLE" \
    --notes "Release created automatically by the script."

echo "Release $TAG_NAME created successfully!"
