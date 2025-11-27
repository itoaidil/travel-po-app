class Vehicle {
  final int id;
  final String vehicleNumber;
  final String plateNumber;
  final String vehicleType; // Bus, Minibus, Van
  final String brand;
  final String model;
  final int year;
  final int capacity;
  final String status; // available, maintenance, inactive
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.plateNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.year,
    required this.capacity,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleNumber: json['vehicle_number'],
      plateNumber: json['plate_number'],
      vehicleType: json['vehicle_type'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      capacity: json['seat_capacity'] ?? json['capacity'],
      status: json['status'],
      isActive: json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Getter untuk compatibility dengan backend yang mengirim seat_capacity
  int get seatCapacity => capacity;

  Map<String, dynamic> toJson() {
    return {
      'vehicle_number': vehicleNumber,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      'brand': brand,
      'model': model,
      'year': year,
      'capacity': capacity,
      'status': status,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Helper untuk status badge color
  String get statusText {
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'maintenance':
        return 'Maintenance';
      case 'inactive':
        return 'Tidak Aktif';
      default:
        return status;
    }
  }

  // Helper untuk vehicle type display
  String get typeDisplay {
    switch (vehicleType.toLowerCase()) {
      case 'bus':
        return 'Bus';
      case 'minibus':
        return 'Minibus';
      case 'van':
        return 'Van';
      default:
        return vehicleType;
    }
  }
}
