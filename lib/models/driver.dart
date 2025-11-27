class Driver {
  final int id;
  final int? poId;
  final String name;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final String? phone;
  final String? emergencyContact;
  final String? licenseNumber;
  final String? licenseType; // A, B1, B2, C
  final DateTime? licenseExpiry;
  final DateTime? joinDate;
  final String status; // active, on_leave, suspended, inactive
  final int totalTrips;
  final int ratingCount;

  Driver({
    required this.id,
    this.poId,
    required this.name,
    this.photoUrl,
    this.dateOfBirth,
    this.address,
    this.phone,
    this.emergencyContact,
    this.licenseNumber,
    this.licenseType,
    this.licenseExpiry,
    this.joinDate,
    this.status = 'active',
    this.totalTrips = 0,
    this.ratingCount = 0,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      poId: json['po_id'],
      name: json['full_name'] ?? json['name'],
      photoUrl: json['photo_url'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      address: json['address'],
      phone: json['phone'],
      emergencyContact: json['emergency_contact'],
      licenseNumber: json['license_number'],
      licenseType: json['license_type'],
      licenseExpiry: json['license_expiry'] != null
          ? DateTime.parse(json['license_expiry'])
          : null,
      joinDate: json['join_date'] != null
          ? DateTime.parse(json['join_date'])
          : null,
      status: json['status'] ?? 'active',
      totalTrips: json['total_trips'] ?? 0,
      ratingCount: json['rating_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'po_id': poId,
      'full_name': name,
      'photo_url': photoUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'address': address,
      'phone': phone,
      'emergency_contact': emergencyContact,
      'license_number': licenseNumber,
      'license_type': licenseType,
      'license_expiry': licenseExpiry?.toIso8601String(),
      'join_date': joinDate?.toIso8601String(),
      'status': status,
      'total_trips': totalTrips,
      'rating_count': ratingCount,
    };
  }
}
