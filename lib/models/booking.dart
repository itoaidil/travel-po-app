class Booking {
  final int id;
  final int userId;
  final int scheduleId;
  final String passengerName;
  final String passengerPhone;
  final String pickupLocation;
  final String? dropoffLocation;
  final int seatsBooked;
  final double totalPrice;
  final String paymentStatus; // pending, paid, failed, refunded
  final String bookingStatus; // pending, confirmed, cancelled, completed
  final DateTime? paidAt;
  final DateTime createdAt;

  // Relations
  final String? userName;
  final String? origin;
  final String? destination;
  final DateTime? departureTime;

  Booking({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupLocation,
    this.dropoffLocation,
    required this.seatsBooked,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bookingStatus,
    this.paidAt,
    required this.createdAt,
    this.userName,
    this.origin,
    this.destination,
    this.departureTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      scheduleId: json['schedule_id'],
      passengerName: json['passenger_name'],
      passengerPhone: json['passenger_phone'],
      pickupLocation: json['pickup_location'],
      dropoffLocation: json['dropoff_location'],
      seatsBooked: json['seats_booked'],
      totalPrice: json['total_price']?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'pending',
      bookingStatus: json['booking_status'] ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
      origin: json['origin'],
      destination: json['destination'],
      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'schedule_id': scheduleId,
      'passenger_name': passengerName,
      'passenger_phone': passengerPhone,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'seats_booked': seatsBooked,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'booking_status': bookingStatus,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
