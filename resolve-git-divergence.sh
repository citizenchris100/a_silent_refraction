#!/bin/bash

# Git Divergent Branch Resolution Script
# This script helps resolve situations where your local and remote branches have diverged

# Show current status
echo "==== Current Git Status ===="
git status

echo ""
echo "==== Available Options ===="
echo "1. Merge (creates a merge commit combining both sets of changes)"
echo "2. Rebase (replays your changes on top of the remote changes)"
echo "3. Fast-forward only (only pulls if no merge is needed)"
echo "4. View differences between branches"
echo "5. Exit without changes"
echo ""

read -p "Select an option (1-5): " option

case $option in
    1)
        echo "Performing merge..."
        git config pull.rebase false
        git pull
        echo "Merge complete. Your local and remote changes have been combined."
        ;;
    2)
        echo "Performing rebase..."
        git config pull.rebase true
        git pull
        echo "Rebase complete. Your changes have been applied on top of the remote changes."
        ;;
    3)
        echo "Attempting fast-forward only pull..."
        git config pull.ff only
        git pull || echo "Fast-forward not possible. You need to choose merge or rebase."
        ;;
    4)
        echo "Showing differences between your branch and remote..."
        echo "Commits on your branch that aren't on remote:"
        git log origin/main..main --oneline
        echo ""
        echo "Commits on remote that aren't on your branch:"
        git log main..origin/main --oneline
        echo ""
        echo "Run this script again to resolve the divergence."
        ;;
    5)
        echo "Exiting without changes."
        ;;
    *)
        echo "Invalid option. Exiting."
        ;;
esac