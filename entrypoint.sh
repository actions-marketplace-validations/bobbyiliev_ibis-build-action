#!/bin/sh

set -euo pipefail

# Path to your Ibis ebook
ibis_path=${INPUT_IBIS_PATH:-${IBIS_PATH:-./}}
# Branch to push the changes to
branch=${INPUT_IBIS_BRANCH:-${IBIS_BRANCH:-main}}
# Email id used while committing to the repo
email=${INPUT_EMAIL:-${EMAIL:-bobby@bobbyiliev.com}}
# The commit message
commit_message=${INPUT_COMMIT_MESSAGE:-${COMMIT_MESSAGE:-Updated Ibis Next Exported Files}}
# Set safe directory (defaults to true)
set_safe_directory=${INPUT_SET_SAFE_DIRECTORY:-${SET_SAFE_DIRECTORY:-true}}

# Validate required environment variables
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "Error: GITHUB_TOKEN is required but not set"
    exit 1
fi

echo "Building PDFs with Ibis Next..."

# Configure Git safe directory (following actions/checkout pattern)
if [ "${set_safe_directory}" = "true" ]; then
    echo "Adding repository directory to git global config as safe directory"
    git config --global --add safe.directory "${GITHUB_WORKSPACE}"
    # Also add current directory as fallback
    git config --global --add safe.directory "$(pwd)"
fi

# build the PDF
cd ${ibis_path}
php /tmp/vendor/bin/ibis-next pdf
php /tmp/vendor/bin/ibis-next pdf dark
php /tmp/vendor/bin/ibis-next sample
php /tmp/vendor/bin/ibis-next sample dark

# commit the new files
echo "Configuring Git and pushing changes..."
git config --global user.email "${email}"
git config --global user.name "Ibis Build Action"

echo "Fetching latest changes..."
git fetch origin "${branch}"

echo "Checking out branch: ${branch}"
git checkout "${branch}"

# Check if there are any changes to commit
if [ -n "$(git status --porcelain export/)" ]; then
    echo "Adding export files to Git..."
    git add export/
    
    echo "Committing changes..."
    git commit -m "${commit_message}"
    
    echo "Pushing to ${branch}..."
    git push origin "${branch}"
    
    echo "✅ Successfully pushed updated PDFs to ${branch}"
else
    echo "ℹ️  No changes detected in export/ directory, skipping commit"
fi
