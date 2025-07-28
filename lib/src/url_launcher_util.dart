// Copyright (c) 2025 The Order of Runes Authors. All rights reserved.

import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as u;
import 'package:url_launcher/url_launcher_string.dart' as us;
import 'package:utils/src/empty_util.dart';

class UrlLauncherUtil {
  /// Launch SecuritySetting page
  Future<void> launchSecuritySetting() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(action: 'android.settings.SECURITY_SETTINGS', flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK]);
      await intent.launch();
    } else if (Platform.isIOS) {
      final url = Uri.parse('App-Prefs:root=TOUCHID_PASSCODE');
      if (await u.canLaunchUrl(url)) {
        await u.launchUrl(url);
      } else {
        final url = Uri.parse('app-settings:');
        if (await u.canLaunchUrl(url)) {
          await u.launchUrl(url);
        }
      }
    }
  }

  /// Launches the [url] in external application.
  Future<bool> launchExternalApplication(String? url) async {
    try {
      if (url.isNotNullAndNotEmpty) {
        return await u.launchUrl(Uri.parse(url!), mode: u.LaunchMode.externalApplication);
      }
    } on PlatformException {
      return false;
    }
    return false;
  }

  /// Launches Android or iOS app referring to the provided url
  ///
  /// On Android: If app is not installed, play store page for the app is opened.
  Future<bool> launchApp({String? playStoreUrl, String? appStoreUrl}) async {
    try {
      if (Platform.isAndroid && playStoreUrl.isNotNullAndNotEmpty) {
        final packageName = Uri.parse(playStoreUrl!).queryParameters['id'];
        return await us.launchUrlString('android-app://$packageName');
      }
      if (Platform.isIOS && appStoreUrl.isNotNullAndNotEmpty) {
        if (await us.canLaunchUrlString(appStoreUrl!)) {
          return await us.launchUrlString(appStoreUrl);
        }
      }
    } on PlatformException {
      return false;
    }
    return false;
  }

  /// Launches playstore/appstore for reviewing the app.
  Future<bool> launchStoreForReview({required String playStoreId, required String appStoreId}) async {
    try {
      if (Platform.isAndroid) {
        await us.launchUrlString('market://details?id=$playStoreId');
      } else if (Platform.isIOS) {
        await us.launchUrlString('https://apps.apple.com/app/id$appStoreId?action=write-review');
      }
    } on PlatformException {
      if (Platform.isAndroid) return _openPlayStore(playStoreId);
    }
    return false;
  }

  Future<bool> _openPlayStore(String id) async {
    try {
      final playLink = Uri.https('play.google.com', 'store/apps/details', {'id': id});

      return await u.launchUrl(playLink);
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openStore({required String playStoreId, required String appStoreId}) async {
    try {
      if (Platform.isAndroid) {
        await us.launchUrlString('market://details?id=$playStoreId');
      } else if (Platform.isIOS) {
        await us.launchUrlString('https://apps.apple.com/app/id$appStoreId');
      }
    } on PlatformException {
      if (Platform.isAndroid) return _openPlayStore(playStoreId);
    }
    return false;
  }
}
