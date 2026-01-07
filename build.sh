#!/bin/bash

# Work Time Reminder - Build Script
# This script compiles the app and creates an .app bundle

set -e

APP_NAME="WorkTimeReminder"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building $APP_NAME..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Compile Swift files
echo "📦 Compiling Swift files..."
swiftc -O \
    -sdk $(xcrun --show-sdk-path --sdk macosx) \
    -target arm64-apple-macosx12.0 \
    -parse-as-library \
    -emit-executable \
    -o "$MACOS_DIR/$APP_NAME" \
    WorkTimeReminder/*.swift

# Copy Info.plist
echo "📄 Copying Info.plist..."
cp WorkTimeReminder/Info.plist "$CONTENTS_DIR/"

# Create PkgInfo
echo "APPL????" > "$CONTENTS_DIR/PkgInfo"

echo "✅ Build complete!"
echo "📍 App location: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "To install (copy to Applications):"
echo "  cp -r $APP_BUNDLE /Applications/"

