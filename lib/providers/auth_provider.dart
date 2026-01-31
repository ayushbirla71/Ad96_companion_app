// import 'package:flutter/material.dart';
// import '../../utils/token_storage.dart';

// class AuthProvider extends ChangeNotifier {
//   bool _isAuthenticated = false;
//   bool _loading = true;

//   bool get isAuthenticated => _isAuthenticated;
//   bool get loading => _loading;

//   Future<void> checkAuth() async {
//     _loading = true;
//     notifyListeners();

//     final token = await TokenStorage.getToken();

//     _isAuthenticated = token != null && token.isNotEmpty;
//     _loading = false;

//     notifyListeners();
//   }

//   Future<void> login(String token) async {
//     await TokenStorage.saveToken(token);
//     _isAuthenticated = true;
//     notifyListeners();
//   }

//   Future<void> logout() async {
//     await TokenStorage.clearToken();
//     _isAuthenticated = false;
//     notifyListeners();
//   }
// }


// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// class AuthProvider extends ChangeNotifier {
//   bool _isAuthenticated = false;

//   bool get isAuthenticated => _isAuthenticated;

//   Future<void> checkAuth() async {
//     _isAuthenticated = await AuthService.isLoggedIn();
//     notifyListeners();
//   }

//   Future<bool> login(String email, String password) async {
//     final success = await AuthService.login(email, password);
//     if (success) {
//       _isAuthenticated = true;
//       notifyListeners();
//     }
//     return success;
//   }

//   Future<void> logout() async {
//     await AuthService.logout();
//     _isAuthenticated = false;
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isChecking => _isChecking;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();

    _isAuthenticated = await AuthService.isLoggedIn();

    _isChecking = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final success = await AuthService.login(email, password);
    if (success) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
