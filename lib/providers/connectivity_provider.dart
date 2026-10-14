import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../utils/api_constants.dart';

/// Tracks whether the device can really reach the backend.
///
/// `connectivity_plus` only says a network interface is up (e.g. Wi-Fi with no
/// internet still reports "wifi"), so every change is verified with a DNS
/// lookup of the API host before the app is considered online.
class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _subscription = Connectivity().onConnectivityChanged.listen(_onChanged);
    checkNow();
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  bool _isOnline = true;
  bool _dismissed = false;
  bool _checking = false;

  bool get isOnline => _isOnline;
  bool get isChecking => _checking;

  /// True when the "no internet" popup should be on screen.
  bool get showOfflinePopup => !_isOnline && !_dismissed;

  void _onChanged(List<ConnectivityResult> results) {
    checkNow();
  }

  /// Hides the popup until the connection state changes again.
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    notifyListeners();
  }

  /// Re-checks the connection. Used by the popup's Retry button and called
  /// by `ApiService` when a request fails with a network error.
  Future<bool> checkNow() async {
    if (_checking) return _isOnline;
    _checking = true;
    notifyListeners();

    final online = await _hasInternet();

    _checking = false;
    if (online != _isOnline) {
      _isOnline = online;
      _dismissed = false; // a new offline period shows the popup again
    }
    notifyListeners();
    return online;
  }

  Future<bool> _hasInternet() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
        return false;
      }

      final host = Uri.parse(ApiConstants.baseUrl).host;
      final lookup =
          await InternetAddress.lookup(host).timeout(const Duration(seconds: 5));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (e) {
      // Unknown platform error: don't lock the user out with a false popup.
      debugPrint('Connectivity check failed: $e');
      return true;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
