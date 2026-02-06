# Publishing Guide: GitHub & pub.dev

This guide covers the complete process of publishing a Dart/Flutter package to GitHub and pub.dev.

---

## Dynamic Variables

This guide uses dynamic variables to make it work for any package. Before running commands, set these variables:

```bash
# Extract package name from pubspec.yaml
PACKAGE_NAME=$(grep '^name:' pubspec.yaml | sed 's/name: //')

# Your GitHub username
USERNAME=SoundSliced

# Repository name (usually same as package name)
REPO=$PACKAGE_NAME

# Current directory (package root)
PACKAGE_DIR=$(pwd)

# Current version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
```

**Note**: Ensure you run commands from the package root directory (where `pubspec.yaml` is located).

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [GitHub Publishing](#github-publishing)
3. [pub.dev Publishing](#pubdev-publishing)
4. [Version Management](#version-management)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools
- Git installed and configured
- Dart SDK or Flutter SDK installed
- GitHub account
- Google account (for pub.dev)

### Package Requirements
- Valid `pubspec.yaml` with all required fields
- `README.md` file
- `CHANGELOG.md` file
- `LICENSE` file
- Example code in `example/` directory (recommended)
- Documentation in code (doc comments)

---

## GitHub Publishing

### Initial Setup

1. **Create a GitHub Repository**
   ```bash
   # Initialize git (if not already done)
   git init
   
   # Add all files
   git add .
   
   # Create initial commit
   git commit -m "Initial commit"
   ```

2. **Create Repository on GitHub**
   - Go to https://github.com/new
   - Create a new repository named `$REPO`
   - Don't initialize with README (you already have one)

3. **Link Local Repository to GitHub**
   ```bash
   # Add remote origin
   git remote add origin https://github.com/$USERNAME/$REPO.git
   
   # Push to GitHub
   git branch -M main
   git push -u origin main
   ```

### Updating GitHub Repository

```bash
# Make your changes
git add .
git commit -m "Descriptive commit message"
git push
```

### Creating Releases on GitHub

1. **Tag Your Version**
   ```bash
   # Get current version from pubspec.yaml
   VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
   
   # Create and push a tag
   git tag -a v$VERSION -m "Release version $VERSION"
   git push origin v$VERSION
   ```

2. **Create GitHub Release**
   - Go to your repository on GitHub: https://github.com/$USERNAME/$REPO
   - Click on "Releases" → "Create a new release"
   - Select the tag you just created
   - Add release notes (copy from CHANGELOG.md)
   - Publish release

---

## pub.dev Publishing

### Pre-Publishing Checklist

1. **Verify Package Structure**
   ```
   $PACKAGE_NAME/
   ├── lib/
   │   ├── $PACKAGE_NAME.dart
   │   └── src/
   ├── test/
   ├── example/
   ├── CHANGELOG.md
   ├── LICENSE
   ├── README.md
   ├── pubspec.yaml
   └── analysis_options.yaml
   ```

2. **Update `pubspec.yaml`**
   Ensure your `pubspec.yaml` includes the following required fields (with your actual values). Check your current file:

   ```bash
   cat pubspec.yaml
   ```

   Required fields:
   - `name`: $PACKAGE_NAME
   - `description`: A clear, concise description (60-180 characters)
   - `version`: $VERSION
   - `homepage`: https://github.com/$USERNAME/$REPO
   - `repository`: https://github.com/$USERNAME/$REPO
   - `issue_tracker`: https://github.com/$USERNAME/$REPO/issues
   - `environment`: sdk and flutter versions as appropriate
   - `dependencies`: Your runtime dependencies
   - `dev_dependencies`: Your development dependencies (testing, linting, etc.)

3. **Update `README.md`**
   Include:
   - Package description
   - Features
   - Installation instructions
   - Usage examples
   - API documentation link
   - Screenshots/GIFs (if UI package)
   - License information

4. **Update `CHANGELOG.md`**
   ```markdown
   ## 1.0.0
   
   * Initial release
   * Feature 1
   * Feature 2
   ```

5. **Update `LICENSE`**
   - Choose an appropriate license (MIT, BSD, Apache 2.0, etc.)
   - Most Flutter packages use MIT or BSD-3-Clause

### Dry Run (Test Before Publishing)

```bash
# Run package analysis
dart analyze
# or for Flutter packages
flutter analyze

# Run tests
dart test
# or for Flutter packages
flutter test

# Perform dry run (simulates publishing without actually publishing)
dart pub publish --dry-run
# or for Flutter packages
flutter pub publish --dry-run
```

**Check for:**
- No errors or warnings
- All files are included
- Package score suggestions
- Correct version number

### Publishing to pub.dev

1. **First-Time Setup**
   ```bash
   # This will authenticate with your Google account
   dart pub publish
   # or
   flutter pub publish
   ```

2. **Follow Authentication Steps**
   - A browser window will open
   - Sign in with your Google account
   - Grant permissions to pub.dev
   - Credentials will be saved locally

3. **Confirm Publishing**
   - Review the package contents
   - Type 'y' to confirm
   - Wait for upload to complete

4. **Verify Publication**
   - Visit https://pub.dev/packages/$PACKAGE_NAME
   - Check package page appears correctly
   - Verify documentation is generated

### Updating a Published Package

1. **Update Version Number**
   - Follow semantic versioning in `pubspec.yaml`
   - Update `CHANGELOG.md`

2. **Commit and Tag**
   ```bash
   # Get the updated version
   VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
   
   git add .
   git commit -m "Bump version to $VERSION"
   git tag -a v$VERSION -m "Version $VERSION"
   git push
   git push origin v$VERSION
   ```

3. **Publish Update**
   ```bash
   dart pub publish --dry-run  # Test first
   dart pub publish            # Actually publish
   ```

---

## Version Management

### Semantic Versioning (MAJOR.MINOR.PATCH)

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward compatible

### Pre-release Versions

```
1.0.0-dev.1    # Development version
1.0.0-alpha.1  # Alpha version
1.0.0-beta.1   # Beta version
1.0.0-rc.1     # Release candidate
```

### Version Update Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md` with changes
- [ ] Set VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
- [ ] Commit changes to git
- [ ] Create git tag v$VERSION
- [ ] Push to GitHub
- [ ] Publish to pub.dev
- [ ] Create GitHub release

---

## Best Practices

### Documentation

1. **Add Doc Comments**
   ```dart
   /// A brief description of the class/function.
   ///
   /// A more detailed explanation with examples:
   /// ```dart
   /// final example = MyClass();
   /// example.doSomething();
   /// ```
   class MyClass {
     /// Description of this method.
     void doSomething() {}
   }
   ```

2. **Include Examples**
   - Create comprehensive examples in `example/` directory
   - Include inline examples in doc comments
   - Add usage examples in README.md

### Testing

1. **Write Tests**
   ```bash
   # Create test files in test/ directory
   test/
   ├── widget_test.dart
   └── unit_test.dart
   ```

2. **Aim for Good Coverage**
   ```bash
   # Run tests with coverage
   flutter test --coverage
   
   # View coverage report
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

### Quality Assurance

1. **Use Linting**
   - Configure `analysis_options.yaml`
   - Use `flutter_lints` or `dart_lints`
   - Fix all warnings before publishing

2. **Check pub.dev Score**
   - After publishing, check your package score
   - Address suggestions to improve score
   - Aim for 130+ points

3. **API Design**
   - Keep APIs simple and intuitive
   - Avoid breaking changes when possible
   - Deprecate before removing features

### Repository Maintenance

1. **Keep README Updated**
   - Update installation instructions
   - Add new features to documentation
   - Include migration guides for breaking changes

2. **Maintain CHANGELOG**
   - Document all changes
   - Group by type (Features, Fixes, Breaking Changes)
   - Keep most recent version at top

3. **Respond to Issues**
   - Monitor GitHub issues
   - Respond to user questions
   - Fix reported bugs promptly

---

## Troubleshooting

### Common Issues

#### "Package validation failed"
```bash
# Check what's wrong
dart pub publish --dry-run

# Common fixes:
# - Update pubspec.yaml fields (description, homepage, etc.)
# - Add missing files (LICENSE, README.md, CHANGELOG.md)
# - Fix analysis errors
```

#### "Version already exists"
```bash
# You cannot republish the same version
# Update version in pubspec.yaml and try again
```

#### "Package name already taken"
```bash
# Choose a different package name
# Check availability: https://pub.dev/packages/your_package_name
# Consider prefixing with your username or organization
```

#### "Authentication failed"
```bash
# Remove cached credentials
rm -rf ~/.pub-cache/credentials.json

# Re-authenticate
dart pub publish
```

#### "Git not clean"
```bash
# Commit all changes before publishing
git status
git add .
git commit -m "Prepare for release"
```

### Getting Help

- **pub.dev Help**: https://dart.dev/tools/pub/publishing
- **GitHub Help**: https://docs.github.com/
- **Flutter Community**: https://flutter.dev/community
- **Dart Discord**: https://discord.gg/Bbumvej

---

## Quick Reference Commands

### GitHub
```bash
# Initial setup
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/$USERNAME/$REPO.git
git push -u origin main

# Updates
git add .
git commit -m "Description"
git push

# Tagging
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
git tag -a v$VERSION -m "Version $VERSION"
git push origin v$VERSION
```

### pub.dev
```bash
# Analysis and testing
dart analyze
dart test

# Publishing
dart pub publish --dry-run  # Test
dart pub publish            # Publish

# For Flutter packages
flutter analyze
flutter test
flutter pub publish --dry-run
flutter pub publish
```

---

## Example Workflow

```bash
# 1. Make changes to your package
# ... edit files ...

# 2. Update version and changelog
# Edit pubspec.yaml: version: 1.0.1
# Edit CHANGELOG.md: Add changes

# 3. Test everything
dart analyze
dart test
dart pub publish --dry-run

# 4. Get version and commit to git
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
git add .
git commit -m "Release v$VERSION: Bug fixes and improvements"
git tag -a v$VERSION -m "Version $VERSION"

# 5. Push to GitHub
git push
git push origin v$VERSION

# 6. Publish to pub.dev
dart pub publish

# 7. Create GitHub release (via web interface)
# Go to: https://github.com/$USERNAME/$REPO/releases/new
```

---

## Additional Resources

- [Dart Package Publishing](https://dart.dev/tools/pub/publishing)
- [Flutter Package Publishing](https://flutter.dev/docs/development/packages-and-plugins/developing-packages)
- [Semantic Versioning](https://semver.org/)
- [Writing Package Documentation](https://dart.dev/guides/libraries/writing-package-pages)
- [Package Layout Conventions](https://dart.dev/tools/pub/package-layout)

---

**Last Updated**: November 19, 2025
