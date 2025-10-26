#!/usr/bin/env bash

# Usage: ./clone-subdir.sh <github-subdir-url>
# Example: ./clone-subdir.sh https://github.com/tonybaloney/vscode-pets/tree/main/media

set -e

if [ -z "$1" ]; then
	echo "Usage: $0 <github-subdir-url>"
	exit 1
fi

URL="$1"

# Extract parts using parameter expansion and regex
REPO_URL=$(echo "$URL" | sed -E 's|(https://github.com/[^/]+/[^/]+)/tree/[^/]+/.*|\1.git|')
BRANCH=$(echo "$URL" | sed -E 's|.*/tree/([^/]+)/.*|\1|')
SUBDIR=$(echo "$URL" | sed -E 's|.*/tree/[^/]+/(.*)|\1|')
REPO_NAME=$(basename "$REPO_URL" .git)
TARGET_DIR="${REPO_NAME}-${SUBDIR//\//-}"

echo "📦 Repo:    $REPO_URL"
echo "🌿 Branch:  $BRANCH"
echo "📁 Subdir:  $SUBDIR"
echo "📂 Target:  $TARGET_DIR"

# Clone repo shallowly with sparse-checkout
git clone --depth 1 --filter=blob:none --sparse --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
cd "$TARGET_DIR"

git sparse-checkout init --cone
git sparse-checkout set "$SUBDIR"

echo "✅ Done! '$SUBDIR' is available in '$TARGET_DIR/$SUBDIR'"
