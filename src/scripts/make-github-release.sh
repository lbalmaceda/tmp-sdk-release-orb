LOCAL_VERSION="${!PACKAGE_VERSION_KEY}"
# Check if $LOCAL_VERSION is defined
if [[ -z "$LOCAL_VERSION" ]]; then
    echo "ERROR: The '$PACKAGE_VERSION_KEY' variable must be set to the package version name."
    exit 1
fi

GH_TOKEN="${!GH_TOKEN_KEY}"
# Check if $GH_TOKEN is defined
if [[ -z "$GH_TOKEN" ]]; then
    echo "ERROR: The '$GH_TOKEN_KEY' variable must be set to a Github access token."
    exit 1
fi

# Check if the API URL can be constructed
if [[ -z "$CIRCLE_PROJECT_USERNAME" ]] || [[ -z "$CIRCLE_PROJECT_REPONAME" ]]; then
    echo "ERROR: The variables 'CIRCLE_PROJECT_USERNAME' and/or 'CIRCLE_PROJECT_REPONAME' are not defined. Running this locally requires those variables to be explicitly set via the CLI. See https://circleci.com/docs/2.0/local-cli/#limitations-of-running-jobs-locally."
    exit 1
fi

if [ "$PREFIX_TAG" = true ] || [ "$PREFIX_TAG" = 1 ]; then LOCAL_VERSION="v$LOCAL_VERSION"; fi

echo "Pulling remote tags..."
git fetch --tags

if ! git show-ref --tags "$LOCAL_VERSION"; then
    echo "Tag with name '$LOCAL_VERSION' found unpublished."
    
    # Try to get the Changelog entry from the release PR
    RELEASE_PR_BRANCH="release/$LOCAL_VERSION"
    API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls?state=all&head=$CIRCLE_PROJECT_USERNAME:$RELEASE_PR_BRANCH"
    echo "Making request to $API_URL"
    RELEASE_PR_BODY=$(curl -H "Accept: application/json" \
    -H "Authorization: token $GH" \
    "$API_URL" | jq -r ".[0].body"
    )
    if [ -z "$RELEASE_PR_BODY" ] || [[ "$RELEASE_PR_BODY" == "null" ]]; then RELEASE_PR_BODY=""; fi

    # POST the Release
    API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/releases"
    STATUS_CODE=$(curl \
    --output /dev/stderr \
    --write-out "%{http_code}" \
    -H "Accept: application/json" \
    -H "Authorization: token $GH_TOKEN" \
    -d '{"tag_name":'\""$LOCAL_VERSION"\"',"name":'\""$LOCAL_VERSION"\"',"body":'\""$RELEASE_PR_BODY"\"'}' \
    "$API_URL"
    )
    
    if [[ "$STATUS_CODE" -lt 200 ]] || [[ "$STATUS_CODE" -gt 299 ]]; then exit "$STATUS_CODE"; fi
    
else
    echo "Tag with name '$LOCAL_VERSION' is already published."
fi