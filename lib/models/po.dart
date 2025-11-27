class PO {
  final int id;
  final String name;
  final String? logoUrl;
  final String? npwp;
  final String? businessLicense;
  final String? accountNumber;
  final String? bankName;
  final String? accountHolder;
  final double commissionRate;
  final String status; // pending, approved, rejected, suspended
  final DateTime? verifiedAt;
  final String? rejectedReason;
  final DateTime createdAt;

  PO({
    required this.id,
    required this.name,
    this.logoUrl,
    this.npwp,
    this.businessLicense,
    this.accountNumber,
    this.bankName,
    this.accountHolder,
    this.commissionRate = 10.0,
    this.status = 'pending',
    this.verifiedAt,
    this.rejectedReason,
    required this.createdAt,
  });

  factory PO.fromJson(Map<String, dynamic> json) {
    // Handle commission_rate as string or number
    double parseCommissionRate(dynamic value) {
      if (value == null) return 10.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 10.0;
      return 10.0;
    }

    return PO(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      npwp: json['npwp'],
      businessLicense: json['business_license'],
      accountNumber: json['account_number'],
      bankName: json['bank_name'],
      accountHolder: json['account_holder'],
      commissionRate: parseCommissionRate(json['commission_rate']),
      status: json['status'] ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      rejectedReason: json['rejected_reason'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'npwp': npwp,
      'business_license': businessLicense,
      'account_number': accountNumber,
      'bank_name': bankName,
      'account_holder': accountHolder,
      'commission_rate': commissionRate,
      'status': status,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejected_reason': rejectedReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
