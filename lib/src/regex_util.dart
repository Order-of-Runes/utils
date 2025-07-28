// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'package:utils/src/empty_util.dart';

class RegexUtil {
  /// Returns true if [text] matches the [regex].
  static bool isValid(String? text, String? regex) {
    if (text.isNull || regex.isNull) return false;
    final regExp = RegExp(regex!);
    return regExp.hasMatch(text!);
  }
}
