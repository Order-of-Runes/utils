// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'package:permission_handler/permission_handler.dart';
import 'package:rusty_dart/rusty_dart.dart';
import 'package:utils/src/device_util.dart';

abstract class PermissionUtilCore<F extends Exception> {
  /// Android: External Storage
  /// iOS: Access to folders like `Documents` or `Downloads`. Implicitly
  /// granted.
  Future<Result<bool, F>> storage() async {
    final storagePermissionStatus = await Permission.storage.request();

    return _handleStatus(storagePermissionStatus);
  }

  /// Android: Photos
  /// iOS: Photos
  Future<Result<bool, F>> photos(DeviceUtil deviceUtil) async {
    final permission = deviceUtil.isSupported(minSdk: 32) ? Permission.photos : Permission.storage;
    final permissionStatus = await permission.request();

    return _handleStatus(permissionStatus);
  }

  Result<bool, F> _handleStatus(PermissionStatus status) {
    if (status.isGranted || status.isLimited) return Ok(true);
    if (status.isPermanentlyDenied) return Err(permissionException);

    return Ok(false);
  }

  Future<bool> openAppSettings() => openAppSettings();

  F get permissionException;
}
