#!/bin/bash

# Script to remove all remote and local branches except origin/main
# This script is destructive - it will delete branches!

echo "Starting Git branch cleanup..."
echo "This will remove all branches except origin/main"
echo "WARNING: This is a destructive operation!"
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# First, fetch from remote to get the latest branch information
echo "Fetching from remote..."
git fetch -p

# Switch to main branch to ensure we're not on a branch we're trying to delete
echo "Switching to main branch..."
git checkout main || git checkout master

# Pull latest changes
echo "Pulling latest changes..."
git pull origin main || git pull origin master

# Remove all local branches except main
echo "Removing local branches except main..."
git branch | grep -v "main" | grep -v "master" | xargs git branch -D

# List all remote branches except main and master
echo "Identifying remote branches to remove..."
REMOTE_BRANCHES=$(git branch -r | grep -v "origin/main" | grep -v "origin/master" | grep -v "HEAD" | sed 's/origin\///')

# Remove each remote branch
if [ -n "$REMOTE_BRANCHES" ]; then
    echo "Removing remote branches..."
    echo "$REMOTE_BRANCHES" | while read branch; do
        echo "Removing remote branch: $branch"
        git push origin --delete $branch
    done
else
    echo "No remote branches to remove."
fi

echo "Branch cleanup complete!"
echo "Remaining branches:"
git branch -a