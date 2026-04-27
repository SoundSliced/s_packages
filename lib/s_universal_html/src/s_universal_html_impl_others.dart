// Non-web stub implementations for SUniversalHtml.
// All methods are no-ops or return empty/default values.

import 'dart:async';

// ─── Context Menu ─────────────────────────────────────────────────────────

void Function()? preventDefaultContextMenu() => null;

Stream<void> onContextMenu() => const Stream.empty();

// ─── Window Location ──────────────────────────────────────────────────────

String get windowLocationHref => '';

void windowLocationReplace(String url) {}

void windowOpen(String url, String target) {}

// ─── URL Parameters ───────────────────────────────────────────────────────

Map<String, String> get urlParameters => {};

// ─── Location Fragment / Hash ─────────────────────────────────────────────

String get locationHash => '';

void setLocationHash(String value) {}

// ─── Browser History ─────────────────────────────────────────────────────

void historyPushState(Object? state, String title, String url) {}

void historyReplaceState(Object? state, String title, String url) {}

Stream<void> onPopState() => const Stream.empty();

// ─── Document Title ───────────────────────────────────────────────────────

String get documentTitle => '';

void setDocumentTitle(String value) {}

// ─── Window Size ─────────────────────────────────────────────────────────

int get windowWidth => 0;

int get windowHeight => 0;

// ─── Window Events ────────────────────────────────────────────────────────

Stream<void> onResize() => const Stream.empty();

Stream<void> onBeforeUnload() => const Stream.empty();

Stream<void> onWindowFocus() => const Stream.empty();

Stream<void> onWindowBlur() => const Stream.empty();

Stream<void> onVisibilityChange() => const Stream.empty();

bool get isPageVisible => true;

// ─── Keyboard Events ──────────────────────────────────────────────────────

Stream<void> onKeyDown() => const Stream.empty();

Stream<void> onKeyUp() => const Stream.empty();

Stream<void> onKeyPress() => const Stream.empty();

// ─── Mouse Events ─────────────────────────────────────────────────────────

Stream<void> onMouseMove() => const Stream.empty();

Stream<void> onMouseUp() => const Stream.empty();

Stream<void> onMouseDown() => const Stream.empty();

Stream<void> onWindowClick() => const Stream.empty();

// ─── Clipboard ────────────────────────────────────────────────────────────

Future<void> copyToClipboard(String text) async {}

Future<String> readFromClipboard() async => '';

// ─── Fullscreen ───────────────────────────────────────────────────────────

Future<void> requestFullscreen() async {}

Future<void> exitFullscreen() async {}

bool get isFullscreen => false;

Stream<void> onFullscreenChange() => const Stream.empty();

// ─── Text Selection ───────────────────────────────────────────────────────

void disableTextSelection() {}

void enableTextSelection() {}

// ─── CSS Custom Properties ────────────────────────────────────────────────

void setCssVariable(String name, String value) {}

String? getCssVariable(String name) => null;

// ─── Scroll ───────────────────────────────────────────────────────────────

void scrollTo(int x, int y) {}

void scrollBy(int x, int y) {}

// ─── File Download ────────────────────────────────────────────────────────

void downloadBytesFile(String filename, List<int> bytes, String mimeType) {}

// ─── Window Focus / Print ─────────────────────────────────────────────────

void windowFocus() {}

void windowBlur() {}

void printPage() {}

// ─── Cookies ─────────────────────────────────────────────────────────────

String get cookies => '';

void setCookieStr(String cookieStr) {}
