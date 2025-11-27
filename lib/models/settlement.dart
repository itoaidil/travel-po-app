class Settlement {
  final int id;
  final int poId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalBookings;
  final double grossRevenue;
  final double commissionAmount;
  final double netRevenue;
  final String status; // pending, processing, completed, failed
  final DateTime? paidAt;
  final String? paymentProofUrl;
  final String? notes;
  final DateTime createdAt;

  Settlement({
    required this.id,
    required this.poId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalBookings,
    required this.grossRevenue,
    required this.commissionAmount,
    required this.netRevenue,
    required this.status,
    this.paidAt,
    this.paymentProofUrl,
    this.notes,
    required this.createdAt,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'],
      poId: json['po_id'],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      totalBookings: json['total_bookings'] ?? 0,
      grossRevenue: json['gross_revenue']?.toDouble() ?? 0.0,
      commissionAmount: json['commission_amount']?.toDouble() ?? 0.0,
      netRevenue: json['net_revenue']?.toDouble() ?? 0.0,
      status: json['settlement_status'] ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      paymentProofUrl: json['payment_proof_url'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'po_id': poId,
      'period_start': periodStart.toIso8601String().split('T')[0],
      'period_end': periodEnd.toIso8601String().split('T')[0],
      'total_bookings': totalBookings,
      'gross_revenue': grossRevenue,
      'commission_amount': commissionAmount,
      'net_revenue': netRevenue,
      'settlement_status': status,
      'paid_at': paidAt?.toIso8601String(),
      'payment_proof_url': paymentProofUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
