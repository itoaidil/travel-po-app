import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../utils/constants.dart';

class LocationService {
  Future<List<Location>> getLocations({String? search}) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.locations}';
      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> locationsJson = data['data'];
          return locationsJson.map((json) => Location.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  Future<List<Location>> getPopularLocations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.locations}/popular'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> locationsJson = data['data'];
          return locationsJson.map((json) => Location.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching popular locations: $e');
      return [];
    }
  }

  // Estimate travel time based on distance (simplified calculation)
  Duration estimateTravelTime(Location origin, Location destination) {
    // Default: 2 hours (since we don't have lat/long in database)
    return const Duration(hours: 2);
  }
}
