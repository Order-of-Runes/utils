// Copyright (c) 2024 Order of Runes Authors. All rights reserved.

import 'package:flutter/material.dart';
import 'package:utils/src/empty_util.dart';

extension StringExtension on String {
  String get withColon => '$this:';

  String get withSpacedColon => '$this: ';

  String get camelCase => _ReCase(this).camelCase;

  String get constantCase => _ReCase(this).constantCase;

  String get sentenceCase => _ReCase(this).sentenceCase;

  String get snakeCase => _ReCase(this).snakeCase;

  String get dotCase => _ReCase(this).dotCase;

  String get paramCase => _ReCase(this).paramCase;

  String get pathCase => _ReCase(this).pathCase;

  String get pascalCase => _ReCase(this).pascalCase;

  String get headerCase => _ReCase(this).headerCase;

  String get titleCase => _ReCase(this).titleCase;

  String replaceTemplate(String templateRegex, List<String> values) {
    final regex = RegExp(templateRegex);
    if (regex.hasMatch(this)) {
      int i = 0;

      return replaceAllMapped(regex, (match) {
        return i < values.length ? values[i++] : match.group(0)!;
      });
    }
    return this;
  }

  String fill(List<String> values) => replaceTemplate(r'\{s\}', values);

  /// key must be defined in url as [url/:key]
  String fillInUrl({Map<String, String> keyValues = const {}, List<String> items = const []}) {
    assert(keyValues.isNotEmpty || items.isNotEmpty, 'Exactly one parameter  must be provided and not both ');
    if (keyValues.isNotNull) {
      String? path = this;
      keyValues.forEach((key, value) {
        if (value.isNotEmpty) {
          path = path!.replaceAll(':$key', value);
        }
      });
      return path!;
    } else {
      return replaceTemplate(r':[a-zA-Z0-9]*', items);
    }
  }

  bool get isNumeric => int.tryParse(this) != null;

  Color get toColor {
    String hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.tryParse('0x$hexColor') ?? 0xFF000000);
  }

  String? safeSplit(String pattern, int position) {
    final splits = split(pattern);
    if (position >= splits.length) return null;
    return splits[position];
  }

  // Includes only the ASCII characters, and strips out the others.
  String get onlyASCII => replaceAll(RegExp(r'[^\x00-\x7F]'), '');

  String get symbol {
    if (isEmpty) return '';

    final splits = split(' ');

    final first = splits.first.substring(0, 1);

    if (splits.length == 1) return first;

    final last = splits.last.substring(0, 1);

    return '$first$last';
  }

  String get mask {
    if (isEmpty) return '';

    final stringLength = length;
    final first = substring(0, stringLength > 3 ? 4 : stringLength);
    final last = substring(stringLength < 2 ? stringLength : stringLength - 2, stringLength);

    return '$first****$last';
  }

  /// Converts [String] to [int].
  ///
  /// If it can't be parsed, returns 0
  int toInt() => int.tryParse(this) ?? 0;

  /// Converts [String] to [double].
  ///
  /// If it can't be parsed, returns 0
  double toDouble() => double.tryParse(this) ?? 0;
}

/// An instance of text to be re-cased.
class _ReCase {
  final RegExp _upperAlphaRegex = RegExp(r'[A-Z]');

  final symbolSet = {' ', '.', '/', '_', r'\\', '-'};

  late List<String> _words;

  _ReCase(String text) {
    _words = _groupIntoWords(text);
  }

  List<String> _groupIntoWords(String text) {
    final StringBuffer sb = StringBuffer();
    final List<String> words = [];
    final bool isAllCaps = text.toUpperCase() == text;

    for (int i = 0; i < text.length; i++) {
      final String char = text[i];
      final String? nextChar = i + 1 == text.length ? null : text[i + 1];

      if (symbolSet.contains(char)) {
        continue;
      }

      sb.write(char);

      final bool isEndOfWord = nextChar == null || (_upperAlphaRegex.hasMatch(nextChar) && !isAllCaps) || symbolSet.contains(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }

  /// camelCase
  String get camelCase => _getCamelCase();

  /// CONSTANT_CASE
  String get constantCase => _getConstantCase();

  /// Sentence case
  String get sentenceCase => _getSentenceCase();

  /// snake_case
  String get snakeCase => _getSnakeCase();

  /// dot.case
  String get dotCase => _getSnakeCase(separator: '.');

  /// param-case
  String get paramCase => _getSnakeCase(separator: '-');

  /// path/case
  String get pathCase => _getSnakeCase(separator: '/');

  /// PascalCase
  String get pascalCase => _getPascalCase();

  /// Header-Case
  String get headerCase => _getPascalCase(separator: '-');

  /// Title Case
  String get titleCase => _getPascalCase(separator: ' ');

  String _getCamelCase({String separator = ''}) {
    final List<String> words = _words.map(_upperCaseFirstLetter).toList();
    if (_words.isNotEmpty) {
      words[0] = words[0].toLowerCase();
    }

    return words.join(separator);
  }

  String _getConstantCase({String separator = '_'}) {
    final List<String> words = _words.map((word) => word.toUpperCase()).toList();

    return words.join(separator);
  }

  String _getPascalCase({String separator = ''}) {
    final List<String> words = _words.map(_upperCaseFirstLetter).toList();

    return words.join(separator);
  }

  String _getSentenceCase({String separator = ' '}) {
    final List<String> words = _words.map((word) => word.toLowerCase()).toList();
    if (_words.isNotEmpty) {
      words[0] = _upperCaseFirstLetter(words[0]);
    }

    return words.join(separator);
  }

  String _getSnakeCase({String separator = '_'}) {
    final List<String> words = _words.map((word) => word.toLowerCase()).toList();

    return words.join(separator);
  }

  String _upperCaseFirstLetter(String word) {
    return '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}';
  }
}
