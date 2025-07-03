#!/usr/bin/env bash
set -euo pipefail

# Config
INSTALL_DIR="$HOME/Programs/ueberzugpp"
BIN_DIR="$HOME/.local/bin"
REPO="jstkdng/ueberzugpp"
TMP_DIR="$(mktemp -d)"
GITHUB_API="https://api.github.com/repos/$REPO/releases/latest"

# Ensure bin directory exists
mkdir -p "$BIN_DIR"

# Get latest version from GitHub
echo "🔍 Fetching latest release from GitHub..."
latest_version=$(curl -s "$GITHUB_API" | grep -Po '"tag_name": "\K.*?(?=")')

if [[ -z "$latest_version" ]]; then
  echo "❌ Failed to get latest version from GitHub"
  exit 1
fi

echo "🔖 Latest version: $latest_version"

# Check installed version if exists
installed_version="none"
if [[ -f "$INSTALL_DIR/VERSION" ]]; then
  installed_version=$(<"$INSTALL_DIR/VERSION")
  echo "📦 Installed version: $installed_version"
fi

# Compare versions
if [[ "$installed_version" == "$latest_version" ]]; then
  echo "✅ ueberzugpp is already up to date ($installed_version)"
  exit 0
fi

# Clone specific tag
echo "⬇️  Installing ueberzugpp $latest_version..."
cd "$TMP_DIR"
git clone --branch "$latest_version" --depth 1 "https://github.com/$REPO.git"
cd ueberzugpp

# Build
cmake -DCMAKE_BUILD_TYPE=Release -B build
cmake --build build --parallel
mkdir -p "$INSTALL_DIR"
cp build/ueberzugpp "$INSTALL_DIR/"
cp build/ueberzug "$INSTALL_DIR/"

# Record installed version
echo "$latest_version" > "$INSTALL_DIR/VERSION"

# Symlink
ln -sf "$INSTALL_DIR/ueberzugpp" "$BIN_DIR/ueberzugpp"
ln -sf "$INSTALL_DIR/ueberzug" "$BIN_DIR/ueberzug"

echo "✅ Installed ueberzugpp $latest_version"
echo "➡️  Symlinked to $BIN_DIR/ueberzugpp"
echo "➡️  Symlinked to $BIN_DIR/ueberzug"

# Cleanup
rm -rf "$TMP_DIR"
