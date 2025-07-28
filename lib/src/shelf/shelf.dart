// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherlog/sherlog.dart';
import 'package:utils/src/shelf/s_key.dart';

class Shelf {
  Shelf({
    this.enableLog = false,
    this.protectedKeys = const {},
  }) : _sherlog = Sherlog(
         levelColors: {
           LogLevel.info: AnsiColor.fg(ConsoleColor.yellow.code),
         },
       );

  late final FlutterSecureStorage _store;
  final Sherlog _sherlog;
  final Map<String, String> _easyStore = {};

  /// Should console logging be enabled
  final bool enableLog;

  /// Passed keys are protected from removal unless the app data is cleared
  /// or the app itself is removed or re-installed
  final Set<SKey> protectedKeys;

  Future<void> init() async {
    _store = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    // Working around iOS's quirk of preserving data even if the app is re-installed
    // this clears the data from Shelf
    if (Platform.isIOS) {
      final pref = SharedPreferencesAsync();
      final firstInstall = (await pref.getBool('fresh_install')) ?? true;
      if (firstInstall) {
        await _deleteAll();
        await pref.setBool('fresh_install', false);
      }
    }
    // Read all data from secure storage and put in the the
    // [_easyStore] for quick access
    await _read();
  }

  Future<void> reload() => _read('Reload');

  Future<bool> delete(SKey key) async {
    final _key = key.name;
    if (_easyStore.containsKey(_key)) {
      _easyStore.remove(_key);
      await _store.delete(key: _key);
      _log(key, ['DELETE']);
      return true;
    }
    return false;
  }

  Future<void> deleteAll() async {
    final backup = <String, String>{};
    if (protectedKeys.isNotEmpty) {
      for (final key in protectedKeys) {
        final _key = key.name;
        if (_easyStore.containsKey(_key)) {
          backup[_key] = _easyStore[_key]!;
        }
      }
    }
    await _deleteAll();
    if (backup.isNotEmpty) {
      _easyStore.addAll(backup);
      final results = backup.map((key, value) {
        return MapEntry(key, _store.write(key: key, value: value));
      });
      await Future.wait(results.values);
    }
  }

  Future<void> put<T>(SKey key, T value) async {
    try {
      final encodedValue = jsonEncode(value);
      final _key = key.name;
      _easyStore[_key] = encodedValue;
      await _store.write(key: _key, value: encodedValue);

      _log(encodedValue, [_getHeader('PUT', _key)]);
    } on Exception catch (e, s) {
      Sherlog(
        level: LogLevel.error,
      ).error(
        'You passed an object that is not serializable. Try passing one which can be serialized',
        detail: e,
        stackTrace: s,
      );
    }
  }

  T? get<T>(SKey key, [T? defaultValue]) {
    try {
      final T? value;
      final _key = key.name;
      if (_easyStore.containsKey(_key)) {
        value = jsonDecode(_easyStore[_key]!) as T?;
      } else {
        value = defaultValue;
      }

      _log(value ?? '', [_getHeader('GET', _key)]);

      return value;
    } on Exception catch (e, s) {
      Sherlog(level: LogLevel.error).error(e, stackTrace: s);
    }
    return null;
  }

  bool containsKey(SKey key) {
    return _easyStore.containsKey(key.name);
  }

  String _getHeader(String method, String key) => '$method : $key';

  Future<void> _deleteAll() async {
    final keys = _easyStore.keys;
    _easyStore.clear();
    await _store.deleteAll();
    _log(keys, ['DELETE ALL']);
  }

  Future<void> _read([String event = 'Load']) async {
    _easyStore
      ..clear()
      ..addAll(await _store.readAll());

    _log(_easyStore, [event]);
  }

  void _log(Object content, [List<String> headers = const []]) {
    if (enableLog) {
      _sherlog.info(content, headers: ['Shelf', ...headers]);
    }
  }
}
