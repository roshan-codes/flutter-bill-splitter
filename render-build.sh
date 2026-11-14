#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

FLUTTER_VERSION="3.24.5"

echo "----------------------------------------"
echo "Setting up Flutter $FLUTTER_VERSION..."
echo "----------------------------------------"

if [ ! -d "$HOME/flutter" ]; then
  git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
fi

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

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
