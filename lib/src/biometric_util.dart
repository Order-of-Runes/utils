// Copyright (c) 2020 Order of Runes Authors. All rights reserved.

import 'package:biometric_signature/android_config.dart';
import 'package:biometric_signature/biometric_signature.dart';
import 'package:biometric_signature/ios_config.dart';
import 'package:flutter/services.dart';

import 'package:utils/src/empty_util.dart';

const _unsupportedErrors = [
  'BIOMETRIC_ERROR_NO_HARDWARE',
  'BIOMETRIC_ERROR_UNSUPPORTED',
  'BIOMETRIC_STATUS_UNKNOWN',
  'NO_BIOMETRICS',
];

const String _noneEnrolled = 'BIOMETRIC_ERROR_NONE_ENROLLED';
const String _none = 'none';

/// Handles initialization, checking support/enrollment,
/// key management, and creating biometric signatures.
///
/// Note: Call `init()` before accessing other properties/methods.
class BiometricUtil {
  late final BiometricSignature _biometricSignature;
  late final String? _biometricType;

  bool _initialized = false;

  /// Initializes the biometric utility by checking for available biometric authentication.
  Future<void> init() async {
    if (!_initialized) {
      _biometricSignature = BiometricSignature();
      _biometricType = await _biometricSignature.biometricAuthAvailable();
      _initialized = true;
    }
  }

  /// Returns the biometric type (e.g., fingerprint, FaceID) or an error string.
  String? get biometricType => _biometricType;

  /// Returns true if biometric authentication is available and not restricted.
  bool get isBiometricAvailable => _biometricType.isNotNull && !_biometricType!.contains(_none);

  /// Returns true if the device supports biometric hardware (regardless of enrollment).
  bool get hasSupport {
    return _biometricType.isNotNull && !_unsupportedErrors.any((e) => _biometricType!.contains(e));
  }

  bool get hasEnrolled {
    if (!hasSupport) return false;

    const enrollmentErrors = [_noneEnrolled, _none];

    return _biometricType.isNotNull && !enrollmentErrors.any((e) => _biometricType!.contains(e));
  }

  /// Checks if the biometric key exists on the device.
  ///
  /// [checkValidity] – when true, verifies if the key is still valid.
  Future<bool> doesKeyExist({bool checkValidity = false}) async {
    return await _biometricSignature.biometricKeyExists(checkValidity: checkValidity) ?? false;
  }

  /// Creates a new RSA key pair for biometric authentication.
  ///
  /// Returns a base64-encoded public key if successful, null otherwise.
  Future<String?> getPublicKey() async {
    try {
      return _biometricSignature.createKeys(
        androidConfig: AndroidConfig(useDeviceCredentials: true),
        iosConfig: IosConfig(useDeviceCredentials: true),
      );
    } on PlatformException {
      return null;
    }
  }

  /// Prompts biometric authentication and returns a base64-encoded signature.
  ///
  /// [payload] – the data to sign
  /// [promptMessage] – message shown in biometric prompt
  /// [shouldMigrate] – for iOS Secure Enclave migration
  /// [allowDeviceCredentials] – fallback option for Android
  Future<String?> createSignature({
    required String payload,
    required String promptMessage,
    String shouldMigrate = 'true',
    String allowDeviceCredentials = 'true',
  }) async {
    try {
      return _biometricSignature.createSignature(
        options: {
          'payload': payload,
          'promptMessage': promptMessage,
          'shouldMigrate': shouldMigrate,
          'allowDeviceCredentials': allowDeviceCredentials,
        },
      );
    } on PlatformException {
      return null;
    }
  }

  /// Delete the biometric key if exists
  ///
  /// - Returns: A boolean indicating whether the deletion was successful
  Future<bool> deleteKeys() async {
    try {
      return (await _biometricSignature.deleteKeys()) ?? false;
    } on PlatformException {
      return false;
    }
  }
}
