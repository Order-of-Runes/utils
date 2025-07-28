// Copyright (c) 2024 Order of Runes Authors. All rights reserved.

import 'dart:ui';

import 'package:flutter/scheduler.dart';

class BindingUtil {
  FlutterView? get _flutterView => SchedulerBinding.instance.platformDispatcher.implicitView;

  Size get physicalSize => _flutterView?.physicalSize ?? Size.zero;

  double get devicePixelRatio => _flutterView?.devicePixelRatio ?? 0;
}
