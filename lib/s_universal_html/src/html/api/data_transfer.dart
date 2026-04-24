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
/*
Some source code in this file was adopted from 'dart:html' in Dart SDK. See:
  https://github.com/dart-lang/sdk/tree/master/tools/dom

The source code adopted from 'dart:html' had the following license:

  Copyright 2012, the Dart project authors. All rights reserved.
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

part of '../../html.dart';

abstract class DataTransfer {
  String? dropEffect;

  String? effectAllowed;

  final List<File>? files = [];

  List<DataTransferItem>? items = [];

  final List<String>? types = [];

  final Map<String, String> _data = <String, String>{};

  void clearData([String? format]) {
    if (format == null) {
      _data.clear();
      return;
    }
    _data.remove(format);
  }

  String getData(String format) {
    return _data[format] ?? '';
  }

  void setData(String format, String data) {
    _data[format] = data;
    if (!(types?.contains(format) ?? false)) {
      types?.add(format);
    }
  }

  void setDragImage(Element image, int x, int y) {}
}

abstract class DataTransferItem {
  DataTransferItem._();

  String? get kind {
    return null;
  }

  String? get type {
    return null;
  }

  Entry getAsEntry();

  File? getAsFile() {
    return null;
  }
}

abstract class DataTransferItemList {
  DataTransferItemList._();

  final List<DataTransferItem> _items = <DataTransferItem>[];

  int get length {
    return _items.length;
  }

  DataTransferItem operator [](int index) {
    return _items[index];
  }

  DataTransferItem add(dynamic dataOrFile, [String? type]) {
    if (dataOrFile is File) {
      return addFile(dataOrFile);
    }
    return addData(dataOrFile?.toString() ?? '', type ?? 'text/plain');
  }

  DataTransferItem addData(String data, String type) {
    final item =
        _FallbackDataTransferItem(kindValue: 'string', typeValue: type);
    _items.add(item);
    return item;
  }

  DataTransferItem addFile(File file) {
    final item = _FallbackDataTransferItem(
      kindValue: 'file',
      typeValue: file.type,
      fileValue: file,
    );
    _items.add(item);
    return item;
  }

  void clear() {
    _items.clear();
  }

  DataTransferItem item(int index) {
    return _items[index];
  }

  void remove(int index) {
    _items.removeAt(index);
  }
}

class _FallbackDataTransferItem extends DataTransferItem {
  final String? kindValue;
  final String? typeValue;
  final File? fileValue;

  _FallbackDataTransferItem({this.kindValue, this.typeValue, this.fileValue})
      : super._();

  @override
  String? get kind => kindValue;

  @override
  String? get type => typeValue;

  @override
  Entry getAsEntry() {
    throw UnsupportedError(
        'DataTransfer entry is not supported in this runtime.');
  }

  @override
  File? getAsFile() => fileValue;
}
