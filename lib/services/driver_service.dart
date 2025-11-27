import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class DriverService {
  final AuthService _authService = AuthService();

  // Get all drivers for current PO
  Future<List<Driver>> getDrivers() async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.drivers}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Driver.fromJson(json))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal mengambil data driver');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Get driver by ID
  Future<Driver> getDriver(int id) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.drivers}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Driver.fromJson(data['driver']);
      } else {
        throw Exception('Failed to load driver');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create driver
  Future<void> createDriver(Map<String, dynamic> driverData) async {
    try {
      final headers = await _authService.getHeaders();
      print('Creating driver with data: $driverData');
      print('API URL: ${ApiConfig.baseUrl}${ApiConfig.drivers}');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.drivers}'),
        headers: headers,
        body: jsonEncode(driverData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menambah driver');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Data tidak valid');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Gagal menambah driver (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Driver service error: $e');
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update driver
  Future<void> updateDriver(int id, Map<String, dynamic> driverData) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.drivers}/$id'),
        headers: headers,
        body: jsonEncode(driverData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal update driver');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal update driver');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Delete driver
  Future<void> deleteDriver(int id) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.drivers}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menghapus driver');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal menghapus driver');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Upload driver photo/document
  Future<String> uploadDocument(String filePath) async {
    try {
      final headers = await _authService.getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadDocument}'),
      );

      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final data = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return data['url'];
      } else {
        throw Exception('Failed to upload document');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
