/// Web implementation of web utilities.
///
/// This file is only loaded on web platforms and provides
/// access to browser-specific functionality.
///
/// Uses `package:s_packages/s_universal_html` for WASM compatibility instead of `dart:html`.
library;

import 'package:s_packages/s_universal_html/src/html.dart' as web;

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

web.IFrameElement? _findIframeBySrc(web.Node parent, String src) {
  if (parent is web.IFrameElement) {
    final parentSrc = parent.src;
    if (parentSrc != null && (parentSrc == src || parentSrc.startsWith(src))) {
      return parent;
    }
  }
  for (var i = 0; i < parent.childNodes.length; i++) {
    final child = parent.childNodes[i];
    final found = _findIframeBySrc(child, src);
    if (found != null) return found;
  }
  if (parent is web.Element && parent.shadowRoot != null) {
    final found = _findIframeBySrc(parent.shadowRoot!, src);
    if (found != null) return found;
  }
  return null;
}
