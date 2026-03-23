
## 3.5.1
- **`s_dropdown` clear-button visibility fix:**
  - The inline clear button now appears only when a real selection is present, including the initial selected item and any user-selected item.
  - The clear button stays hidden when the dropdown is showing only the hint state, preventing a no-op clear affordance.
  - Added a regression test covering the hint-only state to keep the suffix area behavior stable.


## 3.5.0
- **`s_dropdown` clear-selection upgrade:**
  - Added a controller API to clear the current selection programmatically, with support for either restoring the initial item or clearing all the way back to the hint state.
  - Added an inline clear suffix button powered by `SInkButton`, so the current selection can be cleared directly from the dropdown header.
  - Preserved overlay-open and overlay-closed behavior so clearing works consistently in both states.
  - Added focused tests and example updates covering both clear-to-initial and clear-to-hint flows.

- **`s_metar` live fetch flexibility upgrade:**
  - Added configurable fetch options for alternate METAR/TAF endpoints.
  - Added custom success-code handling for non-standard API responses.
  - Added configurable JSON field mapping and item extraction so raw METAR/TAF strings can be read from different response shapes.
  - Added a proxy toggle so callers can disable proxy attachment entirely when talking directly to an API.
  - Added focused tests covering custom parsing and direct-only fetch behavior.


## 3.4.0
- **`s_ink_button` hover feedback improvement:**
  - Active `SInkButton` widgets now show the click cursor on web/desktop hover, giving clearer visual feedback that the widget is interactive.
  - Disabled `SInkButton` widgets keep the basic cursor so non-interactive states remain visually distinct.

## 3.3.1
- **`pop_overlay` interaction and layout refinements:**
  - Added optional `TapRegion` integration to `PopOverlayContent` (`tapRegionGroupId`, `onTapRegionOutside`, `onTapRegionInside`, `tapRegionBehavior`, `tapRegionConsumeOutsideTaps`) so overlay content can participate in grouped inside/outside tap handling.
  - Updated the overlay activator to inherit the surrounding app theme, scroll behavior, and text direction instead of spinning up a nested `MaterialApp`, improving integration inside host applications.
  - Improved dismissal safety by ensuring delayed removals only dispose the exact overlay instance that started exiting, preventing stale dismiss timers from removing a newer overlay that reused the same ID.
  - Improved framed popup sizing with responsive width/height resolution, maximum viewport constraints, and better handling of fractional dimensions for web and constrained layouts.
  - Improved drag lifecycle tracking so drag state is reset consistently on drag start/end/cancel for both popup bodies and draggable headers.
  - Fixed auto-dismiss behavior to trigger `onDismissed` correctly when overlays are made invisible on dismiss.

## 3.3.0
- **`pop_overlay` stack layering upgrade:**
  - Added `stackLevel` to `PopOverlayContent` with default `PopOverlayStackLevels.overlay`.
  - Added stack APIs: `getStackLevel`, `setStackLevel`, `bringToFront`, `sendToBack`, and `activeIdsByStackOrder`.
  - Added stack constants helpers: `PopOverlayStackLevels` and `PopOverlayStackLevelBands`.
  - Replaced hard-coded priority-only ordering with stable effective-level sorting while preserving legacy priority bonuses for known critical overlays.
  - Improved reactivation/update flow for invisible overlays when `offsetToPopFrom` or `stackLevel` changes, including proper replacement cleanup.

- **`s_modal` stack layering and runtime robustness improvements:**
  - Added `stackLevel` support across modal creation/update paths (`ModalBuilder`, `Modal.show`, `Modal.showSnackbar`, `Modal.updateParams`).
  - Added stack-level constants and guidance: `ModalStackLevels`, `ModalStackLevelBands`.
  - Added modal stack APIs: `activeIdsByStackOrder`, `topMostActiveId`, `getStackLevel`, `setStackLevel`, `bringToFront`, and `sendToBack`.
  - Added viewport-aware sizing helpers (`_ModalViewportScope`, `_modalViewportSizeOf`) to better handle framed/responsive layouts and swipe thresholds.
  - Improved dismiss-all scheduling safety by deferring only during frame-critical scheduler phases and preventing duplicate deferred callbacks.
  - Improved snackbar visuals and consistency (entrance timing/barrier fade synchronization, viewport-based gesture calculations).

- **Testing:**
  - Added `test/overlay_stack_ordering_test.dart` covering overlay stack ordering helpers and modal stack smoke checks.

## 3.2.0
- **`s_sidebar` sub-package bug fix:**
  - Fixed issue where `SSideBarItem.onTap` callback was incorrectly triggered during long presses.
  - Replaced `InkWell` with `SInkButton` which uses `onTapUp` internally, ensuring the callback only fires on completed taps.
  - This cleaner solution eliminates the need for wrapper widgets while preserving all visual effects and providing correct tap position data.

## 3.1.0
- **`s_ink_button` splash animation enhancement:**
  - Updated splash rendering to a radial-gradient style so the splash is no longer a flat filled circle.
  - Added a soft fade in the splash interior (center) for a cleaner ink effect.
  - Added a smooth fade on the outer splash edge (border) for more natural ripple falloff.
  - **Affected sub-packages using `SInkButton`:** `pop_overlay`, `s_button`, `s_expendable_menu`, `s_modal`, `s_time`, `week_calendar`.

## 3.0.2
- **`s_webview` proxy HTML normalization refactor:**
  - Extracted new `SWebViewProxyHtmlUtils` utility class (`_proxy_html_utils.dart`) to centralize proxy response handling.
  - `normalizeProxyHtml()` — unwraps known JSON envelopes (e.g. allorigins `{ contents: ... }`), decodes HTML entities (including doubly-escaped payloads like `&amp;lt;html...`), strips wrapping quotes, and handles URL-encoded HTML.
  - `injectBaseTagIfMissing()` — safely injects `<base href="...">` into the `<head>` (or prepends it) when none is present, with proper fragment stripping from the base URL.
  - `looksLikeHtml()` — best-effort HTML-detection heuristic.
  - Refactored `_SWebViewState` to use `SWebViewProxyHtmlUtils` instead of inline proxy response / base-tag injection logic.
  - Added unit tests for `SWebViewProxyHtmlUtils` (JSON envelope unwrap, double-entity decoding, base tag injection/deduplication).

- **Example app updates:**
  - Expanded webview example screen with many more test-URL buttons in a horizontally scrollable row.
  - Added basic widget test (`example/test/widget_test.dart`).

## 3.0.1
- **`s_webview` fix:** restored `webview_flutter_web` dependency that was accidentally removed in 3.0.0, causing URL loading to fail on web platform (no web platform backend registered).

## 3.0.0
- **Dependency unbloat (BREAKING):** removed convenience-only third-party dependencies that were not required by core `s_packages` widgets/controllers.
  - Removed from `dependencies`: `overlay_support`, `email_validator`, `regexed_validator`, `strings`, `cryptography`, `roundcheckbox`, `swipeable_tile`, `toastification`, `sync_scroll_controller`, `animated_list_plus`, `google_fonts`, `simple_animations`.
- **API surface cleanup (BREAKING):** `s_packages.dart` no longer exports `s_packages_extra1.dart` by default.
- **Legacy convenience barrels slimmed:** `s_packages_extra1.dart` and `s_packages_extra2.dart` now expose only lightweight/foundational exports and are no longer intended as "install-everything" shortcuts.
- **Migration note:** apps needing removed third-party packages should add them directly in their own `pubspec.yaml`.

## 2.1.1
- **`s_modal` sub-package improvements**:
  - **Removed idempotent guard in `Modal.appBuilder()`**: Previously, calling `appBuilder` more than once (e.g. during hot reload) would skip reinstallation to avoid double-nesting `_ActivatorWidget`. This guard has been removed so that `appBuilder` always installs a fresh activator widget, fixing cases where hot reload could leave the modal system in a stale state.
  - **Code formatting**: Applied Dart formatter across the file for consistency.

## 2.1.0
- **`s_modal` sub-package improvements**:
  - **Synchronized Barrier & Modal Dismissal**: The background barrier now fades out in perfect sync with the modal content (Dialogs, BottomSheets, Snackbars). No more lingering barriers or premature disappearances.
  - **Snappier Animations**: Reduced exit animation durations from ~300-400ms to **200ms** for a faster, more responsive UI feel.
  - **Cleanup & Fixes**:
    - Fixed an issue where the snackbar barrier was not fading out correctly.
    - Updated internal logic to wait exactly for the animation duration (200ms) before disposing of the modal controller, preventing race conditions or UI lag.

## 2.0.0
- **`pop_overlay` sub-package improvements**:
  - Improved overlay bootstrap resolution to prefer the nearest overlay context before falling back to the root overlay.
  - Fixed popup positioning for framed/scaled layouts (notably web) by keeping overlays in the same coordinate space as the caller.

- **`s_offstage` sub-package improvements**:
  - Removed the internal `Sizer` wrapper from `SOffstage` to avoid forcing an extra layout context around the widget tree.
  - Improved scale-only transitions: hidden state now scales to `0.0` (instead of `0.97`) for a cleaner and fully smooth disappearance at animation end.
  - Updated inline documentation examples to use `SOffstage` naming consistently.

- **Example app update**:
  - `ForcePhoneSizeOnWeb` now uses an explicit size (`2048 x 2732`) in `example/lib/main.dart` for improved demo consistency.

- **Package metadata**:
  - Bumped package version to `2.0.0` and updated README installation snippet accordingly.

## 1.9.0
- **`s_webview` major upgrade**:
  - Added typed config API with `SWebViewConfig` (auto restriction detection, proxy list fallback, host-based cache option, cache TTL, known restricted domains).
  - Added external controller injection support via `SWebView(controller: ...)` with safe ownership/disposal behavior.
  - Added richer callbacks: `onProgress`, `onPageStarted`, `onPageFinished`, `onUrlChanged`, `onNavigationRequest`, `onJavaScriptMessage`.
  - Added navigation decision model (`SWebViewNavigationDecision`) and callback type (`SWebViewNavigationRequestCallback`) to allow/prevent navigation.
  - Added platform capability model (`SWebViewPlatformCapabilities`) on controller.

- **`s_webview` behavior and reliability improvements**:
  - Removed hardcoded navigation blocking and replaced it with callback-driven policy.
  - Upgraded JS result handling to use `runJavaScriptReturningResult(...)` for title/cookies/search metadata paths.
  - Reworked web proxy cache with persisted timestamped entries, TTL validation, stale entry invalidation, and backward compatibility for old bool cache format.
  - Improved restriction detection using known-domain checks plus header/content hints (`X-Frame-Options`, CSP `frame-ancestors`, body hints).
  - Added idempotent/concurrency-safe controller initialization to prevent repeated-init crashes (including `LateInitializationError` on reused controllers).
  - Updated controller navigation helpers to use unified `loadUri(...)` flow and aligned desktop support documentation.

- **`s_webview` API cleanup and internals**:
  - Exported advanced controller extensions from `webview_controller.dart`.
  - Removed duplicate legacy file `webview_controller_clean.dart`.
  - Added shared internal debug logger `_debug_log.dart` and routed platform/desktop logs through it.
  - Added optional pointer-event blocking overlay support to internal WebView widget (`ignorePointerEvents`).

- **Example app updates (`s_webview_example_screen`)**:
  - Updated demo to showcase injected controller, typed config, progress/url callbacks, JS message callback, and navigation decision policy toggle.
  - Added richer live UI state (progress bar, last seen URL, policy feedback, JS message panel).

## 1.8.1
- CHANGELOG and README updated

## 1.8.0
- **`soundsliced_dart_extensions` new utilities added:**
  - **Iterable/List helpers:** `none`, `countWhere`, `singleWhereOrNull`, `distinctBy`, `sortedBy`, `chunked`, `windowed`, `firstWhereOrNull`, `lastWhereOrNull`, `firstOrNull`, `lastOrNull`, `elementAtOrNull`.
  - **Map helpers:** `mapKeys`, `mapValues`, `filterKeys`, `filterValues`, plus typed accessors `getString`, `getIntOrNull`, `getDoubleOrNull`, `getBoolOrNull`.
  - **String helpers:** `isBlank`, `ifBlank`, `toIntOrNull`, `toDoubleOrNull`, `toTitleCase`, `removeDiacritics`.
  - **Duration helpers:** `formatCompactDuration()` and `toClockString()`.
  - **Date/num helpers:** `DateTime.clampTo(...)`, `num?.clampOrNull(...)`, and `num?.clampToDoubleOrNull(...)`.
  - Marked legacy `MyStringExtension.convertStringIntoStringList()` as deprecated in favor of `StringExtensions.convertToListString()` and the top-level helper.

- **`soundsliced_dart_extensions` extension deduplication (BREAKING):**
  - Removed overlapping extensions already provided by exported `nb_utils` to prevent ambiguous extension resolution.
  - Removed `DateTime` members from this subpackage: `isToday`, `isYesterday`, `isTomorrow`, `isSameDay`, `startOfDay`, `endOfDay`.
  - Removed overlapping `String` members from this subpackage: `toCamelCase`, `toSnakeCase`.
  - Removed overlapping `int` duration members from this subpackage: `seconds`, `minutes`, `hours`, `microseconds`.
  - **Migration guidance:**
    - Use `nb_utils` equivalents for removed overlapping APIs (available transitively via `s_packages`).
    - For `int` durations, prefer retained short-hands from this subpackage where desired: `sec`, `min`, `hr`, `micSec`.

- **`s_packages` export changes:**
  - Exported `nb_utils` directly from `s_packages.dart`.
  - Removed duplicate `nb_utils` export from `s_packages_extra1.dart`.

## 1.7.2

- **`s_metar` sub-package improvements**:
  - **NEW: Live METAR/TAF fetching**:
    - Added `MetarTafFetcher` class for fetching live weather data from aviationweather.gov API
    - Added `MetarTafResult` class for typed fetch results with parsed `Metar`/`Taf` objects and raw data
    - ICAO code validation: ensures 4-character codes (first char letter, rest alphanumeric) via `isValidIcao()`
    - DateTime validation: rejects future dates and returns descriptive error
    - Integration with `s_client` API for HTTP requests with automatic retry and error handling
  - **CORS proxy support for web builds**:
    - `proxyUrls` static list for configurable proxy URLs (default: two Cloudflare Workers for redundancy)
    - `customProxyUrls` parameter on `fetch()` for per-request proxy override
    - Automatic proxy fallback: tries each proxy in order, switches on rate limit (429/503 status codes)
    - Direct API fallback when all proxies fail
  - **Deployment resources**:
    - Cloudflare Worker implementation in `lib/s_metar/deployment/cloudflare-worker.js`
    - Vercel Edge Function implementation in `lib/s_metar/deployment/vercel-edge-function.js`
    - Comprehensive deployment guide in `lib/s_metar/deployment/README.md`
    - Usage examples in `lib/s_metar/deployment/USAGE_EXAMPLES.dart`
  - **Example app integration**:
    - Added interactive `s_metar` example screen with 3-tab interface:
      - METAR tab: preset samples (EGLL, KJFK, Winter, CAVOK) + custom input with live parsing
      - TAF tab: editable TAF code with live parsing
      - Live Fetch tab: ICAO input, date/time picker, and real-time API fetching
    - Expandable cards showing parsed weather data (wind, visibility, clouds, temperatures, pressure)
    - Registered in package examples registry under "Networking" category

## 1.7.1
- **`s_metar` bug fixes**:
  - Fixed `toString()` in `Distance`, `Pressure`, `Temperature` (base), `MetarTrendIndicator`, and `TafTemperature` — `${super}` in string interpolation was invoking `Object.toString()` on the superclass proxy, returning the runtime type string (e.g. `"Instance of 'Numeric'"`) instead of the formatted value; changed to `${super.toString()}` throughout

## 1.7.0
- **NEW `s_metar` sub-package added**:
  - **METAR parsing**: Full support for aviation routine weather reports with `Metar(String code)` constructor
  - **TAF parsing**: Terminal Aerodrome Forecast support with `Taf(String code)` constructor
  - **Wind data**:
    - Speed in multiple units: knots, m/s, km/h, mph via `speedInKnot`, `speedInMps`, `speedInKph`, `speedInMiph`
    - Gust speed in same units via `gustInKnot`, `gustInMps`, `gustInKph`, `gustInMiph`
    - Direction in degrees and cardinal direction (N, NE, E, etc.)
    - Wind variation range (from/to degrees)
    - Beaufort scale number (0-12) and description via `beaufort` and `beaufortDescription`
    - `isCalm` boolean flag for calm wind conditions (00000KT)
  - **Visibility**:
    - Prevailing and minimum visibility in meters, kilometers, sea miles, and feet
    - `isMaximum` flag for visibility ≥10 km
    - CAVOK detection
  - **Weather phenomena**:
    - Intensity, descriptor, precipitation, obscuration, and other phenomena
    - `precipitationCodes` list for compound weather (e.g., RASN → ['RA', 'SN'])
    - Recent weather parsing
  - **Cloud layers**:
    - Cover amount with ICAO code (`coverCode`: FEW/SCT/BKN/OVC/NSC) and translation
    - Height in feet, meters, and kilometers
    - Cloud type codes (CB, TCU) with `cloudTypeCode` and `cloudType`
    - Oktas (eighths of sky coverage)
    - `ceiling` property (true when ≤1500 ft and BKN/OVC)
  - **Temperature data**:
    - Temperature and dewpoint in Celsius, Fahrenheit, Kelvin, and Rankine
    - Derived meteorological quantities:
      - `relativeHumidity` percentage
      - `dewpointSpread` in °C
      - `heatIndex` in °C (valid when temp ≥27°C and RH ≥40%)
      - `windChill(double? windSpeedKph)` in °C (valid when temp ≤10°C and wind ≥4.8 km/h)
  - **Pressure**:
    - Support for 7 units: hPa, inHg, mbar, Pa, kPa, bar, atm via `inHPa`, `inInHg`, `inMbar`, `inPa`, `inKPa`, `inBar`, `inAtm`
  - **Flight rules**: Automatic VFR/MVFR/IFR/LIFR/VLIFR classification via `flightRules` property
  - **CAVOK validation**: `shouldBeCavok()` method checks if conditions meet CAVOK criteria
  - **Additional METAR fields**: Runway visual range (RVR), windshear, sea state, runway state, weather trends (TEMPO/BECMG)
  - **TAF features**: Valid period, change indicators (FM/TEMPO/BECMG/PROB), max/min temperature forecasts, change period details
  - **Serialization**: `asMap()` method for JSON-serializable output
  - **GroupList utilities**: `asList()` method for converting group lists (clouds, weather, etc.) to `List<Map<String, Object?>>`
  - **Flexible parsing**: Optional `year` and `month` parameters for accurate timestamp resolution, `truncate` option for remark handling
  - **Unparsed groups tracking**: `unparsedGroups` property lists any METAR/TAF groups that weren't recognized


## 1.6.0
- **`s_screenshot` sub-package performance improvements**:
  - Fixed `ui.Image` memory leak — native GPU resources are now properly disposed after byte extraction
  - Base64 encoding is now offloaded to a separate isolate via `compute()` on native platforms to avoid blocking the UI thread (falls back to main thread on web where isolates aren't available)
  - Replaced `Future.microtask(() {})` with `WidgetsBinding.instance.endOfFrame` for more reliable rendering pipeline synchronization
  - Fixed `ByteData` buffer view to use precise `offsetInBytes`/`lengthInBytes` instead of unbounded `asUint8List()`
  - Added `_chunkedBase64Encode()` method for chunked base64 encoding on web — processes in 192KB chunks with event loop yields to keep animations running

## 1.5.3
- **`s_client` sub-package improvements**:
  - Stripped Dio `BaseOptions` down to only `baseUrl` and `validateStatus` — all other configuration (`connectTimeout`, `receiveTimeout`, `sendTimeout`, `headers`, `followRedirects`, `maxRedirects`) is now applied per-request via `dio.Options`, avoiding web-specific XHR issues (e.g. `connectTimeout` setting `xhr.timeout`, default `Content-Type` triggering CORS preflights)
  - `connectTimeout` and `sendTimeout` are now forwarded to every `_perform*` method (GET, POST, PUT, PATCH, DELETE, HEAD, download, downloadToFile, uploadFile) — previously only `receiveTimeout` was passed through
  - Explicitly forwarded `Content-Type` from request headers to `dio.Options.contentType` in POST, PUT, and PATCH — ensures Dio's request transformer uses the correct encoder (e.g. form-urlencoded vs JSON) regardless of `BaseOptions` defaults
  - Changed `ClientConfig.connectTimeout`, `receiveTimeout`, and `sendTimeout` defaults from `Duration(seconds: 30)` to `null` (no timeout)
  - Added `_withTimeout<T>()` helper — applies `.timeout()` only when the duration is non-null, replacing all inline `.timeout()` calls on `http` package requests
  - Applied `maxRedirects` guard (`config.followRedirects ? config.maxRedirects : null`) consistently to PATCH, DELETE, HEAD, download, downloadToFile, and uploadFile — these methods were previously passing `config.maxRedirects` unconditionally

## 1.5.2
- **`s_client` sub-package improvements**:
  - Added `autoRedirectStatusCodes` parameter to `put()`, `putJson()`, and `_performPut()` — enables manual redirect handling for PUT, POST requests, automatically following the `Location` header with a GET request when the response status code matches (consistent with existing POST redirect behavior)
  - Fixed `maxRedirects` guard in `_performPut()` — now only set when `followRedirects` is enabled (matching POST behavior)

## 1.5.1
- **`s_client` sub-package fixes**:
  - Fixed Dio redirect option handling by only setting `maxRedirects` when `followRedirects` is enabled
  - Applied this fix consistently to base Dio options and per-request Dio options in GET and POST flows

## 1.5.0
- **`s_client` sub-package improvements**:
  - Added `validateStatus` parameter (`bool Function(int?)?`) to all HTTP methods (`get`, `getJson`, `getJsonList`, `post`, `postJson`, `put`, `putJson`, `patch`, `patchJson`, `delete`, `deleteJson`, `head`, `download`, `downloadToFile`, `uploadFile`) — allows per-request control over which status codes are treated as valid
  - Fixed Dio request options: `followRedirects`, `maxRedirects`, and `validateStatus` are now correctly forwarded to all `_perform*` methods — previously only `receiveTimeout` and `headers` were passed through
  - flutter/Dart SDKs updated

## 1.4.2
- **`s_modal` sub-package improvements**:
  — Added `_appBuilderInstalled = false` in both `disposeActivator()` and `_ActivatorWidgetState.dispose()`. Without this, after the first test tears down its widget tree, subsequent tests' `Modal.appBuilder` calls skip creating the `_ActivatorWidget`, so modals never render.

## 1.4.1
- **`s_connectivity` sub-package BREAKING improvements**:
  - **BREAKING:** Renamed `AppInternetConnectivity` class to `SConnectivity` — all call sites must be updated (e.g. `AppInternetConnectivity.listenable` → `SConnectivity.listenable`)
  - **BREAKING:** Renamed source file from `s_connection.dart` to `s_connectivity.dart` — direct imports must be updated
  - Made `toggleConnectivitySnackbar()` private (`_toggleConnectivitySnackbar`) — use the `showNoInternetSnackbar` setter instead for manual snackbar control


## 1.4.0
- **`s_modal` sub-package improvements**:
  - Added `Modal.isAppBuilderInstalled` public getter — allows other packages to check whether `Modal.appBuilder` has already been installed in the widget tree
  - Made `Modal.appBuilder` idempotent — calling it more than once now safely returns the child as-is instead of double-nesting the internal `_ActivatorWidget`
- **`s_connectivity` sub-package improvements**:
  - Added `SConnectivityOverlay` widget — a convenience wrapper that sets up the Modal overlay system so the "No Internet" snackbar works without requiring users to know about or manually call `Modal.appBuilder`
  - Added `SConnectivityOverlay.appBuilder` static method — drop-in replacement for `Modal.appBuilder` that can be passed directly to `MaterialApp(builder: ...)`
  - Safe to use alongside an existing `Modal.appBuilder` call — double-wrapping is prevented automatically thanks to the idempotent `appBuilder`

## 1.3.0
- **`pop_overlay` sub-package improvements**:
  - `PopOverlay.dismissAllPops` added with optional `includeInvisible` and `except` parameters
  - `PopOverlay.replacePop` for atomically replacing an overlay with a new one
  - Added query helpers: `isVisibleById`, `getVisiblePops`, `getInvisiblePops`, `visibleCount`, `invisibleCount`
  - Added `shouldDismissOnEscapeKey` flag on `PopOverlayContent` to opt out of Escape key dismissal per overlay
  - Added `onMadeVisible` callback on `PopOverlayContent` (counterpart to `onMadeInvisible`)
  - Added `onDragStart` and `onDragEnd` callbacks on `PopOverlayContent`
  - Added `dragBounds` on `PopOverlayContent` to constrain dragging within a `Rect`
  - **`FrameDesign` additions**:
    - `subtitle` property for secondary text below the title
    - `titleBarColor` and `bottomBarColor` for per-popup color customization
    - `headerTrailingWidgets` for extra action widgets in the header
- **`bubble_label` sub-package improvements**:
  - Added `animationDuration` for custom show/dismiss timing
  - Added `showCurve` and `dismissCurve` for independent animation curves
  - Added `horizontalOffset` for horizontal positioning control
  - Added `showOnHover` flag to trigger label display on mouse hover
- **`s_bounceable` sub-package improvements**:
  - Added `onLongPress` callback
  - Added `curve` for custom bounce animation curve
  - Added `enableHapticFeedback` flag for tactile feedback on tap
- **`s_disabled` sub-package improvements**:
  - Added `applyGrayscale` flag to apply a grayscale filter when disabled
  - Added `disabledSemanticLabel` for custom accessibility label when disabled
  - Added `disabledChild` to show an alternative widget when disabled
- **`s_banner` sub-package improvements**:
  - Added `onTap` callback
  - Added `gradient` for gradient background support
  - Added `animateVisibility` to animate show/hide transitions
- **`s_glow` sub-package improvements**:
  - Added `onAnimationComplete` callback to Glow1 and Glow2
  - Added `gradient` support for multi-color glow effects in Glow1
- **`shaker` sub-package improvements**:
  - Added `ShakeController` for programmatic shake triggering via `controller.shake()`
- **`s_maintenance_button` sub-package improvements**:
  - Added `icon` for custom button icon
  - Added `showConfirmation` flag and `confirmationMessage` for confirmation dialog before action
- **`s_ink_button` sub-package improvements**:
  - Added `onHover` and `onFocusChange` callbacks
  - Added `hoverColor` for custom hover state color
  - Added `splashDuration` for custom splash animation timing
- **`settings_item` sub-package improvements**:
  - Added `subtitle`, `description`, and `trailing` to `ExpandableParameters`
  - Updated `copyWith`, `==`, and `hashCode` accordingly
- **`s_error_widget` sub-package improvements**:
  - Converted to `StatefulWidget` for expandable stack trace state
  - Added `errorCode`, `stackTrace` (expandable monospace view), `showCopyButton`, and `actions`
  - Copy button copies full error details to clipboard
- **`keystroke_listener` sub-package improvements**:
  - Added `actionHandlers` map for customizable intent callbacks per intent type
- **`s_context_menu` sub-package improvements**:
  - Added `disabled` and `shortcutHint` fields to `SContextMenuItem`
  - Disabled items render at reduced opacity with forbidden cursor
  - Shortcut hints display as right-aligned secondary text in menu items
- **`s_animated_tabs` sub-package improvements**:
  - Added `tabIcons` list for optional per-tab icons
  - Added `tabBadges` list for optional per-tab badge pills
- **`s_expendable_menu` sub-package improvements**:
  - Added `onExpansionChanged` callback to `SExpandableMenu`
  - Added `tooltip` and `disabled` fields to `SExpandableItem`
  - Disabled items render at reduced opacity with null tap handler
- **`s_future_button` sub-package improvements**:
  - Added `successDuration` and `errorDuration` for configurable state display timing
  - Added `loadingWidget` for custom loading indicator replacement
- **`s_gridview` sub-package improvements**:
  - Added `emptyStateWidget` to display when children list is empty
- **`ticker_free_circular_progress_indicator` sub-package improvements**:
  - Added `size` parameter (replaces hardcoded 36.0 diameter)
- **`soundsliced_tween_animation_builder` sub-package improvements**:
  - Added `delay` for pre-animation delay
  - Added `repeatCount` to limit number of auto-repeat cycles
- **`week_calendar` sub-package improvements**:
  - Added `minDate` and `maxDate` for date boundary constraints
  - Added `eventIndicatorDates` and `eventIndicatorColor` for event dot indicators on days
- **`s_client` sub-package improvements**:
  - Added `putJson<T>()` typed variant for PUT requests with JSON deserialization
  - Added `patchJson<T>()` typed variant for PATCH requests with JSON deserialization
  - Added `deleteJson<T>()` typed variant for DELETE requests with JSON deserialization
- **`soundsliced_dart_extensions` sub-package improvements**:
  - Added `String.truncate(maxLength, {ellipsis})` extension
  - Added `List<T>.groupBy<K>(keyOf)` extension for grouping elements by key
- **`s_liquid_pull_to_refresh` sub-package improvements**:
  - Added `triggerDistance` for customizable drag threshold
  - Added `onDragProgress` callback reporting drag progress (0.0 to 1.0)
- **`s_screenshot` sub-package performance improvements**:
  - Fixed `ui.Image` memory leak — native GPU resources are now properly disposed after byte extraction
  - Base64 encoding is now offloaded to a separate isolate via `compute()` on native platforms to avoid blocking the UI thread (falls back to main thread on web where isolates aren't available)
  - Replaced `Future.microtask(() {})` with `WidgetsBinding.instance.endOfFrame` for more reliable rendering pipeline synchronization
  - Fixed `ByteData` buffer view to use precise `offsetInBytes`/`lengthInBytes` instead of unbounded `asUint8List()`
- **`s_connectivity` sub-package improvements**:
  - **BREAKING:** Removed `NoInternetConnectionPopup` widget; connectivity warnings now use the Modal snackbar system
  - Added `showNoInternetSnackbar` static property to auto-show/dismiss a staggered snackbar on connectivity changes
  - Added `noInternetSnackbarMessage` parameter to `initialiseInternetConnectivityListener()` for custom messages
  - Added `toggleConnectivitySnackbar()` static method for manual snackbar control
  - Removed dependencies on `assorted_layout_widgets` and `sizer`
- **`s_modal` sub-package improvements**:
  - **BREAKING:** Renamed `showSuffixIcon` parameter to `showCloseIcon` in `Modal.showSnackbar()`
  - Replaced barrier `SBounceable` with `SInkButton` for ink-splash feedback and long-press dismiss support
  - Improved snackbar default layout: text uses `Flexible` instead of `Expanded`, consistent spacing/alignment
- **`signals_watch` sub-package improvements**:
  - Metadata is now always stored for signals created via `SignalsWatch.signal()`, ensuring `.reset()` works even without lifecycle callbacks
  - `onValueUpdated` callback now supports zero-parameter signatures (fallback invocation if one-parameter call fails)


## 1.2.7

- **`s_sidebar` sub-package improvements**:
  - Enhanced `SideBarController.activateSideBar` with additional customization options:
    - Added `dismissBarrierColor` parameter for custom barrier colors
    - Added `shouldBlurDismissBarrier` parameter for optional blur effect on barrier
    - Added `initState` callback for initialization logic
    - Added `onDismissed` callback to handle sidebar dismissal events

## 1.2.6

- **`pop_overlay` sub-package animation improvements**:
  - Added smooth fade-in animations to all popup types; fixes flash issue in `FrameDesign` popups by smoothly animating appearance during auto dynamic dimension calculation time
  - Extended animation durations for smoother transitions: blur background (400ms → 600ms), barrier fade (0.4-0.5s → 0.8-1.0s), and animated size (300ms → 500ms)
  - Added `borderRadius` support to example demos for better visual consistency
  - Optimized popup entrance animations with `Curves.fastEaseInToSlowEaseOut` for more natural motion

## 1.2.5

- **`pop_overlay` sub-package improvements**:
  - Replaced `pop_overlay`'s use of `MediaQuery.of(context).size` with `Size(100.w, 100.h)` for better responsive sizing using the `sizer` package throughout the overlay system
  - Improved cross-platform compatibility and responsive behavior
- **Example app enhancements**:
  - Wrapped `MaterialApp` with `ForcePhoneSizeOnWeb` for better web demo experience with consistent phone-sized viewport
  - Added comprehensive Pop Overlay Demo section in `s_widgets_example_screen.dart` showcasing draggable popup with blur effects, custom styling, and interactive features

## 1.2.4

- **`s_sidebar` & `pop_overlay` sub-packages upgrades**:
  - `s_sidebar`: Added default left alignment for sidebar activation, allowing the sidebar to stay anchored to the left while minimizing.
  - `pop_overlay`: Added `alignment` property to `PopOverlayContent` (defaulting to `Alignment.center`) and updated `_PopOverlayActivator` to support popup alignment.

## 1.2.3

- No longer exporting web exclusive packages (`universal_html`, `web`...)

## 1.2.2

- SDK constraint upgrade

## 1.2.1

- no longer depending on `web` ^1.1.1

## 1.2.0

- **`s_sidebar` & `pop_overlay` sub-packages upgrades**:
  - Added `animateFromOffset` to `activateSideBar` to allow animating the sidebar popup from a specific screen position (e.g., button tap location).
  - Added `curve` parameter to customize the animation curve.
  - Added `animationDuration` parameter to control the popup animation speed.
  - Added `useGlobalPosition` parameter to `activateSideBar` and `PopOverlay`, simplifying coordinate handling by automatically converting global tap positions.
  - Fixed an issue where `SSideBar` could error with infinite height constraints when used in an overlay.
  - Example app's showcases updated accordingly for both `s_sidebar` & `pop_overlay` sub-packages
- `README` updated

## 1.1.4

- removed some conflicting dependencies

## 1.1.3

- dependencies upgraded
- new dependencies added not used in this package but included for export convenience, so users don't have to add them separately when using the widgets that depend on them.

## 1.1.2

* all Flutter platforms made enabled

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.1] - 2026-02-06
- README updated

## [1.1.0] - 2026-02-06
- full restructure of the package and subpackages + subpackages are exported so to be accessible by the `s_packages` users

## [1.0.3] - 2026-02-06
- s_packages.dart placed in the root folder, and its exports URLs fixed

## [1.0.2] - 2026-02-06
- s_packages.dart created, that exports all included sub packages

## [1.0.1] - 2026-02-06
- README and example gif updated

## [1.0.0] - 2026-02-05

### Added

#### Initial Release
This is the first public release of **s_packages**, a comprehensive collection of 43 Flutter packages designed to accelerate development and provide reusable UI components, utilities, and tools.

#### Package Categories

**UI Components (20 packages)**
- `bubble_label` - A bubble label widget for displaying tags and labels
- `s_animated_tabs` - Animated tab bar with smooth transitions
- `s_banner` - Customizable banner widget for notifications
- `s_button` - Custom button widget with advanced styling
- `s_context_menu` - Context menu widget for right-click interactions
- `s_disabled` - Widget wrapper for disabled state management
- `s_dropdown` - Dropdown widget with advanced features
- `s_error_widget` - Error display widget with customizable UI
- `s_expendable_menu` - Expandable menu widget for hierarchical navigation
- `s_future_button` - Button with Future-based async operations
- `s_ink_button` - Button with ink ripple effects
- `s_liquid_pull_to_refresh` - Liquid-style pull to refresh animation
- `s_maintenance_button` - Button for maintenance mode states
- `s_modal` - Modal dialog system with overlay management
- `s_standby` - Standby state widget for loading states
- `s_toggle` - Toggle switch widget
- `s_widgets` - Collection of reusable widgets
- `settings_item` - Settings item widget for configuration screens
- `ticker_free_circular_progress_indicator` - Progress indicator without ticker dependency

**Lists and Collections (2 packages)**
- `indexscroll_listview_builder` - ListView with index scrolling capabilities
- `s_gridview` - Enhanced grid view widget

**Animations (3 packages)**
- `s_bounceable` - Bounceable animation effects for interactive widgets
- `s_glow` - Glow effects and visual enhancements
- `shaker` - Shake animations for attention-grabbing effects
- `soundsliced_tween_animation_builder` - Custom tween animation builder

**Navigation (3 packages)**
- `pop_overlay` - Overlay management for navigation
- `pop_this` - Navigation utilities and helpers
- `s_sidebar` - Sidebar navigation component

**Networking (2 packages)**
- `s_client` - HTTP client utilities and helpers
- `s_connectivity` - Connectivity monitoring and status

**State Management (2 packages)**
- `signals_watch` - Signal watching utilities for reactive programming
- `states_rebuilder_extended` - Extended state management solutions

**Input & Interaction (1 package)**
- `keystroke_listener` - Keyboard event listener and handler

**Layout (1 package)**
- `s_offstage` - Offstage widget utilities for conditional rendering

**Platform Integration (1 package)**
- `s_webview` - WebView integration for embedded web content

**Utilities (4 packages)**
- `post_frame` - Post-frame callbacks for timing control
- `s_screenshot` - Screenshot capture utilities
- `s_time` - Time utilities and formatters
- `soundsliced_dart_extensions` - Dart language extensions

**Calendar (1 package)**
- `week_calendar` - Week-based calendar widget

#### Example Application
- Comprehensive example app showcasing all 43 packages
- Material Design 3 UI with light/dark theme support
- Package browser with search and category filtering
- Interactive demos for each package
- Example assets including GIF demonstrations

#### Documentation
- Complete README with installation and usage instructions
- Individual package documentation
- Code examples for basic and advanced usage
- GitHub repository with issue tracking

### Features
- ✨ 43 production-ready packages
- 📦 Unified package management
- 🎨 Material Design 3 support
- 🌓 Light and dark theme compatibility
- 📱 Cross-platform support (iOS, Android, Web, Desktop)
- 🔍 Comprehensive example app
- 📚 Extensive documentation
- ⚡ Performance optimized
- 🧪 Tested and validated

[1.0.0]: https://github.com/SoundSliced/s_packages/releases/tag/v1.0.0
