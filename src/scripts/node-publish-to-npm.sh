NPM_TOKEN="${!NPM_TOKEN_KEY}"
# Check if $NPM_TOKEN is defined
if [[ -z "$NPM_TOKEN" ]]; then
    echo "ERROR: The '$NPM_TOKEN_KEY' variable must be set to an Npm Automation Token."
    exit 1
fi

PACKAGE_NAME=$(node -p "require('./package.json').name")
LOCAL_VERSION=$(node -p "require('./package.json').version")
PUBLISHED_VERSION=$(npm view "$PACKAGE_NAME" versions --json | jq -r '.[-1]')

if [[ $LOCAL_VERSION != "$PUBLISHED_VERSION" ]]; then
    echo "Version with name '$LOCAL_VERSION' found unpublished."
    # Configuration from command below will be picked up by yarn as well
    npm config set //registry.npmjs.org/:_authToken "$NPM_TOKEN"
    
    if [[ -n "$PUBLISH_COMMAND" ]]; then
        echo "Running override publish command:"
        $($PUBLISH_COMMAND)
    elif [[ $PKG_MANAGER == 'npm' ]]; then
        echo "Publishing using Npm:"
        npm publish
    else
        echo "Publishing using Yarn:"
        yarn publish
    fi
else
    echo "Version with name '$LOCAL_VERSION' is already published."
fi