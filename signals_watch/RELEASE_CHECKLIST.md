# signals_watch Release Verification Checklist

Use this checklist every time before committing, tagging, and publishing a new version of the `signals_watch` package. This ensures all code, documentation, and metadata are correct and production-ready.

---

## 1. Version Consistency
- [x] `pubspec.yaml` version matches intended release
- [x] `README.md` install snippet uses correct version (ensure the API is correctly portrayed)
- [x] `PACKAGE_SUMMARY.md` version is up to date and summary updated with new API changes
- [x] `CHANGELOG.md` has a section for the new version and date

## 2. Documentation
- [x] `README.md` documents all new features and API changes
- [x] All code examples in `README.md` are updated and accurate as per latest version to be released
- [x] `PACKAGE_SUMMARY.md` reflects new features and correct version
- [x] Migration guides and usage examples are current
 - [x] Example app reflects all new features introduced in this release (computed, async, lifecycle callbacks, overrides, reset, shouldRebuild/shouldNotify, equals, error/loading builders, debug observer)
 - [x] Example app sections are updated or added to demonstrate new APIs and patterns

## 3. Code & Tests
- [x] All code changes are committed
- [x] All tests pass (`flutter test`)
- [x] No analyzer issues (`flutter analyze`)
- [x] Code is formatted (`dart format .`)
- [x] Example app runs without errors

## 4. Metadata & Safety
- [x] Homepage, repository, and issue tracker URLs in `pubspec.yaml` are correct
- [x] `.gitignore` blocks private keys and sensitive files
- [x] No sensitive files (e.g., SSH keys) are present or tracked by git

## 5. Publishing Preparation
- [x] Run `flutter pub get` in package root
- [x] Run `flutter pub publish --dry-run` and resolve any issues
- [x] Review all documentation for typos and outdated info

## 6. Commit & Tag
- [x] Commit all changes with a clear message (e.g., "Release v1.0.0")
- [x] Tag the commit with the version (e.g., `v1.0.0`)
- [x] Push commits and tags to GitHub

## 7. Publish
- [x] Run `dart pub publish` to publish to pub.dev

---

**Tip:** Run through this checklist with your AI assistant before every release for a smooth, error-free publish!
