class Location {
  final int id;
  final String name;
  final String type;
  final String? parentName;
  final bool isPopular;
  final double? latitude;
  final double? longitude;

  Location({
    required this.id,
    required this.name,
    required this.type,
    this.parentName,
    required this.isPopular,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      parentName: json['parent_name'],
      isPopular: json['is_popular'] == 1,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  String get displayName {
    if (parentName != null && parentName!.isNotEmpty) {
      return '$name, $parentName';
    }
    return name;
  }
}
