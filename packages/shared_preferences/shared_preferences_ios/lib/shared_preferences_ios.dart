// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/shared_preferences_ios');

/// The macOS implementation of [SharedPreferencesStorePlatform].
///
/// This class implements the `package:shared_preferences` functionality for iOS.
class SharedPreferencesIOS extends SharedPreferencesStorePlatform {
  /// Registers this class as the default instance of [SharedPreferencesStorePlatform].
  static void registerWith() {
    SharedPreferencesStorePlatform.instance = SharedPreferencesIOS();
  }

  @override
  Future<bool> remove(String key) async {
    return (await _kChannel.invokeMethod<bool>(
      'remove',
      <String, dynamic>{'key': key},
    ))!;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    return (await _kChannel.invokeMethod<bool>(
      'set$valueType',
      <String, dynamic>{'key': key, 'value': value},
    ))!;
  }

  @override
  Future<bool> clear() async {
    return (await _kChannel.invokeMethod<bool>('clear'))!;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    final Map<String, Object>? preferences =
        await _kChannel.invokeMapMethod<String, Object>('getAll');

    if (preferences == null) {
      return <String, Object>{};
    }
    return preferences;
  }
}
