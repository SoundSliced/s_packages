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

abstract class DomMatrix extends DomMatrixReadOnly {
  @override
  int a = 0;
  @override
  int b = 0;
  @override
  int c = 0;
  @override
  int d = 0;
  @override
  int e = 0;
  @override
  int f = 0;
  @override
  int m11 = 0;
  @override
  int m12 = 0;
  @override
  int m13 = 0;
  @override
  int m14 = 0;
  @override
  int m21 = 0;
  @override
  int m22 = 0;
  @override
  int m23 = 0;
  @override
  int m24 = 0;
  @override
  int m31 = 0;
  @override
  int m32 = 0;
  @override
  int m33 = 0;
  @override
  int m34 = 0;
  @override
  int m41 = 0;
  @override
  int m42 = 0;
  @override
  int m43 = 0;
  @override
  int m44 = 0;

  static DomMatrix fromFloat32Array(Float32List list) {
    return _DomMatrixImpl.fromList(
        list.map((value) => value.toDouble()).toList());
  }

  static DomMatrix fromFloat64Array(Float64List list) {
    return _DomMatrixImpl.fromList(list.toList());
  }
}

abstract class DomMatrixReadOnly {
  int get a;

  int get b;

  int get c;

  int get d;

  int get e;

  int get f;

  int get m11;

  int get m12;

  int get m13;

  int get m14;

  int get m21;

  int get m22;

  int get m23;

  int get m24;

  int get m31;

  int get m32;

  int get m33;

  int get m34;

  int get m41;

  int get m42;

  int get m43;

  int get m44;

  DomMatrix flipX();

  DomMatrix flipY();

  DomMatrix inverse();

  DomMatrix multiply(DomMatrix secondDomMatrix);

  DomMatrix rotate(num angle);

  DomMatrix rotateFromVector(num x, num y);

  DomMatrix scale([
    num scaleX,
    num scaleY,
    num scaleZ,
    num originX,
    num originY,
    num originZ,
  ]);

  DomMatrix scale3d([
    num scaleX,
    num scaleY,
    num scaleZ,
    num originX,
    num originY,
    num originZ,
  ]);

  DomMatrix skewX(num angle);

  DomMatrix skewY(num angle);

  DomMatrix translate(num tx, num ty, num tz);

  static DomMatrixReadOnly fromFloat32Array(Float32List list) {
    return DomMatrix.fromFloat32Array(list);
  }

  static DomMatrixReadOnly fromFloat64Array(Float64List list) {
    return DomMatrix.fromFloat64Array(list);
  }
}

class _DomMatrixImpl extends DomMatrix {
  _DomMatrixImpl();

  factory _DomMatrixImpl.fromList(List<double> values) {
    final matrix = _DomMatrixImpl();
    if (values.isNotEmpty) matrix.m11 = values[0].round();
    if (values.length > 1) matrix.m12 = values[1].round();
    if (values.length > 2) matrix.m13 = values[2].round();
    if (values.length > 3) matrix.m14 = values[3].round();
    if (values.length > 4) matrix.m21 = values[4].round();
    if (values.length > 5) matrix.m22 = values[5].round();
    if (values.length > 6) matrix.m23 = values[6].round();
    if (values.length > 7) matrix.m24 = values[7].round();
    if (values.length > 8) matrix.m31 = values[8].round();
    if (values.length > 9) matrix.m32 = values[9].round();
    if (values.length > 10) matrix.m33 = values[10].round();
    if (values.length > 11) matrix.m34 = values[11].round();
    if (values.length > 12) matrix.m41 = values[12].round();
    if (values.length > 13) matrix.m42 = values[13].round();
    if (values.length > 14) matrix.m43 = values[14].round();
    if (values.length > 15) matrix.m44 = values[15].round();
    matrix.a = matrix.m11;
    matrix.b = matrix.m12;
    matrix.c = matrix.m21;
    matrix.d = matrix.m22;
    matrix.e = matrix.m41;
    matrix.f = matrix.m42;
    if (matrix.m33 == 0) {
      matrix.m33 = 1;
    }
    if (matrix.m44 == 0) {
      matrix.m44 = 1;
    }
    return matrix;
  }

  _DomMatrixImpl _copy() => _DomMatrixImpl.fromList(<double>[
        m11.toDouble(),
        m12.toDouble(),
        m13.toDouble(),
        m14.toDouble(),
        m21.toDouble(),
        m22.toDouble(),
        m23.toDouble(),
        m24.toDouble(),
        m31.toDouble(),
        m32.toDouble(),
        m33.toDouble(),
        m34.toDouble(),
        m41.toDouble(),
        m42.toDouble(),
        m43.toDouble(),
        m44.toDouble(),
      ]);

  @override
  DomMatrix flipX() {
    final result = _copy();
    result.m11 = -result.m11;
    result.a = result.m11;
    return result;
  }

  @override
  DomMatrix flipY() {
    final result = _copy();
    result.m22 = -result.m22;
    result.d = result.m22;
    return result;
  }

  @override
  DomMatrix inverse() => _copy();

  @override
  DomMatrix multiply(DomMatrix secondDomMatrix) {
    final result = _copy();
    result.m41 += secondDomMatrix.m41;
    result.m42 += secondDomMatrix.m42;
    result.e = result.m41;
    result.f = result.m42;
    return result;
  }

  @override
  DomMatrix rotate(num angle) => _copy();

  @override
  DomMatrix rotateFromVector(num x, num y) => _copy();

  @override
  DomMatrix scale([
    num scaleX = 1,
    num scaleY = 1,
    num scaleZ = 1,
    num originX = 0,
    num originY = 0,
    num originZ = 0,
  ]) {
    final result = _copy();
    result.m11 = (result.m11 * scaleX).round();
    result.m22 = (result.m22 * scaleY).round();
    result.m33 = (result.m33 * scaleZ).round();
    result.m41 = (result.m41 + originX).round();
    result.m42 = (result.m42 + originY).round();
    result.m43 = (result.m43 + originZ).round();
    result.a = result.m11;
    result.d = result.m22;
    result.e = result.m41;
    result.f = result.m42;
    return result;
  }

  @override
  DomMatrix scale3d([
    num scaleX = 1,
    num scaleY = 1,
    num scaleZ = 1,
    num originX = 0,
    num originY = 0,
    num originZ = 0,
  ]) =>
      scale(scaleX, scaleY, scaleZ, originX, originY, originZ);

  @override
  DomMatrix skewX(num angle) => _copy();

  @override
  DomMatrix skewY(num angle) => _copy();

  @override
  DomMatrix translate(num tx, num ty, num tz) {
    final result = _copy();
    result.m41 += tx.round();
    result.m42 += ty.round();
    result.m43 += tz.round();
    result.e = result.m41;
    result.f = result.m42;
    return result;
  }
}
