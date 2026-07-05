#!/bin/bash

# Set strict mode
set -e

# Detect Flutter SDK
FLUTTER_CMD="flutter"
if ! command -v flutter &> /dev/null; then
    if [ -f "/home/ashok/flutter/bin/flutter" ]; then
        FLUTTER_CMD="/home/ashok/flutter/bin/flutter"
    else
        echo "Error: Flutter SDK not found in PATH or at /home/ashok/flutter/bin/flutter"
        exit 1
    fi
fi

echo "=== Maru Prajapat Build Script ==="
echo "Using Flutter SDK at: $FLUTTER_CMD"

# Verify .env
if [ ! -f ".env" ]; then
    echo "Error: .env file not found in the root directory!"
    exit 1
fi
echo "✓ .env file found."

# Verify signing keys
if [ ! -f "android/key.properties" ]; then
    echo "Error: android/key.properties not found!"
    exit 1
fi
if [ ! -f "android/app/upload-keystore.jks" ]; then
    echo "Error: android/app/upload-keystore.jks not found!"
    exit 1
fi
echo "✓ Android signing config and keystore verified."

# Extract version from pubspec.yaml
VERSION_LINE=$(grep "^version:" pubspec.yaml)
CURRENT_VERSION=$(echo "$VERSION_LINE" | cut -d' ' -f2)
CURRENT_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
CURRENT_CODE=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

echo "Current version in pubspec.yaml: $CURRENT_VERSION (Name: $CURRENT_NAME, Code: $CURRENT_CODE)"

# Default values
NEW_NAME="$CURRENT_NAME"
NEW_CODE="$CURRENT_CODE"

# Check for non-interactive flags or user input
if [ "$1" == "--non-interactive" ] || [ "$1" == "-y" ]; then
    echo "Running in non-interactive mode. Using current version details."
else
    read -p "Enter new version name (default: $CURRENT_NAME): " input_name
    if [ ! -z "$input_name" ]; then
        NEW_NAME="$input_name"
    fi

    read -p "Enter new version code (default: $CURRENT_CODE): " input_code
    if [ ! -z "$input_code" ]; then
        NEW_CODE="$input_code"
    fi
fi

echo "Building version: $NEW_NAME+$NEW_CODE..."

# Clean build cache
echo "Cleaning build cache to prevent config caching..."
$FLUTTER_CMD clean

# Get dependencies
echo "Getting packages..."
$FLUTTER_CMD pub get

# Build APK
echo "Building Release APK..."
$FLUTTER_CMD build apk --release \
  --dart-define-from-file=.env \
  --build-name="$NEW_NAME" \
  --build-number="$NEW_CODE"

# Build AppBundle
echo "Building Release AppBundle..."
$FLUTTER_CMD build appbundle --release \
  --dart-define-from-file=.env \
  --build-name="$NEW_NAME" \
  --build-number="$NEW_CODE"

echo "=================================================="
echo "✓ Builds generated successfully!"
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AppBundle: build/app/outputs/bundle/release/app-release.aab"
echo "=================================================="
