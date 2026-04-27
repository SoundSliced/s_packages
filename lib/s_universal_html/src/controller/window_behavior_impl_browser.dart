// Copyright 2019 terrier989@gmail.com
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:s_packages/s_universal_html/src/html.dart';
import 'package:web/web.dart' as web;

import 'window_controller.dart';

Document newDocument(
    {required Window window,
    required String contentType,
    required bool filled}) {
  final normalizedContentType = contentType.trim().toLowerCase();
  final isHtml = normalizedContentType.isEmpty ||
      normalizedContentType.contains('html') ||
      normalizedContentType == 'application/xhtml+xml';

  if (isHtml) {
    return HtmlDocument.internal(
        window: window, contentType: contentType, filled: filled);
  }

  return XmlDocument.internal(window: window, contentType: contentType);
}

HtmlDocument newHtmlDocument({required Window window, String? contentType}) {
  return HtmlDocument.internal(
      window: window, contentType: contentType ?? 'text/html', filled: true);
}

Navigator newNavigator({required Window window}) {
  final dynamic browserNavigator = web.window.navigator;

  String readString(dynamic value, String fallback) {
    final s = value?.toString() ?? '';
    return s.isEmpty ? fallback : s;
  }

  bool? readBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final s = value.toString().toLowerCase();
    if (s == 'true') return true;
    if (s == 'false') return false;
    return null;
  }

  int? readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  num? readNum(dynamic value) {
    if (value is num) return value;
    if (value == null) return null;
    return num.tryParse(value.toString());
  }

  List<String> readLanguages(dynamic value) {
    if (value is Iterable) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty || raw == '[object Array]') {
      return const <String>[];
    }

    if (raw.contains(',')) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return <String>[raw];
  }

  return Navigator.internal(
    internalWindow: window,
    deviceMemory: readNum(browserNavigator.deviceMemory),
    appCodeName: readString(browserNavigator.appCodeName, ''),
    appName: readString(browserNavigator.appName, 'Netscape'),
    appVersion: readString(browserNavigator.appVersion, '5.0'),
    platform: readString(browserNavigator.platform, 'Win32'),
    product: readString(browserNavigator.product, 'Gecko'),
    productSub: readString(browserNavigator.productSub, '20030107'),
    cookieEnabled: readBool(browserNavigator.cookieEnabled),
    languages: readLanguages(browserNavigator.languages),
    onLine: readBool(browserNavigator.onLine),
    userAgent: readString(browserNavigator.userAgent, '-'),
    vendor: readString(browserNavigator.vendor, '-'),
    vendorSub: readString(browserNavigator.vendorSub, ''),
    doNotTrack: browserNavigator.doNotTrack?.toString(),
    maxTouchPoints: readInt(browserNavigator.maxTouchPoints),
  );
}

Window newWindow({required WindowController windowController}) {
  Location.configureBrowserBindings(
    reload: () {
      web.window.location.reload();
      return true;
    },
    replace: (url) {
      web.window.location.replace(url);
      return true;
    },
    assign: (url) {
      web.window.location.assign(url);
      return true;
    },
    currentHref: () => web.window.location.href,
  );

  return Window.internal(
      internalWindowController: windowController,
      href: web.window.location.href);
}
