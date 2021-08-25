GH_TOKEN="${!GH_TOKEN_KEY}"
# Check if $GH_TOKEN is defined
if [[ -z "$GH_TOKEN" ]]; then
    echo "ERROR: The '$GH_TOKEN_KEY' variable must be set to a Github Access Token."
    exit 1
fi

if [[ -z "$CIRCLE_PROJECT_USERNAME" ]] || [[ -z "$CIRCLE_PROJECT_REPONAME" ]]; then
    echo "ERROR: The variables 'CIRCLE_PROJECT_USERNAME' and/or 'CIRCLE_PROJECT_REPONAME' are not defined. Running this locally requires those variables to be explicitly set via the CLI. See https://circleci.com/docs/2.0/local-cli/#limitations-of-running-jobs-locally."
    exit 1
fi

LOCAL_VERSION=$(node -p "require('./package.json').version")
PREFIXED_VERSION=$TAG_PREFIX$LOCAL_VERSION

if ! git show-ref --tags "$PREFIXED_VERSION"; then
    echo "Tag with name '$PREFIXED_VERSION' found unpublished."
    
    API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/releases"
    STATUS_CODE=$(curl \
    --output /dev/stderr \
    --write-out "%{http_code}" \
    -H "Accept: application/json" \
    -H "Authorization: token $GH_TOKEN" \
    -d '{"tag_name":'\""$PREFIXED_VERSION"\"'}' \
    "$API_URL"
    )
    
    if [ "$STATUS_CODE" -ne 200 ]; then exit "$STATUS_CODE"; fi
    
else
    echo "Tag with name '$PREFIXED_VERSION' is already published."
fi