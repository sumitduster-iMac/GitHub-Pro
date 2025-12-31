#!/bin/bash
#
# create_dmg.sh - Build and package macos-github-overlay as a DMG installer
#
# This script automates the process of:
# 1. Building the .app bundle using py2app
# 2. Creating a DMG installer with proper layout
# 3. Configuring DMG appearance and settings
#
# Usage:
#   ./create_dmg.sh [--arch ARCH] [--method METHOD] [--skip-build]
#
# Options:
#   --arch ARCH       Architecture: universal (default), x86_64, or arm64
#   --method METHOD   DMG method: simple (default) or advanced (requires create-dmg)
#   --skip-build      Skip the py2app build step (use existing dist/ folder)
#   --help            Show this help message
#

set -e  # Exit on error

# Default values
ARCH="universal"
METHOD="simple"
SKIP_BUILD=false
APP_NAME="macos-github-overlay"
DMG_NAME="${APP_NAME}"
DIST_DIR="dist"
APP_PATH="${DIST_DIR}/${APP_NAME}.app"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --arch)
            ARCH="$2"
            shift 2
            ;;
        --method)
            METHOD="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --help)
            # Extract header comments (lines starting with # until first non-comment)
            sed -n '2,/^[^#]/p' "$0" | grep "^#" | sed 's/^# \?//' | head -n -1
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate architecture
if [[ ! "$ARCH" =~ ^(universal|x86_64|arm64)$ ]]; then
    echo "Error: Invalid architecture '$ARCH'"
    echo "Valid options: universal, x86_64, arm64"
    exit 1
fi

# Validate method
if [[ ! "$METHOD" =~ ^(simple|advanced)$ ]]; then
    echo "Error: Invalid method '$METHOD'"
    echo "Valid options: simple, advanced"
    exit 1
fi

# Print configuration
echo "=================================="
echo "macos-github-overlay DMG Builder"
echo "=================================="
echo "Architecture: $ARCH"
echo "Method: $METHOD"
echo "Skip build: $SKIP_BUILD"
echo ""

# Step 1: Build the .app bundle (unless skipped)
if [ "$SKIP_BUILD" = false ]; then
    echo "Step 1: Building .app bundle with py2app..."
    
    # Check if py2app is installed
    if ! python3 -c "import py2app" 2>/dev/null; then
        echo "Error: py2app is not installed"
        echo "Install with: pip3 install py2app"
        exit 1
    fi
    
    # Clean previous build
    if [ -d "build" ]; then
        echo "Cleaning previous build..."
        rm -rf build
    fi
    if [ -d "$DIST_DIR" ]; then
        echo "Cleaning previous dist..."
        rm -rf "$DIST_DIR"
    fi
    
    # Build with specified architecture
    if [ "$ARCH" = "universal" ]; then
        echo "Building universal binary (x86_64 + arm64)..."
        python3 setup.py py2app
    else
        echo "Building for $ARCH..."
        PY2APP_ARCH="$ARCH" python3 setup.py py2app
    fi
    
    echo "✓ Build complete"
else
    echo "Step 1: Skipping build (using existing dist/)"
    
    # Verify that the app exists
    if [ ! -d "$APP_PATH" ]; then
        echo "Error: $APP_PATH does not exist"
        echo "Run without --skip-build to build the app first"
        exit 1
    fi
fi

echo ""

# Step 2: Create the DMG
if [ "$METHOD" = "simple" ]; then
    echo "Step 2: Creating DMG with hdiutil (simple method)..."
    
    DMG_FILE="${DMG_NAME}.dmg"
    
    # Remove existing DMG if present
    if [ -f "$DMG_FILE" ]; then
        echo "Removing existing DMG..."
        rm -f "$DMG_FILE"
    fi
    
    # Create a temporary directory for DMG contents
    DMG_TEMP="dmg_temp"
    rm -rf "$DMG_TEMP"
    mkdir -p "$DMG_TEMP"
    
    # Copy the app to the temp directory
    echo "Copying app to DMG staging area..."
    cp -R "$APP_PATH" "$DMG_TEMP/"
    
    # Create Applications symlink
    echo "Creating Applications symlink..."
    ln -s /Applications "$DMG_TEMP/Applications"
    
    # Create the DMG
    echo "Creating DMG image..."
    hdiutil create -volname "$APP_NAME" \
        -srcfolder "$DMG_TEMP" \
        -ov \
        -format UDZO \
        "$DMG_FILE"
    
    # Clean up temp directory
    rm -rf "$DMG_TEMP"
    
    echo "✓ DMG created: $DMG_FILE"
    
elif [ "$METHOD" = "advanced" ]; then
    echo "Step 2: Creating DMG with create-dmg (advanced method)..."
    
    # Check if create-dmg is installed
    if ! command -v create-dmg &> /dev/null; then
        echo "Error: create-dmg is not installed"
        echo "Install with: brew install create-dmg"
        exit 1
    fi
    
    # Verify icon file exists
    ICON_FILE="${APP_PATH}/Contents/Resources/icon.icns"
    if [ ! -f "$ICON_FILE" ]; then
        echo "Warning: Icon file not found at $ICON_FILE"
        echo "DMG will be created without custom icon"
        ICON_OPTION=""
    else
        ICON_OPTION="--volicon \"$ICON_FILE\""
    fi
    
    DMG_FILE="${DMG_NAME}.dmg"
    
    # Remove existing DMG if present
    if [ -f "$DMG_FILE" ]; then
        echo "Removing existing DMG..."
        rm -f "$DMG_FILE"
    fi
    
    # Create DMG with custom appearance
    echo "Creating styled DMG image..."
    
    # Build create-dmg command with conditional icon
    CMD="create-dmg \
        --volname \"GitHub Overlay\" \
        $ICON_OPTION \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon \"${APP_NAME}.app\" 175 190 \
        --hide-extension \"${APP_NAME}.app\" \
        --app-drop-link 425 185 \
        --no-internet-enable \
        \"$DMG_FILE\" \
        \"$DIST_DIR/\""
    
    eval $CMD
    
    echo "✓ DMG created: $DMG_FILE"
fi

echo ""
echo "=================================="
echo "Build Summary"
echo "=================================="
echo "App bundle: $APP_PATH"
echo "DMG file: $DMG_FILE"
echo "Architecture: $ARCH"

# Display file sizes
if [ -d "$APP_PATH" ]; then
    APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    echo "App size: $APP_SIZE"
fi

if [ -f "$DMG_FILE" ]; then
    DMG_SIZE=$(du -sh "$DMG_FILE" | cut -f1)
    echo "DMG size: $DMG_SIZE"
fi

echo ""
echo "✓ DMG creation complete!"
echo ""
echo "To install:"
echo "  1. Open $DMG_FILE"
echo "  2. Drag ${APP_NAME}.app to Applications folder"
echo "  3. Eject the DMG"
echo "  4. Run from Applications or Spotlight"
