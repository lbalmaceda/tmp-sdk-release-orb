Publish() {
    PACKAGE_NAME=$(node -p "require('./package.json').name")
    LOCAL_VERSION=$(node -p "require('./package.json').version")
    PUBLISHED_VERSION=$(npm view "$PACKAGE_NAME" versions --json | jq -r '.[-1]')
    
    if [[ $LOCAL_VERSION != "$PUBLISHED_VERSION" ]]; then
        echo "Version $LOCAL_VERSION found unpublished. Publishing it to NPM."
        npm config set //registry.npmjs.org/:_authToken "$NPM_TOKEN"
        npm "$PARAM_OVERRIDE_COMMAND"
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
