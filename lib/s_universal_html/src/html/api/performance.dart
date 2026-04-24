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

abstract class MemoryInfo {
  factory MemoryInfo._() {
    return const _MemoryInfoImpl();
  }

  int get jsHeapSizeLimit;

  int get totalJSHeapSize;

  int get usedJSHeapSize;
}

@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE)
@Native('Performance')
class Performance extends EventTarget {
  /// Checks if this type is supported on the current platform.
  static bool get supported => false;

  // To suppress missing implicit constructor warnings.
  factory Performance._() {
    return _PerformanceImpl();
  }

  Performance.internal() : super.internal();

  MemoryInfo? get memory {
    return const _MemoryInfoImpl();
  }

  num? get timeOrigin {
    return DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  void clearMarks(String? markName) {
    if (this is _PerformanceImpl) {
      (this as _PerformanceImpl)._clearMarks(markName);
    }
  }

  void clearMeasures(String? measureName) {
    if (this is _PerformanceImpl) {
      (this as _PerformanceImpl)._clearMeasures(measureName);
    }
  }

  void clearResourceTimings() {
    if (this is _PerformanceImpl) {
      (this as _PerformanceImpl)._clearResourceTimings();
    }
  }

  List<PerformanceEntry> getEntries() {
    if (this is _PerformanceImpl) {
      return (this as _PerformanceImpl).getEntries();
    }
    return const <PerformanceEntry>[];
  }

  List<PerformanceEntry> getEntriesByName(String name, String? entryType) {
    if (this is _PerformanceImpl) {
      return (this as _PerformanceImpl).getEntriesByName(name, entryType);
    }
    return const <PerformanceEntry>[];
  }

  List<PerformanceEntry> getEntriesByType(String entryType) {
    if (this is _PerformanceImpl) {
      return (this as _PerformanceImpl).getEntriesByType(entryType);
    }
    return const <PerformanceEntry>[];
  }

  void mark(String markName) {
    if (this is _PerformanceImpl) {
      (this as _PerformanceImpl).mark(markName);
    }
  }

  void measure(String measureName, String? startMark, String? endMark) {
    if (this is _PerformanceImpl) {
      (this as _PerformanceImpl).measure(measureName, startMark, endMark);
    }
  }

  double now() {
    return DateTime.now().microsecondsSinceEpoch /
        Duration.microsecondsPerMillisecond;
  }

  void setResourceTimingBufferSize(int maxSize) {
    if (this is _PerformanceImpl) {
      // Buffer sizing is ignored by the fallback implementation.
    }
  }
}

@Native('PerformanceEntry')
class PerformanceEntry {
  // To suppress missing implicit constructor warnings.
  factory PerformanceEntry._() {
    return const _PerformanceEntryImpl();
  }

  num get duration {
    return 0;
  }

  String get entryType {
    return '';
  }

  String get name {
    return '';
  }

  num get startTime {
    return 0;
  }
}

class _PerformanceImpl extends Performance {
  final DateTime _startedAt = DateTime.now();
  final Map<String, double> _marks = <String, double>{};
  final List<PerformanceEntry> _entries = <PerformanceEntry>[];

  _PerformanceImpl() : super.internal();

  void _clearMarks(String? markName) {
    if (markName == null) {
      _marks.clear();
      _entries.removeWhere((entry) => entry.entryType == 'mark');
      return;
    }
    _marks.remove(markName);
    _entries.removeWhere(
      (entry) => entry.entryType == 'mark' && entry.name == markName,
    );
  }

  void _clearMeasures(String? measureName) {
    if (measureName == null) {
      _entries.removeWhere((entry) => entry.entryType == 'measure');
      return;
    }
    _entries.removeWhere(
      (entry) => entry.entryType == 'measure' && entry.name == measureName,
    );
  }

  void _clearResourceTimings() {
    _entries.removeWhere((entry) => entry.entryType == 'resource');
  }

  @override
  List<PerformanceEntry> getEntries() =>
      List<PerformanceEntry>.unmodifiable(_entries);

  @override
  List<PerformanceEntry> getEntriesByName(String name, String? entryType) {
    return List<PerformanceEntry>.unmodifiable(
      _entries.where(
        (entry) =>
            entry.name == name &&
            (entryType == null || entry.entryType == entryType),
      ),
    );
  }

  @override
  List<PerformanceEntry> getEntriesByType(String entryType) {
    return List<PerformanceEntry>.unmodifiable(
      _entries.where((entry) => entry.entryType == entryType),
    );
  }

  @override
  void mark(String markName) {
    final current = now();
    _marks[markName] = current;
    _entries.add(_PerformanceEntryImpl(
        name: markName, entryType: 'mark', startTime: current));
  }

  @override
  void measure(String measureName, String? startMark, String? endMark) {
    final end = endMark == null ? now() : (_marks[endMark] ?? now());
    final start = startMark == null ? 0 : (_marks[startMark] ?? 0);
    _entries.add(
      _PerformanceEntryImpl(
        name: measureName,
        entryType: 'measure',
        startTime: start,
        duration: end - start,
      ),
    );
  }

  @override
  MemoryInfo? get memory => const _MemoryInfoImpl();

  @override
  double now() =>
      DateTime.now().difference(_startedAt).inMicroseconds /
      Duration.microsecondsPerMillisecond;
}

class _PerformanceEntryImpl implements PerformanceEntry {
  @override
  final num duration;

  @override
  final String entryType;

  @override
  final String name;

  @override
  final num startTime;

  const _PerformanceEntryImpl({
    this.duration = 0,
    this.entryType = '',
    this.name = '',
    this.startTime = 0,
  });
}

class _MemoryInfoImpl implements MemoryInfo {
  @override
  int get jsHeapSizeLimit => 0;

  @override
  int get totalJSHeapSize => 0;

  @override
  int get usedJSHeapSize => 0;

  const _MemoryInfoImpl();
}
