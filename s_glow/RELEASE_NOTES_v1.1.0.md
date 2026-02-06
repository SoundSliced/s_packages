# Release Notes - v1.1.0

## Package Readiness Summary

All requirements for version 1.1.0 have been completed:

### ✅ Documentation Updates

1. **CHANGELOG.md**
   - Updated with detailed v1.1.0 changes
   - Breaking changes clearly documented
   - All new features and improvements listed

2. **README.md**
   - Added visual examples section with GIF links from GitHub
   - Updated API documentation with new `startInsetFactor` parameter
   - Added "What's New in v1.1.0" section
   - Updated code examples to demonstrate new features
   - All examples reflect current API

3. **example/README.md**
   - Updated to reflect v1.1.0 features
   - Documented interactive slider for `glowRadiusFactor`
   - Noted side-by-side layout improvements
   - Mentioned GIF assets

4. **test/README.md**
   - Updated test coverage documentation
   - Added v1.1.0-specific test coverage notes
   - Documented new parameter testing

### ✅ License

- MIT License file exists and is properly formatted
- Copyright 2025 SoundSliced

### ✅ Examples

- Example app updated with interactive slider for `glowRadiusFactor`
- Side-by-side layout showing Glow1 and Glow2 comparisons
- All examples demonstrate current API features
- Visual assets (GIF files) included in `example/assets/`

### ✅ Tests

- All 29 tests passing
- Test coverage includes:
  - glow1_test.dart (16 tests)
  - glow2_test.dart (16 tests)  
  - s_glow_test.dart (package-level tests)
- Tests cover new v1.1.0 features

### ✅ Visual Assets

- **example/assets/glow1.gif** - Breathing effect demonstration
- **example/assets/glow2.gif** - Ripple effect demonstration
- README.md references these via GitHub URLs for pub.dev display

## Key Changes in v1.1.0

### Breaking Changes
- Removed `glowRectFactor` parameter (consolidated into `glowRadiusFactor`)

### New Features
- Added `startInsetFactor` parameter (controls where glow animation begins)
- Shape-aware expansion for rectangles (uses half-width/half-height)
- Animation now starts at 0.1 instead of 0.0 for smoother appearance

### Improvements
- Better proportional expansion for rectangular shapes
- More accurate size calculations using child's actual dimensions
- Enhanced example app with real-time interactive controls

## Ready for Publishing

The package is ready to be published to pub.dev with:
- Version number: 1.1.0
- Complete documentation
- Visual examples
- Comprehensive tests
- MIT License
- Updated examples

## Next Steps

To publish:
```bash
flutter pub publish --dry-run  # Verify package
flutter pub publish            # Publish to pub.dev
```
