// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'package:flutter/material.dart';
import 'package:sherlog/sherlog.dart';
import 'package:utils/src/empty_util.dart';

void logThis(dynamic message, {String? tag, int? lineLength, AnsiColor? color, bool? showSource}) {
  Sherlog(
    lineLength: lineLength ?? 100,
    levelColors: {LogLevel.trace: color ?? const AnsiColor.none()},
  ).trace(message ?? 'null', headers: tag.isNullOrEmpty ? [] : [tag!], showSource: showSource ?? false);
}

Widget logThisInWidget(dynamic message, {String? tag, int? lineLength, AnsiColor? color, bool? showSource}) {
  logThis(message, tag: tag, lineLength: lineLength, color: color, showSource: showSource);
  return const SizedBox.shrink();
}

extension LogThisExtension on Object? {
  void log({String? tag, int? lineLength, AnsiColor? color, bool? showSource}) {
    logThis(this, tag: tag, lineLength: lineLength, color: color, showSource: showSource);
  }

  Widget logInWidget({String? tag, int? lineLength, AnsiColor? color, bool? showSource}) {
    return logThisInWidget(this, tag: tag, lineLength: lineLength, color: color, showSource: showSource);
  }
}
