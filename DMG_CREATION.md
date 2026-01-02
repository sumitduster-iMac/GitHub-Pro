# DMG Creation Quick Reference

This document provides a quick reference for creating DMG installers for the macos-github-overlay application.

## Quick Start

**Most Common Usage:**
```bash
./create_dmg.sh
```

This will:
1. Build a universal binary .app (works on Intel and Apple Silicon)
2. Create a DMG named `macos-github-overlay.dmg`
3. The DMG includes the app and an Applications folder shortcut

## Command Reference

### Basic Commands

```bash
# Build and create DMG (default: universal binary, simple method)
./create_dmg.sh

# Skip building if .app already exists
./create_dmg.sh --skip-build

# View all available options
./create_dmg.sh --help
```

### Architecture Options

```bash
# Universal binary - works on both Intel and Apple Silicon (default)
./create_dmg.sh --arch universal

# Intel (x86_64) only
./create_dmg.sh --arch x86_64

# Apple Silicon (arm64) only
./create_dmg.sh --arch arm64
```

### DMG Styling Methods

```bash
# Simple method using hdiutil (default, no additional dependencies)
./create_dmg.sh --method simple

# Advanced method with custom styling (requires: brew install create-dmg)
./create_dmg.sh --method advanced
```

### Combined Options

```bash
# Build for specific architecture with advanced styling
./create_dmg.sh --arch arm64 --method advanced

# Use existing build and create DMG with advanced styling
./create_dmg.sh --skip-build --method advanced
```

## Prerequisites

### For All Methods
- macOS 10.15 (Catalina) or later
- Python 3.10 or higher
- py2app: `pip3 install py2app`

### For Advanced Method Only
- create-dmg: `brew install create-dmg`

## GitHub Actions

### Manual Build Trigger

1. Go to https://github.com/sumitduster-iMac/GitHub-Pro/actions
2. Click "Build DMG" workflow
3. Click "Run workflow"
4. Select architecture (universal, x86_64, or arm64)
5. Click "Run workflow" button
6. Download DMG from artifacts after build completes

### Automatic Release Build

When you push a version tag:

```bash
# 1. Update version
echo "1.0.0" > macos_github_overlay/about/version.txt

# 2. Commit and push
git add macos_github_overlay/about/version.txt
git commit -m "Bump version to 1.0.0"
git push

# 3. Create and push tag
git tag v1.0.0
git push origin v1.0.0

# 4. Create release on GitHub
# The DMG will be automatically built and attached
```

## Output Files

After running the script:

- **Local build:** `macos-github-overlay.dmg` in the current directory (single, generic name, regardless of version/architecture)
- **GitHub Actions:** `macos-github-overlay-{version}-{arch}.dmg` as artifact/release asset (for example, `macos-github-overlay-1.0.0-arm64.dmg`)
  - This difference is intentional: local builds use a fixed filename for convenience, while CI builds include version and architecture to make releases easier to identify.

## Troubleshooting

### "py2app not found"
```bash
pip3 install py2app
```

### "create-dmg not found" (only for --method advanced)
```bash
brew install create-dmg
```

### "Icon file not found"
The script will warn but continue. The DMG will be created without a custom volume icon.

### Build fails with architecture errors
- On Intel Mac: Use `--arch x86_64` or `--arch universal`
- On Apple Silicon: Use `--arch arm64` or `--arch universal`
- Universal builds work on both but require more build time

### DMG creation fails
1. Check that the .app was built successfully:
   ```bash
   ls -la dist/macos-github-overlay.app
   ```
2. Try the simple method first:
   ```bash
   ./create_dmg.sh --method simple --skip-build
   ```
3. Check for error messages in the output

## Installation from DMG

For end users installing from the DMG:

1. Download the DMG file
2. Double-click to open
3. Drag `macos-github-overlay.app` to the Applications folder
4. Eject the DMG
5. Launch from Applications or Spotlight
6. Grant Accessibility permissions when prompted

## More Information

- Full documentation: [BUILD.md](../BUILD.md)
- Workflow details: [.github/workflows/README.md](.github/workflows/README.md)
- Script source: [create_dmg.sh](../create_dmg.sh)
