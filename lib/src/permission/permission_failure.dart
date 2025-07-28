// Copyright (c) 2025 Order of Runes Authors. All rights reserved.

import 'package:foundation/foundation.dart';

class PermissionFailure extends FailureFoundation {
  const PermissionFailure(super.message);

  @override
  List<Object?> get additionalProps => [];

  @override
  Map<String, String> get toStringValues => {};
}
