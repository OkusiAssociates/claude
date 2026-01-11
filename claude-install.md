#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit

# Claude Code Installation Guide
cat <<'EOT'

◉ Claude Code Installation
  Official methods from Anthropic (2025)

  Native Binary (Recommended) - No Node.js required
  Homebrew (macOS only)

EOT

read -p 'Press any key to continue...'

# 1. Native Binary Installation (Recommended)
curl -fsSL https://claude.ai/install.sh | bash

# 2. Reload Shell Configuration
# shellcheck disable=SC1090
source ~/.bashrc  # For zsh: source ~/.zshrc

# 3. Verify Installation
claude --version
claude doctor

# 4. Authentication
cat <<'EOT'

◉ Authentication
  Run 'claude' in your terminal
  Type '/login' to authenticate with your Anthropic account

◉ Alternative Installation Methods

  macOS (Homebrew):
    brew install --cask claude-code

◉ Updates
  claude update

EOT

#fin
