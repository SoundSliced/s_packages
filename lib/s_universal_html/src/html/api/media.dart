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

typedef RemotePlaybackAvailabilityCallback = void Function(bool available);

abstract class CanvasCaptureMediaStreamTrack implements MediaStreamTrack {
  CanvasCaptureMediaStreamTrack._();

  CanvasElement get canvas;
}

abstract class ImageBitmap {
  ImageBitmap._();
}

abstract class ImageCapture {
  factory ImageCapture(MediaStreamTrack track) {
    return _ImageCaptureImpl(track);
  }

  Future<PhotoCapabilities> getPhotoCapabilities();

  Future<Map<String, dynamic>> getPhotoSettings();

  Future<ImageBitmap> grabFrame();

  Future setOptions(Map photoSettings);

  Future takePhoto([Map photoSettings]);
}

abstract class MediaDeviceInfo {
  MediaDeviceInfo._();

  String? get deviceId;

  String? get groupId;

  String? get kind;

  String? get label;
}

@Native('MediaDevices')
class MediaDevices extends EventTarget {
  factory MediaDevices.fallback() {
    return _MediaDevicesImpl();
  }

  MediaDevices.internal() : super.internal();

  Future<List<dynamic>> enumerateDevices() =>
      Future<List<dynamic>>.value(const <dynamic>[]);

  Map getSupportedConstraints() {
    return const <String, dynamic>{};
  }

  Future<MediaStream> getUserMedia([Map? constraints]) {
    return Future<MediaStream>.value(MediaStream());
  }
}

@Unstable()
@Native('MediaError')
class MediaError {
  static const int MEDIA_ERR_ABORTED = 1;

  static const int MEDIA_ERR_DECODE = 3;

  static const int MEDIA_ERR_NETWORK = 2;

  static const int MEDIA_ERR_SRC_NOT_SUPPORTED = 4;

  factory MediaError._() {
    return const _MediaErrorImpl();
  }

  int get code {
    return MEDIA_ERR_SRC_NOT_SUPPORTED;
  }

  String? get message {
    return '';
  }
}

abstract class MediaKeys {
  factory MediaKeys._() {
    return _MediaKeysImpl();
  }

  Future getStatusForPolicy(MediaKeysPolicy policy);

  Future setServerCertificate(dynamic serverCertificate);
}

abstract class MediaKeysPolicy {
  factory MediaKeysPolicy(Map init) {
    return _MediaKeysPolicyImpl(init);
  }

  String? get minHdcpVersion;
}

@Native('MediaRecorder')
class MediaRecorder extends EventTarget {
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  static const EventStreamProvider<Event> pauseEvent =
      EventStreamProvider<Event>('pause');

  factory MediaRecorder(MediaStream stream, [Map? options]) {
    return _MediaRecorderImpl(stream, options);
  }

  MediaRecorder.internal() : super.internal();

  int? get audioBitsPerSecond {
    return 0;
  }

  String? get mimeType {
    return '';
  }

  Stream<Event> get onError => errorEvent.forTarget(this);

  Stream<Event> get onPause => pauseEvent.forTarget(this);

  String? get state {
    return 'inactive';
  }

  MediaStream? get stream {
    return null;
  }

  int? get videoBitsPerSecond {
    return 0;
  }

  void pause() {
    // No-op in fallback mode.
  }

  void requestData() {
    // No-op in fallback mode.
  }

  void resume() {
    // No-op in fallback mode.
  }

  void start([int? timeslice]) {
    // No-op in fallback mode.
  }

  void stop() {
    // No-op in fallback mode.
  }

  static bool isTypeSupported(String type) {
    return false;
  }
}

@Native('MediaSession')
class MediaSession {
  factory MediaSession._() {
    return _MediaSessionImpl();
  }

  MediaMetadata? get metadata {
    return null;
  }

  set metadata(MediaMetadata? value) {
    // No-op in fallback mode.
  }

  String? get playbackState {
    return 'none';
  }

  set playbackState(String? value) {
    // No-op in fallback mode.
  }

  void setActionHandler(String action, MediaSessionActionHandler? handler) {
    // No-op in fallback mode.
  }
}

abstract class MediaSettingsRange {
  MediaSettingsRange._();

  num get max;

  num get min;

  num get step;
}

@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.IE, '11')
@Native('MediaSource')
class MediaSource extends EventTarget {
  static bool get supported => false;

  factory MediaSource() {
    return _MediaSourceImpl();
  }

  MediaSource.internal() : super.internal();

  List<SourceBuffer>? get activeSourceBuffers {
    return const <SourceBuffer>[];
  }

  num? get duration {
    return 0;
  }

  set duration(num? value) {
    // No-op in fallback mode.
  }

  String? get readyState {
    return 'closed';
  }

  List<SourceBuffer>? get sourceBuffers {
    return const <SourceBuffer>[];
  }

  SourceBuffer addSourceBuffer(String type) {
    return SourceBuffer._();
  }

  void clearLiveSeekableRange() {
    // No-op in fallback mode.
  }

  void endOfStream([String? error]) {
    // No-op in fallback mode.
  }

  void removeSourceBuffer(SourceBuffer buffer) {
    // No-op in fallback mode.
  }

  void setLiveSeekableRange(num start, num end) {
    // No-op in fallback mode.
  }

  static bool isTypeSupported(String type) {
    return false;
  }
}

abstract class MediaStream implements EventTarget {
  /// Static factory designed to expose `addtrack` events to event
  /// handlers that are not necessarily instances of [MediaStream].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> addTrackEvent =
      EventStreamProvider<Event>('addtrack');

  /// Static factory designed to expose `removetrack` events to event
  /// handlers that are not necessarily instances of [MediaStream].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> removeTrackEvent =
      EventStreamProvider<Event>('removetrack');

  static bool get supported => false;

  factory MediaStream([dynamic streamOrTracks]) {
    return _MediaStreamImpl.from(streamOrTracks);
  }

  bool get active;

  String get id;

  /// Stream of `addtrack` events handled by this [MediaStream].
  Stream<Event> get onAddTrack => addTrackEvent.forTarget(this);

  /// Stream of `removetrack` events handled by this [MediaStream].
  Stream<Event> get onRemoveTrack => removeTrackEvent.forTarget(this);

  void addTrack(MediaStreamTrack track);

  MediaStream clone();

  List<MediaStreamTrack> getAudioTracks();

  MediaStreamTrack getTrackById(String trackId);

  List<MediaStreamTrack> getTracks();

  List<MediaStreamTrack> getVideoTracks();

  void removeTrack(MediaStreamTrack track);
}

abstract class MediaStreamEvent extends Event {
  static bool get supported => false;

  MediaStreamEvent(super.type) : super.internal();

  MediaStream get stream;
}

abstract class MediaStreamTrack extends EventTarget {
  String? contentHint;
  bool? enabled;

  MediaStreamTrack._() : super.internal();

  String get id;

  String get kind;

  String get label;

  bool get muted;

  String get readyState;
}

abstract class MediaStreamTrackEvent extends Event {
  factory MediaStreamTrackEvent(String type, Map eventInitDict) {
    return _MediaStreamTrackEventImpl(type, eventInitDict);
  }

  MediaStreamTrack get track;
}

abstract class PhotoCapabilities {
  PhotoCapabilities._();

  List get fillLightMode;

  MediaSettingsRange get imageHeight;

  MediaSettingsRange get imageWidth;

  String get redEyeReduction;
}

abstract class RemotePlayback extends EventTarget {
  factory RemotePlayback._() {
    return _RemotePlaybackImpl();
  }

  String get state;

  Future cancelWatchAvailability([int id]);

  Future prompt();

  Future<int> watchAvailability(RemotePlaybackAvailabilityCallback callback);
}

@Native('SourceBuffer')
class SourceBuffer extends EventTarget {
  static const EventStreamProvider<Event> abortEvent =
      EventStreamProvider<Event>('abort');

  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  factory SourceBuffer._() {
    return _SourceBufferImpl();
  }

  SourceBuffer.internal() : super.internal();

  num? get appendWindowEnd {
    return 0;
  }

  set appendWindowEnd(num? value) {
    // No-op in fallback mode.
  }

  num? get appendWindowStart {
    return 0;
  }

  set appendWindowStart(num? value) {
    // No-op in fallback mode.
  }

  List<AudioTrack>? get audioTracks {
    return const <AudioTrack>[];
  }

  TimeRanges? get buffered {
    return TimeRanges._();
  }

  String? get mode {
    return 'segments';
  }

  set mode(String? value) {
    // No-op in fallback mode.
  }

  Stream<Event> get onAbort => abortEvent.forTarget(this);

  Stream<Event> get onError => errorEvent.forTarget(this);

  num? get timestampOffset {
    return 0;
  }

  set timestampOffset(num? value) {
    // No-op in fallback mode.
  }

  List<TrackDefault>? get trackDefaults {
    return const <TrackDefault>[];
  }

  set trackDefaults(List<TrackDefault>? value) {
    // No-op in fallback mode.
  }

  bool? get updating {
    return false;
  }

  List<VideoTrack>? get videoTracks {
    return const <VideoTrack>[];
  }

  void abort() {
    // No-op in fallback mode.
  }

  void appendBuffer(ByteBuffer data) {
    // No-op in fallback mode.
  }

  @JSName('appendBuffer')
  void appendTypedData(TypedData data) {
    // No-op in fallback mode.
  }

  void remove(num start, num end) {
    // No-op in fallback mode.
  }
}

class TextTrack {
  TextTrack._();
}

abstract class TimeRanges {
  factory TimeRanges._() {
    return const _TimeRangesImpl();
  }

  int get length;

  double end(int index);

  double start(int index);
}

@Native('TrackDefault')
class TrackDefault {
  factory TrackDefault(
    String type,
    String language,
    String label,
    List<String> kinds, [
    String? byteStreamTrackID,
  ]) {
    return _TrackDefaultImpl(type, language, label, kinds, byteStreamTrackID);
  }

  String? get byteStreamTrackID {
    return null;
  }

  Object? get kinds {
    return const <String>[];
  }

  String? get label {
    return null;
  }

  String? get language {
    return null;
  }

  String? get type {
    return null;
  }
}

class VideoPlaybackQuality {
  VideoPlaybackQuality._();
}

@Native('VideoTrack')
class VideoTrack {
  factory VideoTrack._() {
    return _VideoTrackImpl();
  }

  String? get id {
    return null;
  }

  String? get kind {
    return null;
  }

  String? get label {
    return null;
  }

  String? get language {
    return null;
  }

  bool? get selected {
    return false;
  }

  set selected(bool? value) {
    // No-op in fallback mode.
  }

  SourceBuffer? get sourceBuffer {
    return null;
  }
}

class _ImageBitmapImpl implements ImageBitmap {
  _ImageBitmapImpl();
}

class _ImageCaptureImpl implements ImageCapture {
  final MediaStreamTrack track;

  _ImageCaptureImpl(this.track);

  @override
  Future<PhotoCapabilities> getPhotoCapabilities() =>
      Future<PhotoCapabilities>.value(_PhotoCapabilitiesImpl());

  @override
  Future<Map<String, dynamic>> getPhotoSettings() =>
      Future<Map<String, dynamic>>.value(const <String, dynamic>{});

  @override
  Future<ImageBitmap> grabFrame() =>
      Future<ImageBitmap>.value(_ImageBitmapImpl());

  @override
  Future setOptions(Map photoSettings) => Future.value();

  @override
  Future takePhoto([Map photoSettings = const <String, dynamic>{}]) =>
      Future<Blob>.value(Blob(const <Object>[]));
}

class _MediaDevicesImpl extends MediaDevices {
  _MediaDevicesImpl() : super.internal();
}

class _MediaErrorImpl implements MediaError {
  const _MediaErrorImpl();

  @override
  int get code => MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED;

  @override
  String? get message => '';
}

class _MediaKeysImpl implements MediaKeys {
  @override
  Future getStatusForPolicy(MediaKeysPolicy policy) => Future.value('usable');

  @override
  Future setServerCertificate(dynamic serverCertificate) => Future.value(true);
}

class _MediaKeysPolicyImpl implements MediaKeysPolicy {
  final Map _init;

  _MediaKeysPolicyImpl(this._init);

  @override
  String? get minHdcpVersion => _init['minHdcpVersion'] as String?;
}

class _MediaRecorderImpl extends MediaRecorder {
  final MediaStream? _stream;
  String _state = 'inactive';

  _MediaRecorderImpl(MediaStream stream, Map? options)
      : _stream = stream,
        super.internal();

  @override
  String? get state => _state;

  @override
  MediaStream? get stream => _stream;

  @override
  void pause() {
    _state = 'paused';
  }

  @override
  void resume() {
    _state = 'recording';
  }

  @override
  void start([int? timeslice]) {
    _state = 'recording';
  }

  @override
  void stop() {
    _state = 'inactive';
  }
}

class _MediaSessionImpl implements MediaSession {
  MediaMetadata? _metadata;
  String? _playbackState = 'none';

  @override
  MediaMetadata? get metadata => _metadata;

  @override
  set metadata(MediaMetadata? value) {
    _metadata = value;
  }

  @override
  String? get playbackState => _playbackState;

  @override
  set playbackState(String? value) {
    _playbackState = value;
  }

  @override
  void setActionHandler(String action, MediaSessionActionHandler? handler) {}
}

class _MediaSourceImpl extends MediaSource {
  final List<SourceBuffer> _sourceBuffers = <SourceBuffer>[];
  num _duration = 0;

  _MediaSourceImpl() : super.internal();

  @override
  List<SourceBuffer>? get activeSourceBuffers =>
      List<SourceBuffer>.unmodifiable(_sourceBuffers);

  @override
  num? get duration => _duration;

  @override
  set duration(num? value) {
    _duration = value ?? 0;
  }

  @override
  String? get readyState => 'open';

  @override
  List<SourceBuffer>? get sourceBuffers =>
      List<SourceBuffer>.unmodifiable(_sourceBuffers);

  @override
  SourceBuffer addSourceBuffer(String type) {
    final buffer = SourceBuffer._();
    _sourceBuffers.add(buffer);
    return buffer;
  }

  @override
  void removeSourceBuffer(SourceBuffer buffer) {
    _sourceBuffers.remove(buffer);
  }
}

class _MediaStreamImpl extends EventTarget implements MediaStream {
  final List<MediaStreamTrack> _tracks;
  final String _id = 'media-stream';

  _MediaStreamImpl(this._tracks) : super.internal();

  factory _MediaStreamImpl.from(dynamic streamOrTracks) {
    if (streamOrTracks is MediaStream) {
      return _MediaStreamImpl(streamOrTracks.getTracks());
    }
    if (streamOrTracks is List<MediaStreamTrack>) {
      return _MediaStreamImpl(List<MediaStreamTrack>.from(streamOrTracks));
    }
    return _MediaStreamImpl(<MediaStreamTrack>[]);
  }

  @override
  bool get active => _tracks.isNotEmpty;

  @override
  String get id => _id;

  @override
  Stream<Event> get onAddTrack => MediaStream.addTrackEvent.forTarget(this);

  @override
  Stream<Event> get onRemoveTrack =>
      MediaStream.removeTrackEvent.forTarget(this);

  @override
  void addTrack(MediaStreamTrack track) {
    _tracks.add(track);
  }

  @override
  MediaStream clone() => _MediaStreamImpl(List<MediaStreamTrack>.from(_tracks));

  @override
  List<MediaStreamTrack> getAudioTracks() =>
      _tracks.where((track) => track.kind == 'audio').toList(growable: false);

  @override
  MediaStreamTrack getTrackById(String trackId) =>
      _tracks.firstWhere((track) => track.id == trackId,
          orElse: () => _MediaStreamTrackImpl(trackId, 'unknown'));

  @override
  List<MediaStreamTrack> getTracks() =>
      List<MediaStreamTrack>.unmodifiable(_tracks);

  @override
  List<MediaStreamTrack> getVideoTracks() =>
      _tracks.where((track) => track.kind == 'video').toList(growable: false);

  @override
  void removeTrack(MediaStreamTrack track) {
    _tracks.remove(track);
  }
}

class _MediaStreamTrackImpl extends MediaStreamTrack {
  @override
  final String id;

  @override
  final String kind;

  @override
  String get label => '';

  @override
  bool get muted => false;

  @override
  String get readyState => 'live';

  _MediaStreamTrackImpl(this.id, this.kind) : super._();
}

class _MediaStreamTrackEventImpl extends Event
    implements MediaStreamTrackEvent {
  final MediaStreamTrack _track;

  _MediaStreamTrackEventImpl(super.type, Map eventInitDict)
      : _track = eventInitDict['track'] as MediaStreamTrack? ??
            _MediaStreamTrackImpl('track', 'unknown'),
        super.internal();

  @override
  MediaStreamTrack get track => _track;
}

class _MediaSettingsRangeImpl implements MediaSettingsRange {
  @override
  num get max => 0;

  @override
  num get min => 0;

  @override
  num get step => 1;

  const _MediaSettingsRangeImpl();
}

class _PhotoCapabilitiesImpl implements PhotoCapabilities {
  @override
  List get fillLightMode => const <String>[];

  @override
  MediaSettingsRange get imageHeight => const _MediaSettingsRangeImpl();

  @override
  MediaSettingsRange get imageWidth => const _MediaSettingsRangeImpl();

  @override
  String get redEyeReduction => 'never';
}

class _RemotePlaybackImpl extends EventTarget implements RemotePlayback {
  _RemotePlaybackImpl() : super.internal();

  @override
  String get state => 'disconnected';

  @override
  Future cancelWatchAvailability([int? id]) => Future.value();

  @override
  Future prompt() => Future.value();

  @override
  Future<int> watchAvailability(
      RemotePlaybackAvailabilityCallback callback) async {
    callback(false);
    return 0;
  }
}

class _SourceBufferImpl extends SourceBuffer {
  _SourceBufferImpl() : super.internal();
}

class _TimeRangesImpl implements TimeRanges {
  const _TimeRangesImpl();

  @override
  int get length => 0;

  @override
  double end(int index) => 0;

  @override
  double start(int index) => 0;
}

class _TrackDefaultImpl implements TrackDefault {
  final String _type;
  final String _language;
  final String _label;
  final List<String> _kinds;
  final String? _byteStreamTrackID;

  _TrackDefaultImpl(
    this._type,
    this._language,
    this._label,
    this._kinds,
    this._byteStreamTrackID,
  );

  @override
  String? get byteStreamTrackID => _byteStreamTrackID;

  @override
  Object? get kinds => List<String>.unmodifiable(_kinds);

  @override
  String? get label => _label;

  @override
  String? get language => _language;

  @override
  String? get type => _type;
}

class _VideoTrackImpl implements VideoTrack {
  bool _selected = false;

  @override
  String? get id => null;

  @override
  String? get kind => null;

  @override
  String? get label => null;

  @override
  String? get language => null;

  @override
  bool? get selected => _selected;

  @override
  set selected(bool? value) {
    _selected = value ?? false;
  }

  @override
  SourceBuffer? get sourceBuffer => null;
}
