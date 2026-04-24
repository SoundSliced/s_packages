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

typedef MediaSessionActionHandler = void Function();

typedef StorageErrorCallback = void Function(DomError error);

typedef StorageQuotaCallback = void Function(int grantedQuotaInBytes);

typedef StorageUsageCallback = void Function(
    int currentUsageInBytes, int currentQuotaInBytes);

class BudgetService {
  factory BudgetService._() {
    return _BudgetServiceImpl();
  }

  Future<BudgetState> getBudget() => Future<BudgetState>.value(BudgetState._());

  Future<double> getCost(String operation) => Future<double>.value(0);

  Future<bool> reserve(String operation) => Future<bool>.value(false);
}

@Native('BudgetState')
class BudgetState {
  factory BudgetState._() {
    return const _BudgetStateImpl();
  }

  num? get budgetAt => 0;

  int? get time => 0;
}

abstract class Clipboard implements EventTarget {
  Clipboard._();

  Future<DataTransfer> read() => Future<DataTransfer>.error(
      UnsupportedError('Clipboard.read is unavailable on this platform.'));

  Future<String> readText() => Future<String>.value('');

  Future write(DataTransfer data) => Future.value();

  Future writeText(String data) => Future.value();
}

abstract class Credential {
  Credential._();

  String get id;

  String get type;
}

abstract class CredentialsContainer {
  CredentialsContainer._();

  Future create([Map? options]);

  Future get([Map? options]);

  Future preventSilentAccess();

  Future requireUserMediation();

  Future store(Credential credential);
}

abstract class Gamepad {
  Gamepad._();

  List<num>? get axes;

  List<GamepadButton>? get buttons;

  bool? get connected;

  int? get displayId;

  String? get hand;

  String? get id;

  int? get index;

  String? get mapping;

  GamepadPose? get pose;

  int? get timestamp;
}

abstract class GamepadButton {
  GamepadButton._();

  bool? get pressed;

  bool? get touched;

  num? get value;
}

abstract class GamepadPose {
  GamepadPose._();

  Float32List? get angularAcceleration;

  Float32List? get angularVelocity;

  bool? get hasOrientation;

  bool? get hasPosition;

  Float32List? get linearAcceleration;

  Float32List? get linearVelocity;

  Float32List? get orientation;

  Float32List? get position;
}

abstract class MediaCapabilities {
  MediaCapabilities._();

  Future<MediaCapabilitiesInfo> decodingInfo(Map configuration);

  Future<MediaCapabilitiesInfo> encodingInfo(Map configuration);
}

abstract class MediaCapabilitiesInfo {
  MediaCapabilitiesInfo._();

  bool get powerEfficient;

  bool get smooth;

  bool get supported;
}

abstract class MediaMetadata {
  String? album;

  String? artist;

  List? artwork;

  String? title;

  factory MediaMetadata([Map? metadata]) {
    return _MediaMetadataImpl(metadata);
  }
}

abstract class MimeType {
  MimeType._();

  String? get description;

  Plugin? get enabledPlugin;

  String? get suffixes;

  String? get type;
}

abstract class NavigatorAutomationInformation {
  NavigatorAutomationInformation._();

  bool? get webdriver;
}

abstract class NavigatorConcurrentHardware {
  NavigatorConcurrentHardware._();

  int? get hardwareConcurrency => 1;
}

abstract class NavigatorCookies {
  NavigatorCookies._();

  bool? get cookieEnabled;
}

abstract class NavigatorID {
  NavigatorID._();

  String get appCodeName;

  String get appName;

  String get appVersion;

  bool? get dartEnabled;

  String? get platform;

  String get product;

  String get userAgent;
}

abstract class NavigatorLanguage {
  NavigatorLanguage._();

  String? get language;

  List<String>? get languages;
}

abstract class NavigatorOnLine {
  NavigatorOnLine._();

  bool? get onLine;
}

abstract class NetworkInformation implements EventTarget {
  static const EventStreamProvider<Event> changeEvent =
      EventStreamProvider<Event>('change');

  NetworkInformation._();

  num? get downlink;

  num? get downlinkMax;

  String? get effectiveType;

  Stream<Event> get onChange => changeEvent.forTarget(this);

  int? get rtt;

  String? get type;
}

@Native('NFC')
abstract class NFC {
  factory NFC._() {
    return _NfcImpl();
  }
}

abstract class Plugin {
  Plugin._();

  String? get description;

  String? get filename;

  int? get length;

  String? get name;

  MimeType item(int index);

  MimeType namedItem(String name);
}

abstract class Presentation {
  PresentationRequest? defaultRequest;

  Presentation._();

  PresentationReceiver? get receiver;
}

abstract class PresentationAvailability implements EventTarget {
  static const EventStreamProvider<Event> changeEvent =
      EventStreamProvider<Event>('change');

  PresentationAvailability._();

  Stream<Event> get onChange;

  bool? get value;
}

abstract class PresentationConnection extends EventTarget {
  static const EventStreamProvider<MessageEvent> messageEvent =
      EventStreamProvider<MessageEvent>('message');

  String? binaryType;

  factory PresentationConnection._() {
    return _PresentationConnectionImpl();
  }

  String? get id;

  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  String? get state;

  String? get url;

  void close() {
    binaryType = null;
  }

  void send(dynamic dataOrMessage) {
    // No-op in fallback mode.
  }

  void terminate() {
    binaryType = null;
  }
}

abstract class PresentationConnectionAvailableEvent extends Event {
  factory PresentationConnectionAvailableEvent(String type, Map eventInitDict) {
    return _PresentationConnectionAvailableEventImpl(type, eventInitDict);
  }

  PresentationConnection get connection;
}

abstract class PresentationConnectionCloseEvent extends Event {
  factory PresentationConnectionCloseEvent(String type, Map eventInitDict) {
    return _PresentationConnectionCloseEventImpl(type, eventInitDict);
  }

  String? get message;

  String? get reason;
}

abstract class PresentationConnectionList extends EventTarget {
  factory PresentationConnectionList._() {
    return _PresentationConnectionListImpl();
  }

  List<PresentationConnection> get connections;
}

class PresentationReceiver {
  factory PresentationReceiver._() {
    return _PresentationReceiverImpl();
  }

  Future<PresentationConnectionList> get connectionList =>
      Future<PresentationConnectionList>.value(PresentationConnectionList._());
}

class PresentationRequest extends EventTarget {
  PresentationRequest.internal() : super.internal();

  factory PresentationRequest(dynamic urlOrUrls) {
    return _PresentationRequestImpl(urlOrUrls);
  }

  Future<PresentationAvailability> getAvailability() =>
      Future<PresentationAvailability>.value(_PresentationAvailabilityImpl());

  Future<PresentationConnection> reconnect(String id) =>
      Future<PresentationConnection>.value(PresentationConnection._());

  Future<PresentationConnection> start() =>
      Future<PresentationConnection>.value(PresentationConnection._());
}

class _BudgetServiceImpl implements BudgetService {
  @override
  Future<BudgetState> getBudget() => Future<BudgetState>.value(BudgetState._());

  @override
  Future<double> getCost(String operation) => Future<double>.value(0);

  @override
  Future<bool> reserve(String operation) => Future<bool>.value(false);
}

class _BudgetStateImpl implements BudgetState {
  const _BudgetStateImpl();

  @override
  num? get budgetAt => 0;

  @override
  int? get time => 0;
}

class _MediaMetadataImpl implements MediaMetadata {
  @override
  String? album;

  @override
  String? artist;

  @override
  List? artwork;

  @override
  String? title;

  _MediaMetadataImpl(Map? metadata) {
    album = metadata?['album'] as String?;
    artist = metadata?['artist'] as String?;
    artwork = metadata?['artwork'] as List?;
    title = metadata?['title'] as String?;
  }
}

class _NfcImpl implements NFC {}

class _PresentationConnectionImpl extends EventTarget
    implements PresentationConnection {
  @override
  String? binaryType;

  _PresentationConnectionImpl() : super.internal();

  @override
  String? get id => null;

  @override
  Stream<MessageEvent> get onMessage =>
      PresentationConnection.messageEvent.forTarget(this);

  @override
  String? get state => 'closed';

  @override
  String? get url => null;

  @override
  void close() {
    binaryType = null;
  }

  @override
  void send(dynamic dataOrMessage) {
    // No-op in fallback mode.
  }

  @override
  void terminate() {
    binaryType = null;
  }
}

class _PresentationConnectionAvailableEventImpl extends Event
    implements PresentationConnectionAvailableEvent {
  final PresentationConnection _connection;

  _PresentationConnectionAvailableEventImpl(super.type, Map eventInitDict)
      : _connection =
            (eventInitDict['connection'] as PresentationConnection?) ??
                PresentationConnection._(),
        super.internal();

  @override
  PresentationConnection get connection => _connection;
}

class _PresentationConnectionCloseEventImpl extends Event
    implements PresentationConnectionCloseEvent {
  final String? _message;
  final String? _reason;

  _PresentationConnectionCloseEventImpl(super.type, Map eventInitDict)
      : _message = eventInitDict['message'] as String?,
        _reason = eventInitDict['reason'] as String?,
        super.internal();

  @override
  String? get message => _message;

  @override
  String? get reason => _reason;
}

class _PresentationConnectionListImpl extends EventTarget
    implements PresentationConnectionList {
  final List<PresentationConnection> _connections;

  _PresentationConnectionListImpl([List<PresentationConnection>? connections])
      : _connections = connections ?? <PresentationConnection>[],
        super.internal();

  @override
  List<PresentationConnection> get connections =>
      List<PresentationConnection>.unmodifiable(_connections);
}

class _PresentationReceiverImpl implements PresentationReceiver {
  @override
  Future<PresentationConnectionList> get connectionList =>
      Future<PresentationConnectionList>.value(
          _PresentationConnectionListImpl());
}

class _PresentationAvailabilityImpl extends EventTarget
    implements PresentationAvailability {
  _PresentationAvailabilityImpl() : super.internal();

  @override
  Stream<Event> get onChange =>
      PresentationAvailability.changeEvent.forTarget(this);

  @override
  bool? get value => false;
}

class _PresentationRequestImpl extends PresentationRequest {
  _PresentationRequestImpl(dynamic urlOrUrls) : super.internal();

  @override
  Future<PresentationAvailability> getAvailability() =>
      Future<PresentationAvailability>.value(_PresentationAvailabilityImpl());

  @override
  Future<PresentationConnection> reconnect(String id) =>
      Future<PresentationConnection>.value(PresentationConnection._());

  @override
  Future<PresentationConnection> start() =>
      Future<PresentationConnection>.value(PresentationConnection._());
}

abstract class RelatedApplication {
  RelatedApplication._();

  String? get id;

  String? get platform;

  String? get url;
}

abstract class StorageManager {
  StorageManager._();

  Future<Map<String, dynamic>> estimate();

  Future<bool> persist();

  Future<bool> persisted();
}

abstract class VR implements EventTarget {
  VR._();

  Future getDevices();
}
