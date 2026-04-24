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
// ignore_for_file: constant_identifier_names

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

class DirectoryEntry extends Entry {
  DirectoryEntry.internal() : super._();

  factory DirectoryEntry._() {
    return _DirectoryEntryImpl.root();
  }

  @override
  bool get isDirectory => true;

  /// Create a new directory with the specified `path`. If `exclusive` is true,
  /// the returned Future will complete with an error if a directory already
  /// exists with the specified `path`.
  Future<Entry> createDirectory(String path, {bool exclusive = false}) {
    return (_asDirectory(this)).createDirectory(path, exclusive: exclusive);
  }

  /// Create a new file with the specified `path`. If `exclusive` is true,
  /// the returned Future will complete with an error if a file already
  /// exists at the specified `path`.
  Future<Entry> createFile(String path, {bool exclusive = false}) {
    return (_asDirectory(this)).createFile(path, exclusive: exclusive);
  }

  DirectoryReader createReader() {
    return (_asDirectory(this)).createReader();
  }

  /// Retrieve an already existing directory entry. The returned future will
  /// result in an error if a directory at `path` does not exist or if the item
  /// at `path` is not a directory.
  Future<Entry> getDirectory(String path) {
    return (_asDirectory(this)).getDirectory(path);
  }

  /// Retrieve an already existing file entry. The returned future will
  /// result in an error if a file at `path` does not exist or if the item at
  /// `path` is not a file.
  Future<Entry> getFile(String path) {
    return (_asDirectory(this)).getFile(path);
  }

  Future removeRecursively() {
    return (_asDirectory(this)).removeRecursively();
  }
}

class DirectoryReader {
  factory DirectoryReader._() {
    return _DirectoryReaderImpl(const <Entry>[]);
  }

  Future<List<Entry>> readEntries() {
    return (_asDirectoryReader(this)).readEntries();
  }
}

abstract class Entry {
  Entry._();

  FileSystem? get filesystem => null;

  String? get fullPath => null;

  bool get isDirectory => false;

  bool get isFile => false;

  String? get name => null;

  Future<Entry> copyTo(DirectoryEntry parent, {String? name}) {
    return Future<Entry>.value(this);
  }

  Future<Metadata> getMetadata() {
    return Future<Metadata>.value(Metadata._());
  }

  Future<Entry> getParent() {
    return Future<Entry>.value(this);
  }

  Future<Entry> moveTo(DirectoryEntry parent, {String? name}) {
    return Future<Entry>.value(this);
  }

  Future remove() {
    return Future.value();
  }

  String toUrl() {
    return fullPath ?? '';
  }
}

class File implements Blob {
  factory File(List<Object> fileBits, String fileName, [Map? options]) {
    return _FileImpl(fileBits, fileName, options);
  }

  int get lastModified => DateTime.now().millisecondsSinceEpoch;

  DateTime get lastModifiedDate =>
      DateTime.fromMillisecondsSinceEpoch(lastModified);

  String get name => '';

  String get relativePath => name;

  @override
  int get size => 0;

  @override
  String get type => '';

  @override
  Future<List<int>> internalBytes() => Future<List<int>>.value(const <int>[]);

  @override
  Blob slice([int? start, int? end, String? contentType]) =>
      Blob(const <Object>[], contentType ?? type);
}

class FileEntry extends Entry {
  FileEntry.internal() : super._();

  factory FileEntry._() {
    return _FileEntryImpl(File(const <Object>[], ''));
  }

  @override
  bool get isFile => true;

  Future<FileWriter> createWriter() {
    return (_asFileEntry(this)).createWriter();
  }

  Future<File> file() {
    return (_asFileEntry(this)).file();
  }

  @override
  Future remove();
}

class FileReader extends EventTarget {
  static const int DONE = 2;
  static const int EMPTY = 0;
  static const int LOADING = 1;

  /// Static factory designed to expose `abort` events to event
  /// handlers that are not necessarily instances of [FileReader].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> abortEvent =
      EventStreamProvider<ProgressEvent>('abort');

  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [FileReader].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> errorEvent =
      EventStreamProvider<ProgressEvent>('error');

  /// Static factory designed to expose `load` events to event
  /// handlers that are not necessarily instances of [FileReader].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> loadEvent =
      EventStreamProvider<ProgressEvent>('load');

  /// Static factory designed to expose `loadend` events to event
  /// handlers that are not necessarily instances of [FileReader].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> loadEndEvent =
      EventStreamProvider<ProgressEvent>('loadend');

  /// Static factory designed to expose `loadstart` events to event
  /// handlers that are not necessarily instances of [FileReader].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> loadStartEvent =
      EventStreamProvider<ProgressEvent>('loadstart');

  /// Static factory designed to expose `progress` events to event
  /// handlers that are not necessarily instances of [FileReader].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> progressEvent =
      EventStreamProvider<ProgressEvent>('progress');

  factory FileReader() = FileReader._;

  FileReader._() : super.internal();

  Object? _result;
  int _readyState = EMPTY;

  Error get error => StateError('No file read error.') as Error;

  /// Stream of `abort` events handled by this [FileReader].
  Stream<ProgressEvent> get onAbort => abortEvent.forTarget(this);

  /// Stream of `error` events handled by this [FileReader].
  Stream<ProgressEvent> get onError => errorEvent.forTarget(this);

  /// Stream of `load` events handled by this [FileReader].
  Stream<ProgressEvent> get onLoad => loadEvent.forTarget(this);

  /// Stream of `loadend` events handled by this [FileReader].
  Stream<ProgressEvent> get onLoadEnd => loadEndEvent.forTarget(this);

  /// Stream of `loadstart` events handled by this [FileReader].
  Stream<ProgressEvent> get onLoadStart => loadStartEvent.forTarget(this);

  /// Stream of `progress` events handled by this [FileReader].
  Stream<ProgressEvent> get onProgress => progressEvent.forTarget(this);

  int get readyState => _readyState;

  Object get result => _result ?? '';

  void abort() {
    _readyState = DONE;
    _result = null;
  }

  void readAsArrayBuffer(Blob blob) {
    _readyState = LOADING;
    blob.internalBytes().then((bytes) {
      _result = Uint8List.fromList(bytes).buffer;
      _readyState = DONE;
    });
  }

  void readAsDataUrl(Blob blob) {
    _readyState = LOADING;
    blob.internalBytes().then((bytes) {
      _result = 'data:${blob.type};base64,${base64Encode(bytes)}';
      _readyState = DONE;
    });
  }

  void readAsText(Blob blob, [String? label]) {
    _readyState = LOADING;
    blob.internalBytes().then((bytes) {
      _result = utf8.decode(bytes, allowMalformed: true);
      _readyState = DONE;
    });
  }
}

class FileSystem {
  static bool get supported => false;

  factory FileSystem._() {
    return _FileSystemImpl.create();
  }

  String? get name => null;

  DirectoryEntry? get root => null;
}

abstract class FileWriter extends EventTarget {
  /// Static factory designed to expose `abort` events to event
  /// handlers that are not necessarily instances of [FileWriter].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> abortEvent =
      EventStreamProvider<ProgressEvent>('abort');

  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [FileWriter].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  /// Static factory designed to expose `progress` events to event
  /// handlers that are not necessarily instances of [FileWriter].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> progressEvent =
      EventStreamProvider<ProgressEvent>('progress');

  /// Static factory designed to expose `write` events to event
  /// handlers that are not necessarily instances of [FileWriter].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> writeEvent =
      EventStreamProvider<ProgressEvent>('write');

  /// Static factory designed to expose `writeend` events to event
  /// handlers that are not necessarily instances of [FileWriter].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> writeEndEvent =
      EventStreamProvider<ProgressEvent>('writeend');

  /// Static factory designed to expose `writestart` events to event
  /// handlers that are not necessarily instances of [FileWriter].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<ProgressEvent> writeStartEvent =
      EventStreamProvider<ProgressEvent>('writestart');

  static const int DONE = 2;

  static const int INIT = 0;

  static const int WRITING = 1;

  FileWriter._() : super.internal();

  Error get error;

  int get length;

  /// Stream of `abort` events handled by this [FileWriter].
  Stream<ProgressEvent> get onAbort => abortEvent.forTarget(this);

  /// Stream of `error` events handled by this [FileWriter].
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of `progress` events handled by this [FileWriter].
  Stream<ProgressEvent> get onProgress => progressEvent.forTarget(this);

  /// Stream of `write` events handled by this [FileWriter].
  Stream<ProgressEvent> get onWrite => writeEvent.forTarget(this);

  /// Stream of `writeend` events handled by this [FileWriter].
  Stream<ProgressEvent> get onWriteEnd => writeEndEvent.forTarget(this);

  /// Stream of `writestart` events handled by this [FileWriter].
  Stream<ProgressEvent> get onWriteStart => writeStartEvent.forTarget(this);

  int get position => 0;

  int get readyState => DONE;

  void abort();

  void seek(int position);

  void truncate(int size);

  void write(Blob data);
}

class Metadata {
  factory Metadata._() {
    return _MetadataImpl();
  }

  DateTime get modificationTime => DateTime.fromMillisecondsSinceEpoch(0);

  int get size => 0;
}

_DirectoryEntryImpl _asDirectory(DirectoryEntry entry) {
  if (entry is _DirectoryEntryImpl) {
    return entry;
  }
  return DirectoryEntry._() as _DirectoryEntryImpl;
}

_DirectoryReaderImpl _asDirectoryReader(DirectoryReader reader) {
  if (reader is _DirectoryReaderImpl) {
    return reader;
  }
  return _DirectoryReaderImpl(const <Entry>[]);
}

_FileEntryImpl _asFileEntry(FileEntry entry) {
  if (entry is _FileEntryImpl) {
    return entry;
  }
  return FileEntry._() as _FileEntryImpl;
}

class _FileImpl implements File {
  final Blob _blob;
  @override
  final int lastModified;
  @override
  final String name;
  @override
  final String relativePath;

  _FileImpl(List<Object> fileBits, this.name, [Map? options])
      : _blob = Blob(fileBits, options?['type'] as String? ?? ''),
        lastModified = options?['lastModified'] as int? ??
            DateTime.now().millisecondsSinceEpoch,
        relativePath = options?['relativePath'] as String? ?? name;

  @override
  DateTime get lastModifiedDate =>
      DateTime.fromMillisecondsSinceEpoch(lastModified);

  @override
  int get size => _blob.size;

  @override
  String get type => _blob.type;

  @override
  Future<List<int>> internalBytes() => _blob.internalBytes();

  @override
  Blob slice([int? start, int? end, String? contentType]) =>
      _blob.slice(start ?? 0, end, contentType);
}

class _DirectoryEntryImpl extends DirectoryEntry {
  final Map<String, Entry> _children = <String, Entry>{};
  final _FileSystemImpl _filesystem;
  final _DirectoryEntryImpl? _parent;
  @override
  final String? name;
  @override
  final String? fullPath;

  _DirectoryEntryImpl._(this._filesystem, this._parent, this.name)
      : fullPath = _parent == null
            ? '/'
            : (_parent.fullPath == '/'
                ? '/$name'
                : '${_parent.fullPath}/$name'),
        super.internal();

  factory _DirectoryEntryImpl.root() {
    final fs = _FileSystemImpl._private();
    final root = _DirectoryEntryImpl._(fs, null, '');
    fs._rootEntry = root;
    return root;
  }

  @override
  FileSystem? get filesystem => _filesystem;

  @override
  Future<Entry> createDirectory(String path, {bool exclusive = false}) async {
    if (exclusive && _children.containsKey(path)) {
      throw StateError('Directory already exists: $path');
    }
    return _children.putIfAbsent(
        path, () => _DirectoryEntryImpl._(_filesystem, this, path));
  }

  @override
  Future<Entry> createFile(String path, {bool exclusive = false}) async {
    if (exclusive && _children.containsKey(path)) {
      throw StateError('File already exists: $path');
    }
    return _children.putIfAbsent(
        path, () => _FileEntryImpl(File(const <Object>[], path), parent: this));
  }

  @override
  DirectoryReader createReader() =>
      _DirectoryReaderImpl(_children.values.toList(growable: false));

  @override
  Future<Entry> getDirectory(String path) async {
    final entry = _children[path];
    if (entry is DirectoryEntry) {
      return entry;
    }
    throw StateError('Directory not found: $path');
  }

  @override
  Future<Entry> getFile(String path) async {
    final entry = _children[path];
    if (entry is FileEntry) {
      return entry;
    }
    throw StateError('File not found: $path');
  }

  @override
  Future<Entry> getParent() async => _parent ?? this;

  @override
  Future remove() async {
    _parent?._children.remove(name);
  }

  @override
  Future removeRecursively() async {
    _children.clear();
    await remove();
  }
}

class _DirectoryReaderImpl implements DirectoryReader {
  final List<Entry> _entries;

  _DirectoryReaderImpl(this._entries);

  @override
  Future<List<Entry>> readEntries() =>
      Future<List<Entry>>.value(List<Entry>.unmodifiable(_entries));
}

class _FileEntryImpl extends FileEntry {
  File _file;
  final _DirectoryEntryImpl? parent;

  _FileEntryImpl(this._file, {this.parent}) : super.internal();

  @override
  FileSystem? get filesystem => parent?.filesystem;

  @override
  String? get fullPath =>
      parent == null ? '/${_file.name}' : '${parent!.fullPath}/${_file.name}';

  @override
  String? get name => _file.name;

  @override
  Future<FileWriter> createWriter() =>
      Future<FileWriter>.value(_MemoryFileWriter(this));

  @override
  Future<File> file() => Future<File>.value(_file);

  @override
  Future<Entry> getParent() async => parent ?? this;

  @override
  Future remove() async {
    parent?._children.remove(_file.name);
  }
}

class _MemoryFileWriter extends FileWriter {
  final _FileEntryImpl _entry;
  final Object _error = StateError('No file writer error.');
  int _position = 0;
  int _readyState = FileWriter.DONE;

  _MemoryFileWriter(this._entry) : super._();

  @override
  Error get error => _error as Error;

  @override
  int get length => _entry._file.size;

  @override
  int get position => _position;

  @override
  int get readyState => _readyState;

  @override
  void abort() {
    _readyState = FileWriter.DONE;
  }

  @override
  void seek(int position) {
    _position = position.clamp(0, length);
  }

  @override
  void truncate(int size) {
    _entry._file = File(
        <Object>[_entry._file.slice(0, size)],
        _entry._file.name,
        {
          'type': _entry._file.type,
          'lastModified': DateTime.now().millisecondsSinceEpoch,
          'relativePath': _entry._file.relativePath,
        });
    _position = _position.clamp(0, size);
  }

  @override
  void write(Blob data) {
    _readyState = FileWriter.WRITING;
    data.internalBytes().then((bytes) {
      _entry._file = File(
          <Object>[bytes],
          _entry._file.name,
          {
            'type': data.type,
            'lastModified': DateTime.now().millisecondsSinceEpoch,
            'relativePath': _entry._file.relativePath,
          });
      _position = _entry._file.size;
      _readyState = FileWriter.DONE;
    });
  }
}

class _MetadataImpl implements Metadata {
  @override
  DateTime get modificationTime => DateTime.now();

  @override
  int get size => 0;
}

class _FileSystemImpl implements FileSystem {
  _FileSystemImpl._private();

  factory _FileSystemImpl.create() {
    final fs = _FileSystemImpl._private();
    fs._rootEntry = _DirectoryEntryImpl._(fs, null, '');
    return fs;
  }

  late DirectoryEntry _rootEntry;

  @override
  String? get name => 'memory';

  @override
  DirectoryEntry? get root => _rootEntry;
}
