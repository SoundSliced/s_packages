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

abstract class AbstractWorker implements EventTarget {
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  factory AbstractWorker._() {
    throw UnsupportedError('AbstractWorker is not available outside a browser context.');
  }

  /// Stream of `error` events handled by this [AbstractWorker].
  Stream<Event> get onError => errorEvent.forTarget(this);
}

@Native('BackgroundFetchFetch')
class BackgroundFetchFetch {
  factory BackgroundFetchFetch._() {
    throw UnsupportedError('BackgroundFetchFetch is not available outside a browser context.');
  }

  Request? get request => null;
}

class BackgroundFetchManager {
  factory BackgroundFetchManager._() {
    throw UnsupportedError('BackgroundFetchManager is not available outside a browser context.');
  }

  Future<BackgroundFetchRegistration> fetch(
    String id,
    Object requests, [
    Map? options,
  ]) =>
      Future.error(UnsupportedError('Background fetch is not available outside a browser context.'));

  Future<BackgroundFetchRegistration> get(String id) =>
      Future.error(UnsupportedError('Background fetch is not available outside a browser context.'));

  Future<List<String>> getIds() => Future.value([]);
}

@Native('BackgroundFetchRegistration')
class BackgroundFetchRegistration extends EventTarget {
  factory BackgroundFetchRegistration._() {
    throw UnsupportedError('BackgroundFetchRegistration is not available outside a browser context.');
  }

  int? get downloaded => null;

  int? get downloadTotal => null;

  String? get id => null;

  String? get title => null;

  int? get totalDownloadSize => null;

  int? get uploaded => null;

  int? get uploadTotal => null;

  Future<bool> abort() => Future.value(false);
}

class BackgroundFetchSettledFetch extends BackgroundFetchFetch {
  factory BackgroundFetchSettledFetch(Request request, Response response) {
    throw UnsupportedError('BackgroundFetchSettledFetch is not available outside a browser context.');
  }

  Response? get response => null;
}

abstract class Body {
  factory Body._() {
    throw UnsupportedError('Body is not available outside a browser context.');
  }

  bool? get bodyUsed => null;

  Future arrayBuffer() =>
      Future.error(UnsupportedError('Body.arrayBuffer() is not available outside a browser context.'));

  Future<Blob> blob() =>
      Future.error(UnsupportedError('Body.blob() is not available outside a browser context.'));

  Future<FormData> formData() =>
      Future.error(UnsupportedError('Body.formData() is not available outside a browser context.'));

  Future json() =>
      Future.error(UnsupportedError('Body.json() is not available outside a browser context.'));

  Future<String> text() =>
      Future.error(UnsupportedError('Body.text() is not available outside a browser context.'));
}

abstract class Client {
  factory Client._() {
    throw UnsupportedError('Client is not available outside a browser context.');
  }

  String? get frameType;

  String? get id;

  String? get type;

  String? get url;

  void postMessage(Object message, [List<Object>? transfer]) {}
}

class Clients {
  factory Clients._() {
    throw UnsupportedError('Clients is not available outside a browser context.');
  }

  Future claim() =>
      Future.error(UnsupportedError('Clients is not available outside a browser context.'));

  Future get(String id) =>
      Future.error(UnsupportedError('Clients is not available outside a browser context.'));

  Future<List<Client>> matchAll([Map? options]) => Future.value([]);

  Future<WindowClient> openWindow(String url) =>
      Future.error(UnsupportedError('Cannot open window outside a browser context.'));
}

abstract class ForeignFetchEvent extends ExtendableEvent {
  factory ForeignFetchEvent(String type, Map eventInitDict) {
    throw UnsupportedError('ForeignFetchEvent is not available outside a browser context.');
  }

  String? get origin;

  // final _Request request;

  void respondWith(Future r) {}
}

class FormData {
  /// Checks if this type is supported on the current platform.
  static bool get supported => false;

  final _data = <String, List<Object>>{};

  factory FormData([FormElement? form]) => FormData._internal();

  FormData._internal();

  void append(String name, String value) =>
      (_data[name] ??= []).add(value);

  void appendBlob(String name, Blob value, [String? filename]) =>
      (_data[name] ??= []).add(value);

  void delete(String name) => _data.remove(name);

  Object? get(String name) => _data[name]?.first;

  List<Object> getAll(String name) => _data[name] ?? [];

  bool has(String name) => _data.containsKey(name);

  void set(String name, value, [String? filename]) =>
      _data[name] = [value];
}

class Headers {
  factory Headers([Object? init]) => Headers._internal();

  Headers._internal();
}

class NavigationPreloadManager {
  factory NavigationPreloadManager._() {
    throw UnsupportedError('NavigationPreloadManager is not available outside a browser context.');
  }

  Future disable() =>
      Future.error(UnsupportedError('NavigationPreloadManager is not available outside a browser context.'));

  Future enable() =>
      Future.error(UnsupportedError('NavigationPreloadManager is not available outside a browser context.'));

  Future<Map<String, dynamic>> getState() =>
      Future.error(UnsupportedError('NavigationPreloadManager is not available outside a browser context.'));
}

abstract class PushManager {
  static final List<String> supportedContentEncodings = <String>[];

  factory PushManager._() {
    throw UnsupportedError('PushManager is not available outside a browser context.');
  }

  Future<PushSubscription> getSubscription() =>
      Future.error(UnsupportedError('Push is not available outside a browser context.'));

  Future permissionState([Map? options]) =>
      Future.error(UnsupportedError('Push is not available outside a browser context.'));

  Future<PushSubscription> subscribe([Map? options]) =>
      Future.error(UnsupportedError('Push is not available outside a browser context.'));
}

class PushMessageData {
  factory PushMessageData._() {
    throw UnsupportedError('PushMessageData is not available outside a browser context.');
  }

  ByteBuffer arrayBuffer() =>
      throw UnsupportedError('Push is not available outside a browser context.');

  Blob blob() =>
      throw UnsupportedError('Push is not available outside a browser context.');

  Object json() =>
      throw UnsupportedError('Push is not available outside a browser context.');

  String text() =>
      throw UnsupportedError('Push is not available outside a browser context.');
}

abstract class PushSubscription {
  factory PushSubscription._() {
    throw UnsupportedError('PushSubscription is not available outside a browser context.');
  }

  String get endpoint;

  int get expirationTime;

  PushSubscriptionOptions get options;

  ByteBuffer getKey(String name) =>
      throw UnsupportedError('Push is not available outside a browser context.');

  Future<bool> unsubscribe() => Future.value(false);
}

abstract class PushSubscriptionOptions {
  factory PushSubscriptionOptions._() {
    throw UnsupportedError('PushSubscriptionOptions is not available outside a browser context.');
  }

  ByteBuffer get applicationServerKey;

  bool get userVisibleOnly;
}

@Native('Request')
class Request extends Body {
  factory Request() {
    throw UnsupportedError('Request is not available outside a browser context.');
  }

  String? get cache => null;

  String? get credentials => null;

  Headers? get headers => null;

  String? get integrity => null;

  String? get mode => null;

  String? get redirect => null;

  String? get referrer => null;

  String? get referrerPolicy => null;

  String? get url => null;

  Request clone() => throw UnsupportedError('Request.clone() is not available outside a browser context.');
}

@Native('Response')
abstract class Response extends Body {
  factory Response() {
    throw UnsupportedError('Response is not available outside a browser context.');
  }
}

@Native('ServiceWorker')
class ServiceWorker extends EventTarget implements AbstractWorker {
  // To suppress missing implicit constructor warnings.
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  factory ServiceWorker._() {
    throw UnsupportedError('ServiceWorker is not available outside a browser context.');
  }

  @override
  Stream<Event> get onError => errorEvent.forTarget(this);

  @JSName('scriptURL')
  String? get scriptUrl => null;

  String? get state => null;

  void postMessage(dynamic message, [List<Object>? transfer]) {}
}

@Native('ServiceWorkerContainer')
class ServiceWorkerContainer extends EventTarget {
  // To suppress missing implicit constructor warnings.
  static const EventStreamProvider<MessageEvent> messageEvent =
      EventStreamProvider<MessageEvent>('message');

  factory ServiceWorkerContainer._() {
    throw UnsupportedError('ServiceWorkerContainer is not available outside a browser context.');
  }

  ServiceWorker? get controller => null;

  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  Future<ServiceWorkerRegistration> get ready =>
      Future.error(UnsupportedError('Service workers are not available outside a browser context.'));

  Future<ServiceWorkerRegistration> getRegistration([String? documentURL]) =>
      Future.error(UnsupportedError('Service workers are not available outside a browser context.'));

  Future<List<dynamic>> getRegistrations() =>
      Future.error(UnsupportedError('Service workers are not available outside a browser context.'));

  Future<ServiceWorkerRegistration> register(String url, [Map? options]) =>
      Future.error(UnsupportedError('Service workers are not available outside a browser context.'));
}

@Native('ServiceWorkerGlobalScope')
class ServiceWorkerGlobalScope extends WorkerGlobalScope {
  // To suppress missing implicit constructor warnings.
  static const EventStreamProvider<Event> activateEvent =
      EventStreamProvider<Event>('activate');

  static const EventStreamProvider<Event> fetchEvent =
      EventStreamProvider<Event>('fetch');

  static const EventStreamProvider<ForeignFetchEvent> foreignfetchEvent =
      EventStreamProvider<ForeignFetchEvent>('foreignfetch');

  static const EventStreamProvider<Event> installEvent =
      EventStreamProvider<Event>('install');

  static const EventStreamProvider<MessageEvent> messageEvent =
      EventStreamProvider<MessageEvent>('message');

  static ServiceWorkerGlobalScope get instance =>
      throw UnsupportedError('ServiceWorkerGlobalScope is not available outside a browser context.');

  factory ServiceWorkerGlobalScope._() {
    throw UnsupportedError('ServiceWorkerGlobalScope is not available outside a browser context.');
  }

  Clients? get clients => null;

  Stream<Event> get onActivate => activateEvent.forTarget(this);

  Stream<Event> get onFetch => fetchEvent.forTarget(this);

  Stream<ForeignFetchEvent> get onForeignfetch =>
      foreignfetchEvent.forTarget(this);

  Stream<Event> get onInstall => installEvent.forTarget(this);

  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  ServiceWorkerRegistration? get registration => null;

  Future skipWaiting() => Future.value();
}

@Native('ServiceWorkerRegistration')
class ServiceWorkerRegistration extends EventTarget {
  // To suppress missing implicit constructor warnings.
  factory ServiceWorkerRegistration._() {
    throw UnsupportedError('ServiceWorkerRegistration is not available outside a browser context.');
  }

  ServiceWorker? get active => null;

  BackgroundFetchManager? get backgroundFetch => null;

  ServiceWorker? get installing => null;

  NavigationPreloadManager? get navigationPreload => null;

  PaymentManager? get paymentManager => null;

  PushManager? get pushManager => null;

  String? get scope => null;

  SyncManager? get sync => null;

  ServiceWorker? get waiting => null;

  Future<List<dynamic>> getNotifications([Map? filter]) => Future.value([]);

  Future showNotification(String title, [Map? options]) => Future.value();

  Future<bool> unregister() => Future.value(false);

  Future update() => Future.value();
}

abstract class SyncManager {
  factory SyncManager._() {
    throw UnsupportedError('SyncManager is not available outside a browser context.');
  }

  Future<List<String>> getTags() => Future.value([]);

  Future register(String tag) =>
      Future.error(UnsupportedError('Background sync is not available outside a browser context.'));
}

abstract class WindowClient extends Client {
  factory WindowClient._() {
    throw UnsupportedError('WindowClient is not available outside a browser context.');
  }

  bool get focused;

  String get visibilityState;

  Future<WindowClient> focus() =>
      Future.error(UnsupportedError('WindowClient is not available outside a browser context.'));

  Future<WindowClient> navigate(String url) =>
      Future.error(UnsupportedError('WindowClient is not available outside a browser context.'));
}

@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
@Native('Worker')
class Worker extends EventTarget implements AbstractWorker {
  // To suppress missing implicit constructor warnings.
  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [Worker].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  /// Static factory designed to expose `message` events to event
  /// handlers that are not necessarily instances of [Worker].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<MessageEvent> messageEvent =
      EventStreamProvider<MessageEvent>('message');

  /// Checks if this type is supported on the current platform.
  static bool get supported => false;

  factory Worker(String scriptUrl) {
    throw UnsupportedError('Worker is not available outside a browser context.');
  }

  /// Stream of `error` events handled by this [Worker].
  @override
  Stream<Event> get onError => errorEvent.forTarget(this);

  /// Stream of `message` events handled by this [Worker].
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  void postMessage(dynamic message, [List<Object>? transfer]) =>
      throw UnsupportedError('Worker is not available outside a browser context.');

  void terminate() {}
}

@Native('WorkerGlobalScope')
class WorkerGlobalScope extends EventTarget {
  // To suppress missing implicit constructor warnings.
  /// Static factory designed to expose `error` events to event
  /// handlers that are not necessarily instances of [WorkerGlobalScope].
  ///
  /// See [EventStreamProvider] for usage information.
  static const EventStreamProvider<Event> errorEvent =
      EventStreamProvider<Event>('error');

  static WorkerGlobalScope get instance =>
      throw UnsupportedError('WorkerGlobalScope is not available outside a browser context.');

  WorkerGlobalScope._() : super.internal();

  String? get addressSpace => null;

  CacheStorage? get caches => null;

  Crypto? get crypto => null;

  IdbFactory? get indexedDB => null;

  bool? get isSecureContext => false;

  Location get location =>
      throw UnsupportedError('WorkerGlobalScope.location is not available outside a browser context.');

  WorkerNavigator get navigator =>
      throw UnsupportedError('WorkerGlobalScope.navigator is not available outside a browser context.');

  /// Stream of `error` events handled by this [WorkerGlobalScope].
  Stream<Event> get onError => errorEvent.forTarget(this);

  String? get origin => null;

  WorkerPerformance? get performance => null;

  WorkerGlobalScope get self => this;

  // From WindowBase64

  String atob(String atob) =>
      throw UnsupportedError('atob() is not available outside a browser context.');

  String btoa(String btoa) =>
      throw UnsupportedError('btoa() is not available outside a browser context.');

  Future fetch(dynamic input, [Map? init]) =>
      Future.error(UnsupportedError('fetch() is not available outside a browser context.'));

  void importScripts(String urls) {}
}

@Native('WorkerNavigator')
abstract class WorkerNavigator extends NavigatorConcurrentHardware
    implements NavigatorOnLine, NavigatorID {
  // To suppress missing implicit constructor warnings.
  factory WorkerNavigator._() {
    throw UnsupportedError('WorkerNavigator is not available outside a browser context.');
  }
}

@Native('WorkerPerformance')
class WorkerPerformance extends EventTarget {
  // To suppress missing implicit constructor warnings.
  factory WorkerPerformance._() {
    throw UnsupportedError('WorkerPerformance is not available outside a browser context.');
  }

  MemoryInfo? get memory => null;

  num? get timeOrigin =>
      DateTime.now().millisecondsSinceEpoch.toDouble();

  void clearMarks(String? markName) {}

  void clearMeasures(String? measureName) {}

  void clearResourceTimings() {}

  List<PerformanceEntry> getEntries() => [];

  List<PerformanceEntry> getEntriesByName(String name, String? entryType) => [];

  List<PerformanceEntry> getEntriesByType(String entryType) => [];

  void mark(String markName) {}

  void measure(String measureName, String? startMark, String? endMark) {}

  double now() =>
      DateTime.now().microsecondsSinceEpoch / 1000.0;

  void setResourceTimingBufferSize(int maxSize) {}
}

@Native('WorkletAnimation')
class WorkletAnimation {
  factory WorkletAnimation(
    String animatorName,
    List<KeyframeEffectReadOnly> effects,
    List<Object> timelines,
    /*SerializedScriptValue*/ options,
  ) {
    throw UnsupportedError('WorkletAnimation is not available outside a browser context.');
  }

  String? get playState => null;

  void cancel() {}

  void play() {}
}

@Native('WorkletGlobalScope')
class WorkletGlobalScope {
  // To suppress missing implicit constructor warnings.
  factory WorkletGlobalScope._() {
    throw UnsupportedError('WorkletGlobalScope is not available outside a browser context.');
  }
}
