import 'package:flutter/material.dart';

// API Configuration
class ApiConfig {
  // Local testing - gunakan ini saat development
  static const String baseUrl =
      'https://travel-api-production-23ae.up.railway.app';

  // Auth Endpoints
  static const String loginPO = '/api/po/login';
  static const String registerPO = '/api/po/register';

  // Vehicle Endpoints
  static const String vehicles = '/api/vehicles';

  // Driver Endpoints
  static const String drivers = '/api/drivers';

  // Schedule Endpoints
  static const String schedules = '/api/schedules';

  // Booking Endpoints
  static const String bookings = '/api/bookings';

  // Notification Endpoints
  static const String notifications = '/api/notifications';

  // Settlement Endpoints
  static const String settlements = '/api/settlements';

  // Travel Endpoints
  static const String travels = '/api/travels';

  // Location Endpoints
  static const String locations = '/api/locations';

  // Document Upload
  static const String uploadDocument = '/api/po/upload';
}

// App Colors
class AppColors {
  static const Color primary = Color(0xFF0D47A1); // Blue
  static const Color secondary = Color(0xFFFF9800); // Orange
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Light Blue

  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}

// App Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

// Responsive Breakpoints
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobile &&
        MediaQuery.of(context).size.width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}

// Vehicle Status
enum VehicleStatus { available, onTrip, maintenance, inactive }

// Driver Status
enum DriverStatus { active, onLeave, suspended, inactive }

// PO Status
enum POStatus { pending, approved, rejected, suspended }

// Settlement Status
enum SettlementStatus { pending, processing, completed, failed }

// Notification Type
enum NotificationType { booking, payment, maintenance, documentExpiry, system }
