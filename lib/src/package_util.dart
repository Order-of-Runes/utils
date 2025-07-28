// Copyright (c) 2024 Order of Runes Authors. All rights reserved.

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sherlog/sherlog.dart';

/// Make sure to initialize this before accessing member methods
class PackageUtil {
  late final PackageInfo _packageInfo;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // TODO (Ishwor) Return result instead
      try {
        _packageInfo = await PackageInfo.fromPlatform();
      } on PlatformException catch (e, s) {
        Sherlog(level: LogLevel.error).error(e, stackTrace: s);
        rethrow;
      }
      _initialized = true;
    }
  }

  /// Returns [applicationName] i.e. `CFBundleDisplayName` on iOS, `application/label` on Android.
  String get applicationName => _packageInfo.appName;

  /// Returns [versionName] i.e. `CFBundleShortVersionString` on iOS, `versionName` on Android.
  String get versionName => _packageInfo.version;

  /// Returns [applicationId] i.e. `bundleIdentifier` on iOS, `getPackageName` on Android.
  String get applicationId => _packageInfo.packageName;

  /// Returns [versionCode] i.e. `CFBundleVersion` on iOS, `versionCode` on Android.
  String get versionCode => _packageInfo.buildNumber;
}
