import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BookingService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> getBookings(int poId) async {
    try {
      final url = '$baseUrl/api/bookings?po_id=$poId';
      print('🌐 BookingService: Fetching bookings from $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('🌐 BookingService: Response status ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🌐 BookingService: Response data: ${data.toString().substring(0, 200)}...');
        
        if (data['success'] == true) {
          final bookings = List<Map<String, dynamic>>.from(data['data'] ?? []);
          print('✅ BookingService: Parsed ${bookings.length} bookings');
          return bookings;
        }
      }
      print('❌ BookingService: Failed to load bookings - Status ${response.statusCode}');
      throw Exception('Failed to load bookings');
    } catch (e) {
      print('❌ BookingService: Error - $e');
      throw Exception('Error fetching bookings: $e');
    }
  }

  Future<bool> confirmBooking(int bookingId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/bookings/$bookingId/confirm'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error confirming booking: $e');
    }
  }

  Future<bool> cancelBooking(int bookingId, String reason) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/bookings/$bookingId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }
}
