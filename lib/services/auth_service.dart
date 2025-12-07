import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/po.dart';
import '../utils/constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _poKey = 'po_data';

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginPO}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ AuthService: Login API success');
        // Save token and PO data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['token']);
        await prefs.setString(_poKey, jsonEncode(data['po']));
        print('💾 AuthService: Saved token and PO data to storage');

        return {
          'success': true,
          'token': data['token'],
          'po': PO.fromJson(data['po']),
        };
      } else {
        print('❌ AuthService: Login API failed - ${data['message']}');
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerPO}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registrasi berhasil! Silakan login.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registrasi gagal',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get saved PO data
  Future<PO?> getSavedPO() async {
    try {
      print('💾 AuthService: Getting saved PO from storage...');
      final prefs = await SharedPreferences.getInstance();
      final poString = prefs.getString(_poKey);

      if (poString != null) {
        print('✅ AuthService: Found PO data: ${poString.substring(0, 100)}...');
        final po = PO.fromJson(jsonDecode(poString));
        return po;
      } else {
        print('❌ AuthService: No PO data in storage');
        return null;
      }
    } catch (e) {
      print('❌ AuthService: Error getting saved PO - $e');
      return null;
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_poKey);
  }

  // Get headers with auth token
  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
