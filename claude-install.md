#!/bin/bash
set -Eeuo pipefail

# Add NodeSource repository and install
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node -v  # Should show v22.x.x
npm -v   # Should show npm version

read

#  2. Configure npm for Global Packages (No sudo required)

# Create npm global directory
mkdir -p ~/.npm-global

# Configure npm to use new directory
npm config set prefix '~/.npm-global'

# Add to PATH (for bash)
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

#  3. Install Claude Code Globally

# Install without sudo
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version

#fin
