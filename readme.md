<p align="center">
  <h1 align="center"><code>macos-github-overlay</code></h1>
</p>

<p align="center">
A simple macOS overlay application for pinning <code>github.com</code> to a dedicated window with a global hotkey <code>Option+Space</code>.
</p>

## Overview

This application provides a dedicated, always-accessible overlay window for GitHub on macOS. Based on the architecture of [macos-grok-overlay](https://github.com/tchlux/macos-grok-overlay), it uses PyObjC to create a native macOS experience.

## Features

- **Borderless floating window** with rounded corners and shadow
- **Global hotkey**: `Option + Space` to toggle visibility
- **Always-on-top** window (NSFloatingWindowLevel)
- **Resizable and draggable** by the top bar
- **Session persistence**: GitHub login persists across restarts
- **Menu bar integration** with status icon
- **Customizable hotkey**: Set your own trigger key combination
- **Auto-launch support**: Optional startup at login
- **Cross-architecture support**: Universal binary for Intel x86_64 and Apple Silicon arm64

## Requirements

- macOS (tested on macOS 10.15+)
- Python 3.10 or higher
- Accessibility permissions (for global hotkey monitoring)

## Installation

### From Source

1. Clone the repository:
```bash
git clone https://github.com/sumitduster-iMac/GitHub-Pro.git
cd GitHub-Pro
```

2. Install dependencies:
```bash
pip3 install -r requirements.txt
```

3. Run the application:
```bash
python3 -m macos_github_overlay
```

Or use the provided run script:
```bash
python3 run.py
```

### Install as Package

Install directly from the repository:
```bash
pip3 install -e .
```

Then run:
```bash
macos-github-overlay
```

### Enable Auto-launch at Login

To have the application start automatically when you log in:
```bash
macos-github-overlay --install-startup
```

To disable auto-launch:
```bash
macos-github-overlay --uninstall-startup
```

## Usage

### First Launch

When you first launch the application, you'll be prompted to grant Accessibility permissions. This is required for the global hotkey (`Option + Space`) to work.

1. Go to **System Settings** → **Privacy & Security** → **Accessibility**
2. Enable permissions for Terminal, Python, or the macos-github-overlay app (depending on how you're running it)

### Keyboard Shortcuts

- **Option + Space**: Toggle overlay visibility (show/hide)
- **Command + H**: Hide the overlay
- **Command + Q**: Quit the application
- **Command + C/V/X/A**: Standard copy/paste/cut/select all

### Menu Bar Options

Click the menu bar icon to access:
- **Show/Hide GitHub**: Toggle overlay visibility
- **Home**: Return to GitHub homepage
- **Clear Web Cache**: Clear cookies and cache
- **Request Microphone Access**: Enable microphone for GitHub features
- **Install/Uninstall Autolauncher**: Manage startup behavior
- **Set New Trigger**: Customize the hotkey
- **Quit**: Exit the application

### Customizing the Hotkey

1. Click the menu bar icon
2. Select "Set New Trigger"
3. Press your desired key combination
4. The new trigger will be saved and used immediately

## Building a Standalone .app Bundle

To create a standalone macOS application using py2app:

1. Install py2app:
```bash
pip3 install py2app
```

2. Build the application:
```bash
python3 setup.py py2app
```

The application will be created in the `dist/` directory.

### Building Universal Binary

To create a universal binary that works on both Intel and Apple Silicon:

```bash
# For universal binary (default)
python3 setup.py py2app

# For specific architecture
PY2APP_ARCH=x86_64 python3 setup.py py2app  # Intel only
PY2APP_ARCH=arm64 python3 setup.py py2app   # Apple Silicon only
```

## Architecture

The application is structured as follows:

```
macos_github_overlay/
├── __init__.py          # Package initialization
├── __main__.py          # Entry point for python -m execution
├── main.py              # Main application entry and CLI handling
├── app.py               # AppDelegate, AppWindow, and UI components
├── constants.py         # Configuration constants (URL, hotkeys, etc.)
├── listener.py          # Global hotkey monitoring and handling
├── launcher.py          # Startup management and permissions
├── health_checks.py     # Crash detection and error logging
├── about/               # Package metadata
│   ├── version.txt
│   ├── author.txt
│   ├── description.txt
│   ├── requirements.txt
│   └── ...
└── logo/                # Application icons and images
    ├── logo_white.png
    ├── logo_black.png
    └── icon.icns
```

### Key Components

- **WKWebView**: Renders GitHub in a native WebKit view
- **NSWindow**: Custom borderless window with rounded corners
- **CGEventTap**: Captures global keyboard events for hotkey
- **NSStatusBar**: Menu bar integration
- **Launch Agent**: Auto-launch functionality via macOS launchd

## Technical Details

- **PyObjC** bridges Python to macOS Cocoa APIs
- **WKWebView** provides the web rendering engine
- **Quartz Event Tap** enables global hotkey monitoring
- **Session persistence** via WKWebView's default data store
- **Crash loop detection** prevents infinite restart cycles
- **Universal binary support** through py2app configuration

## Troubleshooting

### Hotkey Not Working

Ensure Accessibility permissions are granted:
```bash
macos-github-overlay --check-permissions
```

### Application Won't Start

Check the error log:
```bash
cat ~/Library/Logs/macos-github-overlay/macos_github_overlay_error_log.txt
```

### Crash Loop Detected

If the application crashes repeatedly, it will stop auto-restarting. To reset:
```bash
rm ~/Library/Logs/macos-github-overlay/macos_github_overlay_crash_counter.txt
```

### Clear Custom Trigger

To reset the hotkey to default (Option + Space):
```bash
rm ~/Library/Logs/macos-github-overlay/custom_trigger.json
```

## Uninstallation

1. Remove from auto-launch:
```bash
macos-github-overlay --uninstall-startup
```

2. Uninstall the package:
```bash
pip3 uninstall macos-github-overlay
```

3. Clean up logs and preferences:
```bash
rm -rf ~/Library/Logs/macos-github-overlay
```

## Credits

Based on the excellent [macos-grok-overlay](https://github.com/tchlux/macos-grok-overlay) by [tchlux](https://github.com/tchlux).

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Disclaimer

This is an independent project and is not officially affiliated with or endorsed by GitHub, Inc.
