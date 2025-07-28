import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as p;

class PathUtil {
  Future<String> get dBDirPath async {
    try {
      final dir = defaultTargetPlatform == TargetPlatform.iOS ? await p.getLibraryDirectory() : await p.getApplicationDocumentsDirectory();
      return dir.path;
    } on PlatformException catch (e, _) {
      // TODO (Ishwor) log error
      return '';
    }
  }

  Future<String> getExternalStoragePath(String packageName) async {
    if (Platform.isAndroid) {
      final path = '/storage/emulated/0/Download/$packageName';
      final downloadDir = Directory(path);
      if (!(await downloadDir.exists())) await downloadDir.create(recursive: true);
      return downloadDir.path;
    }

    // For iOS or other platforms
    final dir = await p.getApplicationDocumentsDirectory();
    return dir.path;
  }
}
