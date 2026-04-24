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

abstract class ScrollState {
  factory ScrollState([Map? scrollStateInit]) {
    return _DefaultScrollState.fromInit(scrollStateInit);
  }

  num? get deltaGranularity;

  num? get deltaX;

  num? get deltaY;

  bool? get fromUserInput;

  bool? get inInertialPhase;

  bool? get isBeginning;

  bool? get isDirectManipulation;

  bool? get isEnding;

  int? get positionX;

  int? get positionY;

  num? get velocityX;

  num? get velocityY;

  void consumeDelta(num x, num y);

  void distributeToScrollChainDescendant();
}

class _DefaultScrollState implements ScrollState {
  @override
  final num? deltaGranularity;

  @override
  num? deltaX;

  @override
  num? deltaY;

  @override
  final bool? fromUserInput;

  @override
  final bool? inInertialPhase;

  @override
  final bool? isBeginning;

  @override
  final bool? isDirectManipulation;

  @override
  final bool? isEnding;

  @override
  int? positionX;

  @override
  int? positionY;

  @override
  num? velocityX;

  @override
  num? velocityY;

  _DefaultScrollState({
    this.deltaGranularity,
    this.deltaX,
    this.deltaY,
    this.fromUserInput,
    this.inInertialPhase,
    this.isBeginning,
    this.isDirectManipulation,
    this.isEnding,
    this.positionX,
    this.positionY,
    this.velocityX,
    this.velocityY,
  });

  factory _DefaultScrollState.fromInit(Map? init) {
    return _DefaultScrollState(
      deltaGranularity: init?['deltaGranularity'] as num?,
      deltaX: init?['deltaX'] as num?,
      deltaY: init?['deltaY'] as num?,
      fromUserInput: init?['fromUserInput'] as bool?,
      inInertialPhase: init?['inInertialPhase'] as bool?,
      isBeginning: init?['isBeginning'] as bool?,
      isDirectManipulation: init?['isDirectManipulation'] as bool?,
      isEnding: init?['isEnding'] as bool?,
      positionX: init?['positionX'] as int?,
      positionY: init?['positionY'] as int?,
      velocityX: init?['velocityX'] as num?,
      velocityY: init?['velocityY'] as num?,
    );
  }

  @override
  void consumeDelta(num x, num y) {
    deltaX = (deltaX ?? 0) - x;
    deltaY = (deltaY ?? 0) - y;
  }

  @override
  void distributeToScrollChainDescendant() {
    // No-op fallback.
  }
}
