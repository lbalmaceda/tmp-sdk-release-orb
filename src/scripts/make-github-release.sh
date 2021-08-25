GH_TOKEN="${!GH_TOKEN_KEY}"
# Check if $GH_TOKEN is defined
if [[ -z "$GH_TOKEN" ]]; then
    echo "ERROR: The '$GH_TOKEN_KEY' variable must be set to a Github Access Token."
    exit 1
fi

LOCAL_VERSION=$(node -p "require('./package.json').version")
PREFIXED_VERSION="$TAG_PREFIX$LOCAL_VERSION"

if ! git show-ref --tags "$PREFIXED_VERSION"; then
    echo "Tag with name '$PREFIXED_VERSION' found unpublished."
    REPOSITORY_URL=${CIRCLE_REPOSITORY_URL%".git"}

    curl -v \
    -H "Accept: application/json" \
    -H "Authorization: token $GH_TOKEN" \
    -d "tag_name=$PREFIXED_VERSION" \
    "$REPOSITORY_URL/releases"
else
    echo "Tag with name '$PREFIXED_VERSION' is already published."
fi