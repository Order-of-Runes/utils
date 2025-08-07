// Copyright (c) 2024 Order of Runes Authors. All rights reserved.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:foundation/foundation.dart';

const List<ConnectivityResult> _acceptedNetworkResults = [
  ConnectivityResult.wifi,
  ConnectivityResult.ethernet,
  ConnectivityResult.mobile,
  ConnectivityResult.vpn,
];

class NetworkUtil extends NetworkInfoFoundation {
  late final Connectivity _connectivity;

  StreamSubscription<bool>? _streamSubscription;
  bool _hasNetwork = false;

  @override
  bool get isAvailable => _hasNetwork;

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _connectivity = Connectivity();
      _hasNetwork = await onChange().first;
      _streamSubscription = onChange().listen((val) => _hasNetwork = val);
      _initialized = true;
    }
  }

  Stream<bool> onChange() {
    return _connectivity.onConnectivityChanged.map((results) {
      for (final result in results) {
        if (_acceptedNetworkResults.contains(result)) {
          return true;
        }
      }
      return false;
    });
  }

  void close() {
    _streamSubscription?.cancel();
  }
}
