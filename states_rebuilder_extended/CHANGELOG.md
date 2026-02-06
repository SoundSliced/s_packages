## 1.0.3 - 2025-11-24

- updated `README.md`

## 1.0.2 - 2025-11-24

- updated `README.md` dependencies

## 1.0.1 - 2025-11-24

- exported `states_rebuilder` dependencies

## 1.0.0 - 2025-11-21

**Stable release**

This version promotes the previously published pre-release (`1.0.0-dev1`) to a stable build. The dependency constraint has been aligned to the latest stable `states_rebuilder: ^6.4.0` so that you can use the package without relying on a dev build of the underlying library.

### Added (from pre-release)
- ✅ **Type-safe updates** for nullable and non-nullable injected states
- ✅ **Boolean helpers** (`toggle()`) for nullable & non-nullable `Injected<bool>`
- ✅ **Multi-injected builders** (`builder`, `builderState`, `builderData`, `builderDataIndexed`)
- ✅ **Tag-based rebuilds** for selective widget notifications
- ✅ **Safe refresh** (`safeRefresh()`) ignoring disposed exceptions
- ✅ **Hot reload mixin** (`RebuildOnHotReloadMixin`) for Flutter Web
- ✅ **Injection helpers** (`InjectExtension`, `MyNull`) for concise creation
- ✅ **API documentation** for public members
- ✅ **Example app & README usage sections**
- ✅ **Initial test suite** covering core behaviors

### Changed
- Dependency: `states_rebuilder` now pinned to stable `^6.4.0`
- README updated to reflect stable release (removed pre-release wording)

### Fixed
- Documentation inconsistencies between example and main README

### Breaking Changes
None – first stable release.

---

## 1.0.0-dev1 - 2025-11-20

**First pre-release!**

*Note: This was a pre-release version depending on `states_rebuilder: ^7.0.0-dev1`.*

### Features
- ✅ **Type-safe updates**: Safer `update<T?>` and `update<T>` methods with explicit generic enforcement
- ✅ **Boolean helpers**: `toggle()` for both nullable and non-nullable `Injected<bool>`
- ✅ **Multi-injected builders**: Listen to multiple injected instances simultaneously
  - `builder()` - Simple builder without state
  - `builderState()` - Builder with access to SnapState
  - `builderData()` - Data builder handling waiting/error/data states
  - `builderDataIndexed()` - Indexed data builder for lists
- ✅ **Tag-based rebuilds**: Selective notification and rebuilding with tags
- ✅ **Safe refresh**: `safeRefresh()` to ignore disposed injector exceptions
- ✅ **Hot reload mixin**: `RebuildOnHotReloadMixin` for reliable Flutter Web hot reload
- ✅ **Injection helpers**: `InjectExtension` and `MyNull` for concise injector creation
- ✅ **Comprehensive documentation**: Full API documentation and examples
- ✅ **Complete test coverage**: Unit tests for all core functionality

### Documentation
- Added comprehensive README with usage examples
- Added working example app demonstrating all features
- Added API documentation comments to all public members

### Breaking Changes
None - this is the first stable release

## 0.0.1 - 2025-11-18

**Initial development release**

- Initial extraction of extensions and helpers from internal codebase
- Basic implementations of core features
- Experimental API (not stable)
