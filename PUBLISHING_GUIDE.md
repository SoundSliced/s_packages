# S Packages - Publishing Guide

## Configuration Summary

Your `s_packages` monorepo is now configured to publish all 43 individual packages as a single package on pub.dev.

### What's Included

The package will include:
- ✅ **All 43 package source files** (lib/, test/, README.md, etc.)
- ✅ **Example applications** with source code
- ✅ **Documentation files** (README.md, CHANGELOG.md, LICENSE)
- ✅ **Analysis configuration** (analysis_options.yaml)

### What's Excluded (via `.pubignore`)

The following are automatically excluded from publication to keep the package light (< 4MB):
- ❌ **Heavy Assets**: `**/assets/` (images, videos), `**/*.gif`, `**/*.mp4`, `**/*.mov` (kept in Git/GitHub but excluded from package)
- ❌ **Build artifacts**: `**/build/`, `**/.dart_tool/`, `**/.packages`
- ❌ **Platform boilerplate**: Android/iOS/Web folders in examples
- ❌ **IDE files**: `**/.idea/`, `**/.vscode/`, `*.iml`
- ❌ **Generated files**: `**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`
- ❌ **Scripts & Tools**: `scripts/`, `*.sh`

## Publishing Steps

### 1. Test the Package

```bash
# Run analysis
flutter analyze

# Run tests  
flutter test

# Dry-run to see what will be published
flutter pub publish --dry-run
```

### 2. Check Package Size

The dry-run will show you:
- Total package size
- List of files being published
- Any warnings or validation issues

**Expected size**: Should be significantly smaller than 104 MB (the original monorepo size) because all build artifacts, examples' build folders, and IDE files are excluded.

### 3. Publish to pub.dev

When ready:

```bash
flutter pub publish
```

## Alternative: Publish Individual Packages

If the monorepo approach results in a package that's still too large, you can publish each package individually:

```bash
# Navigate to each package and publish
cd bubble_label && flutter pub publish
cd ../s_button && flutter pub publish
# ... repeat for all 43 packages
```

Then create `s_packages` as an umbrella package that depends on all of them.

## Testing After Publication

Add to a test project:

```yaml
dependencies:
  s_packages: ^1.0.0
```

Then import and use:

```dart
import 'package:s_button/s_button.dart';
import 'package:s_modal/s_modal.dart';
// ... etc
```

## Notes

- The `.pubignore` file uses wildcards (`**/`) to match patterns in any subdirectory
- This ensures build artifacts from all 43 packages are excluded
- Source code, documentation, and examples are preserved
- The `.gitignore` has also been updated to handle all sub-packages properly
