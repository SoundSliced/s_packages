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

abstract class PaymentAddress {
  PaymentAddress._();

  List<String>? get addressLine;

  String? get city;

  String? get country;

  String? get dependentLocality;

  String? get languageCode;

  String? get organization;

  String? get phone;

  String? get postalCode;

  String? get recipient;

  String? get region;

  String? get sortingCode;
}

@Native('PaymentInstruments')
class PaymentInstruments {
  factory PaymentInstruments._() {
    return PaymentInstruments._internal();
  }

  PaymentInstruments._internal();

  final Map<String, Map<String, dynamic>> _store =
      <String, Map<String, dynamic>>{};

  Future<void> clear() {
    _store.clear();
    return Future<void>.value();
  }

  Future<bool> delete(String instrumentKey) =>
      Future<bool>.value(_store.remove(instrumentKey) != null);

  Future<Map<String, dynamic>?> get(String instrumentKey) =>
      Future<Map<String, dynamic>?>.value(_store[instrumentKey]);

  Future<bool> has(String instrumentKey) =>
      Future<bool>.value(_store.containsKey(instrumentKey));

  Future<List<dynamic>> keys() =>
      Future<List<dynamic>>.value(_store.keys.toList(growable: false));

  Future<void> set(String instrumentKey, Map details) {
    _store[instrumentKey] = Map<String, dynamic>.from(details);
    return Future<void>.value();
  }
}

@Native('PaymentManager')
class PaymentManager {
  // ignore: unused_element
  factory PaymentManager._() {
    return PaymentManager._internal();
  }

  PaymentManager._internal();

  final PaymentInstruments _instruments = PaymentInstruments._();

  String? _userHint;

  PaymentInstruments? get instruments {
    return _instruments;
  }

  // ignore: unnecessary_getters_setters
  String? get userHint {
    return _userHint;
  }

  set userHint(String? value) {
    _userHint = value;
  }
}

@Native('PaymentRequest')
class PaymentRequest extends EventTarget {
  final List<Map> _methodData;
  final Map _details;
  final Map? _options;

  factory PaymentRequest(List<Map> methodData, Map details, [Map? options]) {
    return PaymentRequest._internal(methodData, details, options);
  }

  PaymentRequest._internal(this._methodData, this._details, this._options)
      : super.internal();

  String? get id {
    return _options?['id'] as String?;
  }

  PaymentAddress? get shippingAddress {
    return null;
  }

  String? get shippingOption {
    return _options?['shippingOption'] as String?;
  }

  String? get shippingType {
    return _options?['shippingType'] as String?;
  }

  Future<void> abort() => Future<void>.value();

  Future<bool> canMakePayment() =>
      Future<bool>.value(_methodData.isNotEmpty && _details.isNotEmpty);

  Future<PaymentResponse> show() => Future<PaymentResponse>.value(
        PaymentResponse._(),
      );
}

@Native('PaymentResponse')
class PaymentResponse {
  factory PaymentResponse._() {
    return PaymentResponse._internal();
  }

  PaymentResponse._internal();

  Object? get details {
    return null;
  }

  String? get methodName {
    return null;
  }

  String? get payerEmail {
    return null;
  }

  String? get payerName {
    return null;
  }

  String? get payerPhone {
    return null;
  }

  String? get requestId {
    return null;
  }

  PaymentAddress? get shippingAddress {
    return null;
  }

  String? get shippingOption {
    return null;
  }

  Future<void> complete([String? paymentResult]) => Future<void>.value();
}
