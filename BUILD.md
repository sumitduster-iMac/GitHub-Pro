# Build and Run Instructions

## Prerequisites

- macOS 10.15 (Catalina) or later
- Python 3.10 or higher
- pip (Python package installer)

## Quick Start

### 1. Install Dependencies

```bash
pip3 install -r requirements.txt
```

This will install:
- pyobjc-core
- pyobjc-framework-Cocoa
- pyobjc-framework-WebKit
- pyobjc-framework-Quartz
- pyobjc-framework-ApplicationServices

### 2. Run the Application

**Option A: Direct execution**
```bash
python3 run.py
```

**Option B: Module execution**
```bash
python3 -m macos_github_overlay
```

**Option C: Install and run as command**
```bash
pip3 install -e .
macos-github-overlay
```

### 3. Grant Accessibility Permissions

On first launch, you'll be prompted to grant Accessibility permissions:

1. Go to **System Settings** (or **System Preferences** on older macOS)
2. Navigate to **Privacy & Security** → **Accessibility**
3. Enable the checkbox for:
   - **Terminal** (if running from Terminal)
   - **Python** (if running python3 directly)
   - **macos-github-overlay** (if running from .app bundle)

## Building a Standalone .app Bundle

### Install py2app

```bash
pip3 install py2app
```

### Build Options

**Universal Binary (Intel + Apple Silicon):**
```bash
python3 setup.py py2app
```

**Intel x86_64 Only:**
```bash
PY2APP_ARCH=x86_64 python3 setup.py py2app
```

**Apple Silicon arm64 Only:**
```bash
PY2APP_ARCH=arm64 python3 setup.py py2app
```

The built application will be in the `dist/` directory:
```
dist/macos-github-overlay.app
```

### Running the .app Bundle

Double-click the application in Finder, or run from Terminal:
```bash
open dist/macos-github-overlay.app
```

## Command Line Options

```bash
# Check version
python3 -c "import macos_github_overlay; print(macos_github_overlay.__version__)"

# Install to run at login
macos-github-overlay --install-startup

# Remove from login items
macos-github-overlay --uninstall-startup

# Check accessibility permissions
macos-github-overlay --check-permissions
```

## Development

### Project Structure

```
macos_github_overlay/
├── __init__.py          # Package initialization
├── __main__.py          # Entry point for module execution
├── main.py              # CLI and main application logic
├── app.py               # AppDelegate and UI components
├── constants.py         # Configuration (URL, hotkeys, etc.)
├── listener.py          # Global hotkey handling
├── launcher.py          # Startup and permissions
├── health_checks.py     # Crash detection
├── about/               # Package metadata
└── logo/                # Icons and images
```

### Running Tests

Currently, this application doesn't include automated tests since it's primarily a GUI application that requires macOS-specific frameworks. However, you can manually test:

1. **Launch test**: Does the app start without errors?
2. **Window test**: Does the overlay window appear?
3. **Hotkey test**: Does Option+Space toggle the window?
4. **Menu test**: Do all menu options work?
5. **Session test**: Does GitHub login persist after restart?

### Debugging

Enable verbose output:
```bash
python3 run.py 2>&1 | tee debug.log
```

Check error logs:
```bash
cat ~/Library/Logs/macos-github-overlay/macos_github_overlay_error_log.txt
```

### Code Style

The codebase follows the style of the original macos-grok-overlay:
- PEP 8 naming conventions (mostly)
- PyObjC-style method names with underscores (e.g., `methodName_`)
- Clear comments for complex operations
- Modular structure for maintainability

## Troubleshooting

### "Failed to create event tap"

This means Accessibility permissions are not granted. Run:
```bash
macos-github-overlay --check-permissions
```

### Module Import Errors

Ensure PyObjC frameworks are installed:
```bash
pip3 install --upgrade pyobjc-core pyobjc-framework-Cocoa pyobjc-framework-WebKit pyobjc-framework-Quartz pyobjc-framework-ApplicationServices
```

### Crash Loop

The application has built-in crash detection. If it crashes 3 times within 60 seconds, it will stop auto-restarting. To reset:
```bash
rm ~/Library/Logs/macos-github-overlay/macos_github_overlay_crash_counter.txt
```

### py2app Build Fails

Make sure you have Xcode Command Line Tools:
```bash
xcode-select --install
```

### Universal Binary Issues

If building a universal binary fails, try building for your specific architecture:
```bash
# For Intel Macs
PY2APP_ARCH=x86_64 python3 setup.py py2app

# For Apple Silicon Macs
PY2APP_ARCH=arm64 python3 setup.py py2app
```

## Distribution

### Creating a DMG Installer

While this repository doesn't include a DMG builder, you can create one manually:

1. Build the .app bundle
2. Create a new DMG:
```bash
hdiutil create -volname "macos-github-overlay" -srcfolder dist -ov -format UDZO macos-github-overlay.dmg
```

3. Or use create-dmg (install via Homebrew):
```bash
brew install create-dmg
create-dmg \
  --volname "GitHub Overlay" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "macos-github-overlay.app" 200 190 \
  --hide-extension "macos-github-overlay.app" \
  --app-drop-link 600 185 \
  "macos-github-overlay.dmg" \
  "dist/"
```

## Uninstallation

1. Remove from login items:
```bash
macos-github-overlay --uninstall-startup
```

2. Quit the application

3. Remove the application:
```bash
# If installed via pip
pip3 uninstall macos-github-overlay

# If using .app bundle
rm -rf /Applications/macos-github-overlay.app
```

4. Clean up logs and preferences:
```bash
rm -rf ~/Library/Logs/macos-github-overlay
rm -f ~/Library/LaunchAgents/com.*.macosgithuboverlay.plist
```

## Support

For issues, questions, or contributions, please visit:
https://github.com/sumitduster-iMac/GitHub-Pro

## License

MIT License - See LICENSE file for details.
