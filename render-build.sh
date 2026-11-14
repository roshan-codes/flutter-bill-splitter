#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status
set -e

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="$HOME/flutter-$FLUTTER_VERSION"
FLUTTER_BIN="$FLUTTER_DIR/bin/flutter"

echo "========================================"
echo "TTMM RENDER BUILD STARTING"
echo "Target Flutter: $FLUTTER_VERSION"
echo "========================================"

# Purge any unpinned or legacy flutter directory
rm -rf "$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Cloning Flutter $FLUTTER_VERSION..."
  git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "Using Flutter SDK:"
"$FLUTTER_BIN" --version

echo "Resolving dependencies..."
"$FLUTTER_BIN" pub get

echo "Applying Dart 3.7+ compatibility patches if needed..."
python3 -c "
import glob, os
pattern = os.path.expanduser('~/.pub-cache/hosted/pub.dev/google_fonts-*/lib/src/google_fonts_variant.dart')
for f in glob.glob(pattern):
    content = open(f).read()
    if 'const _fontWeightToFilenameWeightParts' in content:
        open(f, 'w').write(content.replace('const _fontWeightToFilenameWeightParts', 'final _fontWeightToFilenameWeightParts'))
        print(f'Patched {f}')
" 2>/dev/null || true

echo "Compiling Flutter Web (Release)..."
"$FLUTTER_BIN" build web --release

echo "========================================"
echo "BUILD SUCCEEDED: Output in build/web"
echo "========================================"
