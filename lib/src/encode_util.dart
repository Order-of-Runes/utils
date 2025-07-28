// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'dart:convert';

class EncodeUtil {
  String encodeBase64(String input) {
    return base64.encode(utf8.encode(input));
  }

  String decodeBase64(String encodedInput) {
    return utf8.decode(base64.decode(encodedInput));
  }
}
