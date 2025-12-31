# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated building, testing, and releasing of macos-github-overlay.

## Workflows

### 1. CI (`ci.yml`)

**Triggers:**
- Push to `main` or `copilot/*` branches
- Pull requests to `main`
- Manual dispatch

**Purpose:**
- Lints Python code with flake8 and black
- Validates package structure
- Checks build configuration
- Tests package imports
- Verifies documentation

**Usage:**
Runs automatically on push/PR. No manual action needed.

### 2. Build DMG (`build-dmg.yml`)

**Triggers:**
- Manual dispatch (with architecture selection)
- Push to version tags (e.g., `v1.0.0`)
- Release creation

**Purpose:**
- Builds the .app bundle using py2app
- Creates a DMG installer
- Uploads DMG as artifact
- Attaches DMG to GitHub releases (for tagged versions)

**Manual Trigger:**
1. Go to Actions tab in GitHub
2. Select "Build DMG" workflow
3. Click "Run workflow"
4. Choose architecture:
   - `universal` (Intel + Apple Silicon) - recommended
   - `x86_64` (Intel only)
   - `arm64` (Apple Silicon only)
5. Click "Run workflow"

**Automatic Release:**
When you push a version tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow will:
1. Build the DMG
2. Name it with version and architecture
3. Upload to the GitHub release
4. Make it available for download

## Creating a Release

To create a new release with DMG:

1. **Update version** in `macos_github_overlay/about/version.txt`

2. **Commit and push changes:**
   ```bash
   git add macos_github_overlay/about/version.txt
   git commit -m "Release v1.0.0"
   git push
   ```

3. **Create and push tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. **Create release on GitHub:**
   - Go to Releases
   - Click "Create a new release"
   - Select the tag you created
   - Fill in release notes
   - The DMG will be automatically attached by the workflow

## Build Artifacts

After a successful DMG build:
- **Artifacts** are available for 30 days in the Actions tab
- **Release assets** are attached to releases permanently
- DMG files are named: `macos-github-overlay-{version}-{arch}.dmg`

## Local Testing

To test the DMG creation locally before pushing:

```bash
# Build for universal architecture
./create_dmg.sh

# Build for specific architecture
./create_dmg.sh --arch x86_64
./create_dmg.sh --arch arm64

# Use advanced DMG styling (requires create-dmg)
./create_dmg.sh --method advanced
```

## Troubleshooting

### Workflow fails with "py2app not found"
- The workflow installs py2app automatically
- This shouldn't happen unless there's a pip installation issue

### DMG creation fails
- Check that all required files exist (logo, icon.icns, etc.)
- Verify setup.py configuration
- Check workflow logs for specific error messages

### Release doesn't have DMG attached
- Ensure the tag starts with 'v' (e.g., v1.0.0, not 1.0.0)
- Check that the workflow completed successfully
- Verify GITHUB_TOKEN has permission to upload release assets

## Security

- Workflows use official GitHub Actions (e.g., actions/checkout@v4)
- No third-party actions that require secrets
- GITHUB_TOKEN is automatically provided by GitHub
- No manual secrets configuration needed
