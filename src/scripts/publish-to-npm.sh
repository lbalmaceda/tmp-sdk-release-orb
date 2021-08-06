Publish() {
    PACKAGE_NAME=$(node -p "require('./package.json').name")
    LOCAL_VERSION=$(node -p "require('./package.json').version")
    PUBLISHED_VERSION=$(npm view "$PACKAGE_NAME" versions --json | jq -r '.[-1]')

    if [[ $LOCAL_VERSION != "$PUBLISHED_VERSION" ]]; then
        echo "Version $LOCAL_VERSION found unpublished. Publishing it to npm."
        # Configuration from command below will be picked up by yarn as well
        npm config set //registry.npmjs.org/:_authToken "$NPM_TOKEN"

        if [[ -n "$PUBLISH_COMMAND" ]]; then
            echo "Running override publish command:"
            $($PUBLISH_COMMAND)
        elif [[ $PKG_MANAGER == 'npm' ]]; then
            echo "Publishing using npm:"
            npm publish
        else
            echo "Publishing using yarn:"
            yarn publish
        fi
    else
        echo "Version $LOCAL_VERSION is already published."
    fi
}

# Will not run if sourced for bats-core tests.
# View src/tests for more information.
ORB_TEST_ENV="bats-core"
if [ "${0#*$ORB_TEST_ENV}" == "$0" ]; then
    Publish
fi
