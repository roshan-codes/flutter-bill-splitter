#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="$HOME/flutter-$FLUTTER_VERSION"

echo "----------------------------------------"
echo "Setting up Flutter $FLUTTER_VERSION..."
echo "----------------------------------------"

# Remove any legacy unpinned flutter directory
if [ -d "$HOME/flutter" ]; then
  echo "Removing legacy cached flutter..."
  rm -rf "$HOME/flutter"
fi

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter $FLUTTER_VERSION..."
  git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"

echo "----------------------------------------"
echo "Flutter Information:"
echo "----------------------------------------"
flutter --version

echo "----------------------------------------"
echo "Getting dependencies..."
echo "----------------------------------------"
flutter pub get

echo "----------------------------------------"
echo "Building Flutter Web (Release)..."
echo "----------------------------------------"
flutter build web --release

echo "----------------------------------------"
echo "Build succeeded! Web files are in build/web"
echo "----------------------------------------"
