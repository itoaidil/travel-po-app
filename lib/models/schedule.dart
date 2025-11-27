class VehicleSchedule {
  final int id;
  final int vehicleId;
  final int driverId;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final double price;
  final int? durationMinutes;
  final double? distanceKm;
  final int availableSeats;

  VehicleSchedule({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.price,
    this.durationMinutes,
    this.distanceKm,
    required this.availableSeats,
  });

  factory VehicleSchedule.fromJson(Map<String, dynamic> json) {
    return VehicleSchedule(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      driverId: json['driver_id'],
      origin: json['origin'] ?? 'Padang',
      destination: json['destination'],
      departureTime: DateTime.parse(json['departure_time']),
      price: json['price']?.toDouble() ?? 0.0,
      durationMinutes: json['duration_minutes'],
      distanceKm: json['distance_km']?.toDouble(),
      availableSeats: json['available_seats'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      'price': price,
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'available_seats': availableSeats,
    };
  }
}
