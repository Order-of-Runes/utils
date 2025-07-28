// Copyright (c) 2024 Order of Runes Authors. All rights reserved.

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:sherlog/sherlog.dart';
import 'package:utils/src/empty_util.dart';
import 'package:utils/src/package_util.dart';
import 'package:utils/src/string_util.dart';
import 'package:uuid/uuid.dart';

/// Make sure to initialize this before accessing member methods
class DeviceUtil {
  late AndroidDeviceInfo _androidDeviceInfo;
  late IosDeviceInfo _iosDeviceInfo;

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // TODO (Ishwor) Return result instead
      try {
        final deviceInfo = DeviceInfoPlugin();

        if (Platform.isIOS) {
          _iosDeviceInfo = await deviceInfo.iosInfo;
        } else if (Platform.isAndroid) {
          _androidDeviceInfo = await deviceInfo.androidInfo;
        }
      } on PlatformException catch (e, s) {
        Sherlog(level: LogLevel.error).error(e, stackTrace: s);
        rethrow;
      }
      _initialized = true;
    }
  }

  /// Returns mobile's user-defined device name.
  String get deviceName {
    String? nickName;
    if (Platform.isAndroid) {
      // TODO (Ishwor) Fetch device name for android platform
      nickName = '';
    } else if (Platform.isIOS) {
      // TODO (Ishwor) Add entitlement for accessing the following property
      // https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.device-information.user-assigned-device-name
      nickName = _iosDeviceInfo.name;
    }

    return nickName?.onlyASCII ?? '';
  }

  /// Returns device market name instead of actual device name.
  ///
  /// For example,
  /// Market Name = Samsung Galaxy S7
  /// Actual Device Name = "SAMSUNG-SM-G930A" or "SM-G930F" or "SM-G930K" or "SM-G930L" or ...
  String get deviceMarketName {
    String? marketName;

    if (Platform.isIOS) {
      marketName ??= _iosDeviceInfo.model;
    } else if (Platform.isAndroid) {
      marketName ??= _androidDeviceInfo.model;
    }

    return marketName?.onlyASCII ?? '';
  }

  /// Returns mobile device manufacturer.
  String get deviceManufacturer {
    String? manufacturer;
    if (Platform.isAndroid) {
      manufacturer = _androidDeviceInfo.manufacturer;
    } else if (Platform.isIOS) {
      manufacturer = 'Apple';
    }

    return manufacturer?.toUpperCase().onlyASCII ?? '';
  }

  /// Returns [osVersion] for the device.
  String get osVersion {
    String? osVersion;
    if (Platform.isAndroid) {
      osVersion = _androidDeviceInfo.version.release;
    } else if (Platform.isIOS) {
      osVersion = _iosDeviceInfo.systemVersion;
    }

    return osVersion ?? '';
  }

  String get deviceId {
    String? deviceId;
    if (Platform.isAndroid) {
      final _androidId = _androidDeviceInfo.id;
      deviceId = _androidId.isNotNullAndNotEmpty ? 'android_$_androidId' : 'android_${const Uuid().v4()}';
    } else if (Platform.isIOS) {
      final _iosId = _iosDeviceInfo.identifierForVendor;
      deviceId = _iosId.isNotNullAndNotEmpty ? 'ios_$_iosId' : 'ios_${const Uuid().v4()}';
    }
    return deviceId ?? '';
  }

  /// Returns [deviceModel] for the device.
  String get deviceModel {
    String? model;
    if (Platform.isAndroid) {
      model = _androidDeviceInfo.model;
    } else if (Platform.isIOS) {
      model = _iosDeviceInfo.model;
    }

    return model?.onlyASCII ?? '';
  }

  /// Returns the current build api version.
  String get apiLevel {
    String? apiLevel;
    if (Platform.isAndroid) {
      apiLevel = '${_androidDeviceInfo.version.sdkInt}';
    } else if (Platform.isIOS) {
      apiLevel = _iosDeviceInfo.systemVersion;
    }
    return apiLevel ?? '';
  }

  /// Returns the OS Name followed by OS Version
  String get osNameWithVersion {
    String osName = '';
    if (Platform.isAndroid) {
      osName += 'Android';
    } else if (Platform.isIOS) {
      osName += 'iOS';
    }
    return '$osName $osVersion';
  }

  String userAgent(PackageUtil packageUtil) {
    return 'TMS/${packageUtil.versionName}'
        '(${packageUtil.applicationId}; build: ${packageUtil.versionCode} '
        '${Platform.operatingSystem} $osVersion)';
  }

  /// Returns true if the device's Android version is greater or equal to [minSupportedVersion].
  ///
  /// For devices other than Android, this function always returns true.
  bool isSupported({required int minSdk}) {
    if (Platform.isAndroid) return _androidDeviceInfo.version.sdkInt >= minSdk;
    return true;
  }

  String getDensityName(double density) {
    if (density < 1) {
      return 'ldpi';
    } else if (density < 1.5) {
      return 'mdpi';
    } else if (density < 2) {
      return 'hdpi';
    } else if (density < 3) {
      return 'xhdpi';
    } else if (density < 4) {
      return 'xxhdpi';
    } else {
      return 'xxxhdpi';
    }
  }
}

// TODO (Ishwor) Add more sdk ints
enum AndroidSdk {
  lollipop(21),
  marshmallow(23),
  nougat(24),
  oreo(26),
  pie(28),
  Q(29),
  R(30),
  S(31),
  T(32);

  const AndroidSdk(this.sdk);

  final int sdk;
}
