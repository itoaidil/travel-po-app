import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class VehicleService {
  final AuthService _authService = AuthService();

  // Get all vehicles for current PO
  Future<List<Vehicle>> getVehicles() async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicles}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => Vehicle.fromJson(json))
              .toList();
        }
        throw Exception(data['message'] ?? 'Gagal mengambil data kendaraan');
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal mengambil data kendaraan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Get vehicle by ID
  Future<Vehicle> getVehicle(int id) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicles}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Vehicle.fromJson(data['vehicle']);
      } else {
        throw Exception('Failed to load vehicle');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create vehicle
  Future<void> createVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicles}'),
        headers: headers,
        body: jsonEncode(vehicleData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menambah kendaraan');
        }
        // Success - no need to return vehicle object
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Data tidak valid');
      }
      throw Exception('Gagal menambah kendaraan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update vehicle
  Future<void> updateVehicle(int id, Map<String, dynamic> vehicleData) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicles}/$id'),
        headers: headers,
        body: jsonEncode(vehicleData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal update kendaraan');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal update kendaraan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(int id) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vehicles}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menghapus kendaraan');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal menghapus kendaraan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Upload vehicle photo
  Future<String> uploadPhoto(String filePath) async {
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
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
