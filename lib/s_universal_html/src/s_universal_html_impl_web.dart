// Web implementation of SUniversalHtml helpers using package:web and
// dart:js_interop. No dart:html usage — compatible with both JS and WASM
// compilation targets.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

// ─── Context Menu ─────────────────────────────────────────────────────────

/// Prevents the browser's native right-click context menu globally.
/// Returns a cancel callback that removes the listener when called.
void Function()? preventDefaultContextMenu() {
  JSFunction? h;
  h = ((web.MouseEvent e) => e.preventDefault()).toJS;
  web.document.addEventListener('contextmenu', h);
  return () {
    final fn = h;
    if (fn != null) {
      web.document.removeEventListener('contextmenu', fn);
      h = null;
    }
  };
}

Stream<void> onContextMenu() => _docStream('contextmenu');

// ─── Window Location ──────────────────────────────────────────────────────

String get windowLocationHref => web.window.location.href;

void windowLocationReplace(String url) => web.window.location.replace(url);

void windowOpen(String url, String target) {
  web.window.open(url, target);
}

// ─── URL Parameters ───────────────────────────────────────────────────────

Map<String, String> get urlParameters {
  try {
    final href = web.window.location.href;
    if (href.isEmpty) return {};
    return Uri.parse(href).queryParameters;
  } catch (_) {
    return {};
  }
}

// ─── Location Fragment / Hash ─────────────────────────────────────────────

String get locationHash => web.window.location.hash;

void setLocationHash(String value) {
  web.window.location.hash = value;
}

// ─── Browser History ─────────────────────────────────────────────────────

void historyPushState(Object? state, String title, String url) {
  web.window.history.pushState(state?.toJSBox, title, url);
}

void historyReplaceState(Object? state, String title, String url) {
  web.window.history.replaceState(state?.toJSBox, title, url);
}

Stream<void> onPopState() => _windowStream('popstate');

// ─── Document Title ───────────────────────────────────────────────────────

String get documentTitle => web.document.title;

void setDocumentTitle(String value) {
  web.document.title = value;
}

// ─── Window Size ─────────────────────────────────────────────────────────

int get windowWidth => web.window.innerWidth;

int get windowHeight => web.window.innerHeight;

// ─── Window Events ────────────────────────────────────────────────────────

Stream<void> onResize() => _windowStream('resize');

Stream<void> onBeforeUnload() => _windowStream('beforeunload');

Stream<void> onWindowFocus() => _windowStream('focus');

Stream<void> onWindowBlur() => _windowStream('blur');

Stream<void> onVisibilityChange() => _docStream('visibilitychange');

bool get isPageVisible => web.document.visibilityState == 'visible';

// ─── Keyboard Events ──────────────────────────────────────────────────────

Stream<void> onKeyDown() => _windowStream('keydown');

Stream<void> onKeyUp() => _windowStream('keyup');

Stream<void> onKeyPress() => _windowStream('keypress');

// ─── Mouse Events ─────────────────────────────────────────────────────────

Stream<void> onMouseMove() => _windowStream('mousemove');

Stream<void> onMouseUp() => _windowStream('mouseup');

Stream<void> onMouseDown() => _windowStream('mousedown');

Stream<void> onWindowClick() => _windowStream('click');

// ─── Clipboard ────────────────────────────────────────────────────────────

Future<void> copyToClipboard(String text) async {
  try {
    await web.window.navigator.clipboard.writeText(text).toDart;
  } catch (_) {
    // Clipboard API unavailable or permission denied — ignore.
  }
}

Future<String> readFromClipboard() async {
  try {
    final result = await web.window.navigator.clipboard.readText().toDart;
    return result.toDart;
  } catch (_) {
    return '';
  }
}

// ─── Fullscreen ───────────────────────────────────────────────────────────

Future<void> requestFullscreen() async {
  try {
    final el = web.document.documentElement;
    if (el != null) await el.requestFullscreen().toDart;
  } catch (_) {}
}

Future<void> exitFullscreen() async {
  try {
    await web.document.exitFullscreen().toDart;
  } catch (_) {}
}

bool get isFullscreen => web.document.fullscreenElement != null;

Stream<void> onFullscreenChange() => _docStream('fullscreenchange');

// ─── Text Selection ───────────────────────────────────────────────────────

void disableTextSelection() {
  final body = web.document.body;
  if (body == null) return;
  body.style.userSelect = 'none';
  body.style.setProperty('-webkit-user-select', 'none');
}

void enableTextSelection() {
  final body = web.document.body;
  if (body == null) return;
  body.style.userSelect = '';
  body.style.removeProperty('-webkit-user-select');
}

// ─── CSS Custom Properties ────────────────────────────────────────────────

void setCssVariable(String name, String value) {
  (web.document.documentElement as web.HTMLElement?)
      ?.style
      .setProperty(name, value);
}

String? getCssVariable(String name) {
  final v = (web.document.documentElement as web.HTMLElement?)
      ?.style
      .getPropertyValue(name);
  return (v == null || v.isEmpty) ? null : v;
}

// ─── Scroll ───────────────────────────────────────────────────────────────

void scrollTo(int x, int y) {
  final opts = web.ScrollToOptions();
  opts.left = x.toDouble();
  opts.top = y.toDouble();
  web.window.scrollTo(opts);
}

void scrollBy(int x, int y) {
  final opts = web.ScrollToOptions();
  opts.left = x.toDouble();
  opts.top = y.toDouble();
  web.window.scrollBy(opts);
}

// ─── File Download ────────────────────────────────────────────────────────

void downloadBytesFile(String filename, List<int> bytes, String mimeType) {
  final uint8 = Uint8List.fromList(bytes);
  final blob = web.Blob(
    [uint8.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  web.document.body?.append(anchor);
  anchor.click();
  web.document.body?.removeChild(anchor);
  web.URL.revokeObjectURL(url);
}

// ─── Window Focus / Print ─────────────────────────────────────────────────

void windowFocus() => web.window.focus();

void windowBlur() => web.window.blur();

void printPage() => web.window.print();

// ─── Cookies ─────────────────────────────────────────────────────────────

String get cookies => web.document.cookie;

void setCookieStr(String cookieStr) {
  web.document.cookie = cookieStr;
}

// ─── Helpers ─────────────────────────────────────────────────────────────

Stream<void> _windowStream(String eventName) =>
    _eventStream(eventName, web.window);

Stream<void> _docStream(String eventName) =>
    _eventStream(eventName, web.document);

Stream<void> _eventStream(String eventName, web.EventTarget target) {
  late StreamController<void> controller;
  JSFunction? jsHandler;
  controller = StreamController<void>(
    onListen: () {
      jsHandler = ((web.Event _) => controller.add(null)).toJS;
      target.addEventListener(eventName, jsHandler!);
    },
    onCancel: () {
      final fn = jsHandler;
      if (fn != null) {
        target.removeEventListener(eventName, fn);
        jsHandler = null;
      }
    },
  );
  return controller.stream;
}
