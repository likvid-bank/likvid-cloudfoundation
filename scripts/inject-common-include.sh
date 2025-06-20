#!/bin/bash

# Script to inject common include block at the top of terragrunt.hcl files in foundations/
# that are tracked by git and don't already have the include "common" block

set -euo pipefail

# The include block to inject
COMMON_INCLUDE='include "common" {
  path = find_in_parent_folders("common.hcl")
}'

# Get all terragrunt.hcl files in foundations/ that are tracked by git
git_files=$(git ls-files | grep "foundations/.*terragrunt\.hcl" || true)

if [ -z "$git_files" ]; then
    echo "No terragrunt.hcl files found in foundations/ folder"
    exit 0
fi

echo "Found $(echo "$git_files" | wc -l) terragrunt.hcl files in foundations/"

# Process each file
while IFS= read -r file; do
    if [ ! -f "$file" ]; then
        echo "Warning: File $file not found, skipping"
        continue
    fi

    # Check if the file already has the common include block
    if grep -q 'include "common"' "$file"; then
        echo "Skipping $file - already has common include block"
        continue
    fi

    echo "Processing $file"

    # Create a temporary file with the new content
    temp_file=$(mktemp)

    # Add the common include block at the top
    echo "$COMMON_INCLUDE" > "$temp_file"
    echo "" >> "$temp_file"  # Add empty line after the block

    # Append the original file content
    cat "$file" >> "$temp_file"

    # Replace the original file with the new content
    mv "$temp_file" "$file"

    echo "✓ Injected common include block into $file"

done <<< "$git_files"

echo ""
echo "Done! Processed all terragrunt.hcl files in foundations/"
echo "You can now review the changes with: git diff"
