#!/bin/sh

set -euo pipefail

# Path to your Ibis ebook - prioritize env vars over inputs for backward compatibility
ibis_path=${IBIS_PATH:-${INPUT_IBIS_PATH:-./}}
# Branch to push the changes to
branch=${IBIS_BRANCH:-${INPUT_IBIS_BRANCH:-main}}
# Email id used while committing to the repo  
email=${EMAIL:-${INPUT_EMAIL:-bobby@bobbyiliev.com}}
# The commit message
commit_message=${COMMIT_MESSAGE:-${INPUT_COMMIT_MESSAGE:-Updated Ibis Next Exported Files}}
# Set safe directory (defaults to true)
set_safe_directory=${INPUT_SET_SAFE_DIRECTORY:-${SET_SAFE_DIRECTORY:-true}}

# Validate required environment variables
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "Error: GITHUB_TOKEN is required but not set"
    exit 1
fi

echo "Building PDFs with Ibis Next..."
echo "📁 Working directory: $(pwd)"
echo "📁 Target ibis path: ${ibis_path}"
echo "📁 GITHUB_WORKSPACE: ${GITHUB_WORKSPACE:-'not set'}"

# Configure Git safe directory (following actions/checkout pattern)
if [ "${set_safe_directory}" = "true" ]; then
    echo "Adding repository directory to git global config as safe directory"
    git config --global --add safe.directory "${GITHUB_WORKSPACE}"
    # Also add current directory as fallback
    git config --global --add safe.directory "$(pwd)"
fi

# Validate ibis.php exists before proceeding
if [ ! -f "${ibis_path}/ibis.php" ]; then
    echo "❌ Error: ibis.php not found at '${ibis_path}/ibis.php'"
    echo "📂 Contents of ${ibis_path}:"
    ls -la "${ibis_path}" || echo "Directory does not exist or is not accessible"
    echo "📂 Contents of current directory:"
    ls -la .
    echo ""
    echo "💡 Make sure:"
    echo "   1. You have run 'ibis-next init' in your ebook directory"
    echo "   2. The ibis_path input points to the correct directory"
    echo "   3. The ibis.php file exists in the specified path"
    exit 1
fi

# build the PDF  
echo "📖 Building PDFs in directory: ${ibis_path}"
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
