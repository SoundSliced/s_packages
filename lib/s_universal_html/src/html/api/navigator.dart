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
  'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
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

class Navigator extends NavigatorConcurrentHardware
    implements
        NavigatorCookies,
        NavigatorLanguage,
        NavigatorOnLine,
        NavigatorAutomationInformation,
        NavigatorID {
  final num? deviceMemory;

  @Unstable()
  late Geolocation geolocation = Geolocation.internal();

  @Unstable()
  final String? productSub;
  final bool? _cookieEnabled;
  final List<String> _languages;
  final bool? _onLine;
  final String _userAgent;
  final String _vendor;
  final String _vendorSub;
  final String? _doNotTrack;
  final int? _maxTouchPoints;

  final Window internalWindow;

  @override
  final String appName;

  @override
  final String appVersion;

  @override
  final String appCodeName;

  @override
  final String platform;

  @override
  final String product;

  /// Internal constructor. NOT part of "dart:html".
  Navigator.internal({
    required this.internalWindow,
    this.deviceMemory,
    this.appCodeName = '',
    this.appName = 'Netscape',
    this.appVersion = '5.0',
    this.platform = 'Win32',
    this.product = 'Gecko',
    this.productSub = '20030107',
    bool? cookieEnabled,
    List<String> languages = const <String>[],
    bool? onLine,
    String userAgent = '-',
    String vendor = '-',
    String vendorSub = '',
    String? doNotTrack,
    int? maxTouchPoints,
  })  : _cookieEnabled = cookieEnabled,
        _languages = languages,
        _onLine = onLine,
        _userAgent = userAgent,
        _vendor = vendor,
        _vendorSub = vendorSub,
        _doNotTrack = doNotTrack,
        _maxTouchPoints = maxTouchPoints,
        super._();

  BudgetService? get budget => null;

  Clipboard? get clipboard => null;

  NetworkInformation? get connection => null;

  @Unstable()
  @override
  bool? get cookieEnabled => _cookieEnabled ?? false;

  CredentialsContainer? get credentials => null;

  @override
  bool get dartEnabled => false;

  String? get doNotTrack => _doNotTrack;

  @override
  String? get language {
    final languages = this.languages;
    return languages.isEmpty ? null : languages.first;
  }

  @override
  List<String> get languages => List<String>.unmodifiable(_languages);

  int? get maxTouchPoints => _maxTouchPoints;

  MediaCapabilities? get mediaCapabilities => null;

  MediaDevices? get mediaDevices => null;

  MediaSession? get mediaSession => null;

  List<MimeType>? get mimeTypes => null;

  NFC? get nfc => null;

  @override
  bool get onLine => _onLine ?? false;

  Permissions? get permissions => null;

  Presentation? get presentation => null;

  ServiceWorkerContainer? get serviceWorker => null;

  StorageManager? get storage => null;

  @override
  String get userAgent => _userAgent;

  @Unstable()
  String get vendor => _vendor;

  @Unstable()
  String get vendorSub => _vendorSub;

  VR? get vr => null;

  @override
  bool? get webdriver => null;

  void cancelKeyboardLock() {
    // Ignore
  }

  Future getBattery() => Future<bool>.value(false);

  List<Gamepad> getGamepads() => const <Gamepad>[];

  Future<RelatedApplication> getInstalledRelatedApps() {
    return Future.error(UnimplementedError());
  }

  /// Gets a stream (video and or audio) from the local computer.
  ///
  /// Use [MediaStream.supported] to check if this is supported by the current
  /// platform. The arguments `audio` and `video` default to `false` (stream does
  /// not use audio or video, respectively).
  ///
  /// Simple example usage:
  ///
  ///     window.navigator.getUserMedia(audio: true, video: true).then((stream) {
  ///       var video = new VideoElement()
  ///         ..autoplay = true
  ///         ..src = Url.createObjectUrlFromStream(stream);
  ///       document.body.append(video);
  ///     });
  ///
  /// The user can also pass in Maps to the audio or video parameters to specify
  /// mandatory and optional constraints for the media stream. Not passing in a
  /// map, but passing in `true` will provide a MediaStream with audio or
  /// video capabilities, but without any additional constraints. The particular
  /// constraint names for audio and video are still in flux, but as of this
  /// writing, here is an example providing more constraints.
  ///
  ///     window.navigator.getUserMedia(
  ///         audio: true,
  ///         video: {'mandatory':
  ///                    { 'minAspectRatio': 1.333, 'maxAspectRatio': 1.334 },
  ///                 'optional':
  ///                    [{ 'minFrameRate': 60 },
  ///                     { 'maxWidth': 640 }]
  ///     });
  ///
  /// See also:
  /// * [MediaStream.supported]
  Future<MediaStream> getUserMedia(
      {dynamic audio = false, dynamic video = false}) {
    return Future.error(UnimplementedError());
  }

  Future getVRDisplays() {
    return Future<List<Object>>.value(const <Object>[]);
  }

  void registerProtocolHandler(String scheme, String url, String title) {
    // Ignore
  }

  Future requestKeyboardLock([List<String>? keyCodes]) {
    return Future.error(UnimplementedError());
  }

  Future requestMediaKeySystemAccess(
      String keySystem, List<Map> supportedConfigurations) {
    return Future.error(UnimplementedError());
  }

  Future requestMidiAccess([Map? options]) => Future.value(null);

  bool sendBeacon(String url, Object data) {
    // Send beacon later
    _sendBeacon(url, data);

    // Return true
    return true;
  }

  Future share([Map? data]) {
    return Future.value();
  }

  Future<void> _sendBeacon(String url, Object data) async {
    await HttpRequest.request(url, method: 'POST', sendData: data);
  }
}
