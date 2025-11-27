import 'package:flutter/foundation.dart';
import '../models/po.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  PO? _currentPO;
  bool _isLoading = false;
  String? _error;

  PO? get currentPO => _currentPO;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentPO != null;

  // Initialize - check if already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final po = await _authService.getSavedPO();
      if (po != null) {
        _currentPO = po;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _currentPO = result['po'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );

      _isLoading = false;

      if (result['success']) {
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentPO = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
