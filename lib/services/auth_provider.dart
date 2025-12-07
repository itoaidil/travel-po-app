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
    print('🔍 AuthProvider: Starting initialization...');
    _isLoading = true;
    notifyListeners();

    try {
      final po = await _authService.getSavedPO();
      if (po != null) {
        print('✅ AuthProvider: Found saved PO - ${po.name} (ID: ${po.id})');
        _currentPO = po;
      } else {
        print('❌ AuthProvider: No saved session found');
      }
    } catch (e) {
      print('❌ AuthProvider: Error during init - $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 AuthProvider: Initialization complete. Logged in: $isLoggedIn');
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    print('🔐 AuthProvider: Login attempt for $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        _currentPO = result['po'];
        print('✅ AuthProvider: Login successful - ${_currentPO!.name}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        print('❌ AuthProvider: Login failed - $_error');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider: Login error - $e');
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
