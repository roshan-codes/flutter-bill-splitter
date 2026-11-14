#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "----------------------------------------"
echo "Installing / Updating Flutter SDK..."
echo "----------------------------------------"

if [ -d "$HOME/flutter" ]; then
  echo "Flutter directory exists. Pulling latest stable..."
  cd "$HOME/flutter"
  git pull
  cd - > /dev/null
else
  echo "Cloning Flutter stable channel..."
  git clone -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
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
