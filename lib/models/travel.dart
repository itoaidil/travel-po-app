class Travel {
  final int id;
  final int poId;
  final int vehicleId;
  final int? driverId;
  final String routeName;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime? arrivalTime;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final String status;
  final String? plateNumber;
  final String? vehicleType;
  final String? driverName;
  final int? totalBookings;
  final DateTime createdAt;

  Travel({
    required this.id,
    required this.poId,
    required this.vehicleId,
    this.driverId,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.status,
    this.plateNumber,
    this.vehicleType,
    this.driverName,
    this.totalBookings,
    required this.createdAt,
  });

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'],
      poId: json['po_id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      routeName:
          json['route_name'] ?? '${json['origin']} - ${json['destination']}',
      origin: json['origin'],
      destination: json['destination'],
      departureTime: DateTime.parse(json['departure_time']),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.parse(json['arrival_time'])
          : null,
      price: _parsePrice(json['price']),
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      status: json['status'] ?? 'scheduled',
      plateNumber: json['plate_number'],
      vehicleType: json['vehicle_type'],
      driverName: json['driver_name'],
      totalBookings: json['total_bookings'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'po_id': poId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'route_name': routeName,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'price': price,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'status': status,
    };
  }
}
