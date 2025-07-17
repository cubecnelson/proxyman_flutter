# GitHub Actions Workflow for Flutter Windows Build

This repository contains a GitHub Actions workflow for building Flutter applications for Windows platform.

## Overview

The workflow consists of the following jobs:

1. **Setup** - Installs Flutter and configures the environment
2. **Test** - Runs Flutter tests and code quality checks
3. **Build Windows** - Builds the Flutter app for Windows
4. **Create Installer** - Creates Windows installer (optional)

## Workflow Triggers

### Automatic Triggers
The workflow automatically runs on:
- **Push** to `main` or `develop` branches
- **Pull Request** to `main` or `develop` branches

### Manual Triggers
You can manually trigger the workflow with custom parameters:
- **Build Type**: Choose between `release` or `debug` builds
- **Access**: Go to Actions tab → Flutter Windows Build → Run workflow

## Jobs Details

### Setup Job
- **Runner**: Windows Latest
- **Purpose**: Initial Flutter setup and dependency caching
- **Actions**:
  - Checkout code
  - Setup Flutter SDK
  - Enable Windows desktop support
  - Get dependencies
  - Cache Flutter dependencies

### Test Job
- **Runner**: Windows Latest
- **Dependencies**: Requires setup job completion
- **Actions**:
  - Run Flutter unit tests
  - Analyze code with `flutter analyze`
  - Check code formatting with `flutter format`

### Build Windows Job
- **Runner**: Windows Latest
- **Dependencies**: Requires test job completion
- **Actions**:
  - Build Flutter app for Windows (release or debug)
  - Upload build artifacts
- **Artifacts**:
  - Release builds: `windows-release` (retained for 7 days)
  - Debug builds: `windows-debug` (retained for 1 day)

### Create Installer Job
- **Runner**: Windows Latest
- **Dependencies**: Requires build-windows job completion
- **Trigger**: Manual workflow dispatch with release build type
- **Actions**:
  - Download release artifacts
  - Create Windows installer
  - Upload installer artifacts
- **Artifacts**: `windows-installer` (retained for 30 days)

## Configuration

### Environment Variables
```yaml
env:
  FLUTTER_VERSION: 3.22.0
```

### Caching Strategy
The workflow caches:
- `.dart_tool/` - Dart tool cache
- `.pub-cache/` - Pub dependencies
- `build/` - Build artifacts

Cache key is based on:
- Runner OS
- Flutter version
- `pubspec.lock` hash

## Usage

### For Developers

1. **Automatic Builds**: Simply push to `main` or `develop` branches
2. **Manual Debug Build**: 
   - Go to Actions tab
   - Select "Flutter Windows Build"
   - Click "Run workflow"
   - Choose "debug" as build type

3. **Create Installer**:
   - Go to Actions tab
   - Select "Flutter Windows Build"
   - Click "Run workflow"
   - Choose "release" as build type
   - The installer job will run automatically

### Accessing Artifacts

1. **From GitHub UI**:
   - Go to Actions tab
   - Click on a completed workflow run
   - Scroll down to "Artifacts" section
   - Download the desired artifact

2. **Artifact Types**:
   - `windows-release`: Release build files
   - `windows-debug`: Debug build files
   - `windows-installer`: Windows installer (if created)

## Requirements

### GitHub Runner Requirements
- **Windows Latest**: For all jobs (setup, testing, and builds)
- **Memory**: At least 4GB RAM recommended
- **Disk Space**: At least 10GB free space

### Flutter Requirements
- Flutter SDK 3.22.0 or later
- Windows desktop support enabled
- All dependencies in `pubspec.yaml`

## Customization

### Adding Custom Build Steps
You can add custom build steps by modifying the workflow file:

```yaml
- name: Custom Build Step
  run: |
    echo "Adding custom build logic here"
    # Your custom commands
```

### Environment Variables
Add custom environment variables in the `env` section:

```yaml
env:
  FLUTTER_VERSION: 3.245
  FLUTTER_CHANNEL: stable"
  CUSTOM_VAR: "value"
```

### Conditional Execution
Jobs can be made conditional using `if` statements:

```yaml
- name: Conditional Step
  if: github.ref == 'refs/heads/main'
  run: echo "Only runs on main branch"
```

## Troubleshooting

### Common Issues

1. **Flutter not found**:
   - Ensure the setup job completes successfully
   - Check Flutter version compatibility

2. **Build failures**:
   - Check `flutter doctor` output
   - Verify Windows desktop support is enabled
   - Review test job output for errors

3. **Cache issues**:
   - Clear cache by updating `pubspec.lock`
   - Check cache key configuration

4. **Artifact upload failures**:
   - Verify artifact paths exist
   - Check file size limits (2GB per artifact)

### Debug Mode
For debugging workflow issues:
1. Enable debug logging in repository settings
2. Check job logs for detailed error messages
3. Use manual workflow dispatch for testing

## Security Notes

- Workflows run in isolated environments
- Secrets can be added in repository settings
- Artifacts are automatically cleaned up based on retention settings
- Manual workflows require repository access permissions

## Support

For issues with the workflow:
1. Check GitHub Actions documentation
2. Review Flutter Windows build requirements
3. Verify runner configuration
4. Check workflow logs for specific error messages

## File Structure

```
.github/
└── workflows/
    └── flutter-windows.yml    # Main workflow file
GITHUB_ACTIONS_README.md       # This documentation
```

## Related Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Windows Desktop](https://docs.flutter.dev/desktop)
- [Flutter Action](https://github.com/subosito/flutter-action)
- [Actions Cache](https://github.com/actions/cache) 