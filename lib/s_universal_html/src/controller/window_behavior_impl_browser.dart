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

import '../../html.dart';
import 'window_controller.dart';

Document newDocument({
  required Window window,
  required String contentType,
  required bool filled,
}) {
  return DomParser().parseFromString('<html></html>', contentType);
}

HtmlDocument newHtmlDocument({required Window window, String? contentType}) {
  return DomParser().parseFromString(
    '<html></html>',
    contentType ?? 'text/html',
  ) as HtmlDocument;
}

Navigator newNavigator({required Window window}) {
  throw UnsupportedError(
    'Constructing a new navigator is unsupported in browser',
  );
}

Window newWindow({required WindowController windowController}) {
  return window;
}
