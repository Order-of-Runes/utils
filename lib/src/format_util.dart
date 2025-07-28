// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'dart:convert';

extension MapExtension on Map {
  String format(String label) {
    final formatted = const JsonEncoder.withIndent('  ').convert(this);

    return '$label $formatted';
  }
}
