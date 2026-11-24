/// Web implementation of web utilities.
///
/// This file is only loaded on web platforms and provides
/// access to browser-specific functionality, through `package:web` so it
/// works with both dart2js and dart2wasm.
library;

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Opens a URL in a new browser tab (web platform only).
void openInNewTab(String url) {
  web.window.open(url, '_blank');
}

/// Applies a CSS filter to the iframe corresponding to [src] (web platform only).
void applyIframeFilter(String src, String filter) {
  final body = web.document.body;
  if (body == null) return;
  final iframe = _findIframeBySrc(body, src);
  if (iframe != null) {
    iframe.style.filter = filter;
  }
}

web.HTMLIFrameElement? _findIframeBySrc(web.Node parent, String src) {
  if (parent.isA<web.HTMLIFrameElement>()) {
    final frame = parent as web.HTMLIFrameElement;
    final frameSrc = frame.src;
    if (frameSrc == src || frameSrc.startsWith(src)) return frame;
  }
  final children = parent.childNodes;
  for (var i = 0; i < children.length; i++) {
    final child = children.item(i);
    if (child == null) continue;
    final found = _findIframeBySrc(child, src);
    if (found != null) return found;
  }
  if (parent.isA<web.Element>()) {
    final shadowRoot = (parent as web.Element).shadowRoot;
    if (shadowRoot != null) {
      final found = _findIframeBySrc(shadowRoot, src);
      if (found != null) return found;
    }
  }
  return null;
}
