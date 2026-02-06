## 1.0.1

This release focuses on documentation completeness, improved developer ergonomics, and exposing several utility extensions that were previously undocumented.

### Added / Documented
* JSON beautifier utilities (`beautifiedJson` on `Map` / `List<Map>`, and `decodeBeautifiedJsonMap` / `decodeBeautifiedJsonList` on `String`).
* Safe list accessor (`list.safe[index]`) to prevent out-of-range exceptions.
* Tuple‑based fluent `EdgeInsets` extensions: `(10, 20).leftPad.rightPad`, `(5,10,15).leftPad.topPad.rightPad`, `(5,10,15,20).leftPad.topPad.rightPad.bottomPad`.
* Fluent EdgeInsets / EdgeInsetsGeometry chaining & modification helpers (`addToLeft`, `leftPad`, etc.).
* TimeOfDay enhancements (serialization `toJson` / `fromJson`, rounding `toNearestMinute`, `roundDown`, arithmetic `addMinutes` / `subtractMinutes`, conversion helpers).
* BorderRadius fluent helpers (`8.allRad`, `12.topRad`, etc.).
* Iterable helper `findFirstWhereOrNull`.
* URI parsing extension (`"https://example.com".toUri`).

### Documentation & Examples
* Overhauled README with correct import path, updated dependency version, and comprehensive usage examples for Duration, DateTime, TimeOfDay, String, List, Color, EdgeInsets (including tuples & fluent builder), JSON beautifier, SafeListAccessor, BorderRadius.
* Added runnable example in `example/lib/main.dart`.
* Expanded test coverage (safe list accessor, JSON beautifier, TimeOfDay rounding & arithmetic, String capitalization, EdgeInsets tuple chaining).

### Misc
* General comment clean-up and consistency.
* Ensured MIT License header year and owner are present.

## 1.0.0

* Initial release
* Duration extensions with shortcuts (seconds, minutes, hours, days, weeks, months, years)
* DateTime utilities for conversion, formatting, and manipulation
* String extensions for parsing, formatting, and JSON utilities
* List extensions with safe access and chunking
* Color extensions for manipulation and hex conversion
* EdgeInsets extensions with fluent API
* TimeOfDay extensions with full feature support
* Offset, Map, ScrollController, and various utility extensions
* Comprehensive type conversion utilities
