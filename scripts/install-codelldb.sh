#!/usr/bin/env bash

set -euxo pipefail

# Configuration
INSTALL_DIR="$HOME/Programs/codelldb"
BIN_DIR="$HOME/.local/bin"
TMP_DIR="$(mktemp -d)"

# Ensure the bin directory exists
mkdir -p "$BIN_DIR"

# Detect platform
platform="linux-x64"
asset_name="codelldb-${platform}.vsix"

# Fetch latest release info from GitHub API
echo "Fetching latest codelldb release info..."
latest_url=$(curl -s https://api.github.com/repos/vadimcn/codelldb/releases/latest \
  | grep browser_download_url \
  | grep "$asset_name" \
  | cut -d '"' -f 4)

if [[ -z "$latest_url" ]]; then
  echo "Error: Could not find download URL for codelldb ($platform)."
  exit 1
fi

echo "Downloading: $latest_url"
cd "$TMP_DIR"
curl -LO "$latest_url"

# Extract .vsix (it's a zip file)
mkdir -p "$INSTALL_DIR"
unzip -q "$asset_name" -d "$INSTALL_DIR"
mv "$INSTALL_DIR"/extension/* "$INSTALL_DIR"
rm -r "$INSTALL_DIR"/extension

# Make symlink
EXECUTABLE="$INSTALL_DIR/adapter/codelldb"
LINK="$BIN_DIR/codelldb"

if [[ -f "$LINK" || -L "$LINK" ]]; then
  echo "Removing old symlink at $LINK"
  rm -f "$LINK"
fi

ln -s "$EXECUTABLE" "$LINK"

echo "✅ codelldb installed to $INSTALL_DIR"
echo "➡️  Symlinked to $LINK"

# Cleanup
rm -rf "$TMP_DIR"
