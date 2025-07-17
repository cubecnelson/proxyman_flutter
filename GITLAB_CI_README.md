# GitLab CI/CD Pipeline for Flutter Windows Build

This directory contains a GitLab CI/CD pipeline configuration for building Flutter applications for Windows platform.

## Overview

The pipeline consists of the following stages:

1. **Setup** - Installs Flutter and configures the environment
2**Test** - Runs Flutter tests and code quality checks
3. **Build** - Builds the Flutter app for Windows
4ifacts** - Creates Windows installer (optional)

## Pipeline Jobs

### Setup Stage
- **setup_flutter**: Installs Flutter SDK, enables Windows desktop support, and fetches dependencies

### Test Stage
- **test**: Runs Flutter unit tests
- **lint**: Performs code analysis and formatting checks

### Build Stage
- **build_windows**: Builds the Flutter app for Windows in release mode
- **build_windows_debug**: Builds the Flutter app for Windows in debug mode (manual trigger)

### Artifacts Stage
- **create_installer**: Creates Windows installer using Wine (manual trigger, requires additional setup)

## Usage

### Automatic Triggers
The pipeline automatically runs on:
- `main` branch
- `develop` branch
- Merge requests

### Manual Triggers
Some jobs require manual triggering:
- `build_windows_debug`: For debug builds
- `create_installer`: For creating Windows installers

### Artifacts
The pipeline produces the following artifacts:
- **Release build**: `build/windows/runner/Release/` (expires in1k)
- **Debug build**: `build/windows/runner/Debug/` (expires in 1 day)
- **Installer**: `build/windows/installer/` (expires in 1 month)

## Configuration

### Variables
- `FLUTTER_VERSION`: Flutter SDK version (default:3245)
- `FLUTTER_CHANNEL`: Flutter channel (default: stable)
- `FLUTTER_HOME`: Path to Flutter installation

### Cache
The pipeline caches:
- Flutter SDK (`.flutter/`)
- Pub dependencies (`.pub-cache/`)
- Build artifacts (`build/`)
- Dart tool cache (`.dart_tool/`)

## Requirements

### GitLab Runner
- Ubuntu 22.04r later
- At least 4GB RAM
- 10GB free disk space

### Dependencies
The pipeline automatically installs:
- curl, git, unzip, xz-utils, zip
- libglu1for OpenGL support)
- Wine (for installer creation)

## Customization

### Adding Custom Build Steps
You can add custom build steps by modifying the `script` section of any job:

```yaml
script:
  - flutter build windows --release
  - # Add your custom commands here
  - echo Custom build step completed"
```

### Environment Variables
Add custom environment variables in the `variables` section:

```yaml
variables:
  FLUTTER_VERSION: 3.245
  FLUTTER_CHANNEL: stable"
  FLUTTER_HOME: $CI_PROJECT_DIR/.flutter  PATH: $FLUTTER_HOME/bin:$PATH"
  CUSTOM_VAR: "value"
```

### Conditional Execution
Jobs can be configured to run only on specific conditions:

```yaml
only:
  - main
  - develop
  - merge_requests
  - tags
```

## Troubleshooting

### Common Issues1*Flutter not found**: Ensure the `setup_flutter` job completes successfully
2. **Build failures**: Check Flutter doctor output for missing dependencies3 **Cache issues**: Clear the pipeline cache if dependency issues occur

### Debug Mode
For debugging pipeline issues:
1. Enable debug logging in GitLab CI/CD settings2Check job logs for detailed error messages3. Use the `build_windows_debug` job for development builds

## Security Notes

- The pipeline runs in a controlled environment
- Dependencies are cached to improve build speed
- Artifacts are automatically cleaned up based on expiration settings
- Manual jobs require explicit approval

## Support

For issues with the pipeline:
1. Check the GitLab CI/CD documentation2ew Flutter Windows build requirements
3. Verify GitLab Runner configuration 