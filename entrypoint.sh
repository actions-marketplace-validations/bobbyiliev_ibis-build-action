#!/bin/bash

set -euo pipefail

# Get input values
ibis_path=${IBIS_PATH:-./}
branch=${IBIS_BRANCH:-main}
email=${EMAIL:-bobby@bobbyiliev.com}
commit_message=${COMMIT_MESSAGE:-"Updated Ibis Next Exported Files"}

echo "🚀 Building eBooks with Ibis Next..."
echo "📁 Working directory: $(pwd)"
echo "📁 Target ibis path: ${ibis_path}"

# Validate ibis.php exists before proceeding
if [ ! -f "${ibis_path}/ibis.php" ]; then
    echo "❌ Error: ibis.php not found at '${ibis_path}/ibis.php'"
    echo "📂 Contents of ${ibis_path}:"
    ls -la "${ibis_path}" 2>/dev/null || echo "Directory does not exist"
    echo ""
    echo "💡 Make sure:"
    echo "   1. You have run 'ibis-next init' in your ebook directory"
    echo "   2. The ibis_path input points to the correct directory"
    echo "   3. The ibis.php file exists in the specified path"
    exit 1
fi

# Add Composer global bin to PATH
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Verify ibis-next is available
if ! command -v ibis-next &> /dev/null; then
    echo "❌ Error: ibis-next command not found in PATH"
    echo "🔍 Checking Composer global install..."
    composer global show hi-folks/ibis-next || echo "Package not installed"
    exit 1
fi

echo "✅ ibis-next version: $(ibis-next --version)"

# Build all formats
echo "📖 Building eBooks in directory: ${ibis_path}"
cd "${ibis_path}"

# Ensure export directory exists
mkdir -p export

echo "📄 Building PDF (light theme)..."
ibis-next pdf

echo "🌙 Building PDF (dark theme)..."
ibis-next pdf dark

echo "📱 Building EPUB..."
ibis-next epub

echo "📑 Building samples..."
ibis-next sample
ibis-next sample dark

# Return to the original directory for git operations
cd "${GITHUB_WORKSPACE:-$(pwd)}"

# Return to workspace root for git operations
cd "${GITHUB_WORKSPACE:-$(pwd)}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "ℹ️  Not in a git repository, skipping commit"
    echo "✅ eBooks built successfully!"
    exit 0
fi

# Check if there are changes to commit
if git diff --quiet HEAD -- "${ibis_path}/export/" 2>/dev/null; then
    echo "ℹ️  No changes detected in export/ directory, skipping commit"
    echo "✅ eBooks built successfully!"
    exit 0
fi

# Configure Git and commit changes
echo "📝 Committing and pushing changes..."
git config --global user.email "${email}"
git config --global user.name "Ibis Build Action"

git add "${ibis_path}/export/"
git commit -m "${commit_message}"
git push origin "${branch}"

echo "✅ Successfully built and pushed eBooks to ${branch}!"
