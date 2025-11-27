import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/travel.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class TravelService {
  final AuthService _authService = AuthService();

  // Get all travels for current PO
  Future<List<Travel>> getTravels() async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.travels}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((json) => Travel.fromJson(json))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal mengambil data perjalanan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Create travel
  Future<void> createTravel(Map<String, dynamic> travelData) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.travels}'),
        headers: headers,
        body: jsonEncode(travelData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menambah perjalanan');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Data tidak valid');
      }
      throw Exception('Gagal menambah perjalanan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Update travel
  Future<void> updateTravel(int id, Map<String, dynamic> travelData) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.travels}/$id'),
        headers: headers,
        body: jsonEncode(travelData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal update perjalanan');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal update perjalanan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  // Delete travel
  Future<void> deleteTravel(int id) async {
    try {
      final headers = await _authService.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.travels}/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal menghapus perjalanan');
        }
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesi berakhir, silakan login kembali');
      }
      throw Exception('Gagal menghapus perjalanan');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
