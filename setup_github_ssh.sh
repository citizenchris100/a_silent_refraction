#!/bin/bash

echo "Setting up SSH authentication for GitHub"
echo ""

# Check for existing SSH keys
echo "Checking for existing SSH keys..."
if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
    echo "Existing SSH keys found."
    ls -la ~/.ssh/
    
    read -p "Do you want to use an existing key? (y/n): " USE_EXISTING
    
    if [[ "$USE_EXISTING" != "y" ]]; then
        echo "Let's create a new SSH key..."
    else
        echo "Using existing SSH key."
        SSH_KEY=$(ls ~/.ssh/id_*.pub | head -1)
        echo "Using key: $SSH_KEY"
    fi
else
    echo "No existing SSH keys found. Let's create one..."
    USE_EXISTING="n"
fi

# Generate a new SSH key if needed
if [[ "$USE_EXISTING" != "y" ]]; then
    echo "Generating new SSH key..."
    read -p "Enter your email address for the SSH key: " EMAIL
    
    # Generate ED25519 key (modern, recommended)
    ssh-keygen -t ed25519 -C "$EMAIL"
    
    SSH_KEY="$HOME/.ssh/id_ed25519.pub"
    echo "SSH key generated: $SSH_KEY"
fi

# Start the SSH agent and add the key
echo "Starting SSH agent..."
eval "$(ssh-agent -s)"

if [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
elif [ -f ~/.ssh/id_rsa ]; then
    ssh-add ~/.ssh/id_rsa 2>/dev/null
fi

# Find the public key file
if [ -z "$SSH_KEY" ]; then
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        SSH_KEY="$HOME/.ssh/id_ed25519.pub"
    elif [ -f ~/.ssh/id_rsa.pub ]; then
        SSH_KEY="$HOME/.ssh/id_rsa.pub"
    else
        echo "Error: Could not find an SSH public key."
        exit 1
    fi
fi

# Display the public key to copy
echo ""
echo "Copy the following SSH public key to GitHub:"
echo "----------------------------------------------------------------"
cat "$SSH_KEY"
echo "----------------------------------------------------------------"
echo ""
echo "Now add this key to GitHub:"
echo "1. Go to GitHub → Settings → SSH and GPG keys → New SSH key"
echo "2. Give it a title (e.g., 'My Development Machine')"
echo "3. Paste the key and click 'Add SSH key'"
echo ""

read -p "Press Enter when you've added the key to GitHub..." 

# Test the connection
echo "Testing connection to GitHub..."
ssh -T git@github.com

echo ""
echo "If you see 'Hi username! You've successfully authenticated...' above, setup is complete!"
echo ""

# Update remotes to use SSH
read -p "Would you like to update your repository to use SSH instead of HTTPS? (y/n): " UPDATE_REMOTE

if [[ "$UPDATE_REMOTE" == "y" ]]; then
    echo "Updating remote URL to use SSH..."
    
    # Get current HTTPS remote
    HTTPS_REMOTE=$(git remote get-url origin)
    
    # Skip if already using SSH
    if [[ $HTTPS_REMOTE == git@* ]]; then
        echo "Already using SSH remote: $HTTPS_REMOTE"
    else
        # Convert HTTPS to SSH format
        # Example: https://github.com/username/repo.git → git@github.com:username/repo.git
        SSH_REMOTE=$(echo $HTTPS_REMOTE | sed 's|https://github.com/|git@github.com:|')
        
        # Update the remote
        git remote set-url origin "$SSH_REMOTE"
        echo "Remote updated to: $(git remote get-url origin)"
    fi
fi

echo "SSH setup complete!"