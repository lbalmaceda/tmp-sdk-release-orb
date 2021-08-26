echo "Looking for the package version, assuming the platform is '$LANGUAGE'."

if [[ "$LANGUAGE" = "node" ]]; then
    PACKAGE_VERSION=$(node -p "require('./package.json').version")
fi
## TODO: Add future platforms here

# Check if something was found
if [[ -z "$PACKAGE_VERSION" ]]; then
    echo "ERROR: Could not obtain the package version."
    exit 1
fi

echo "Version found: '$PACKAGE_VERSION'. Exporting to $PACKAGE_VERSION_KEY.".
echo "export $PACKAGE_VERSION_KEY=$PACKAGE_VERSION" >> "$BASH_ENV"
