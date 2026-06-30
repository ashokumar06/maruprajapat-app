class MembershipRequestModel {
  final int id;
  final int userId;
  final String fullName;
  final String village;
  final String district;
  final String status; // pending, approved, rejected, correction_needed
  final String? adminNote;
  final DateTime? submittedAt;

  MembershipRequestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.village,
    required this.district,
    required this.status,
    this.adminNote,
    this.submittedAt,
  });

  factory MembershipRequestModel.fromJson(Map<String, dynamic> json) {
    return MembershipRequestModel(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? 0,
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      status: json['status'] ?? 'pending',
      adminNote: json['admin_note'] ?? json['adminNote'],
      submittedAt: json['submitted_at'] != null 
          ? DateTime.tryParse(json['submitted_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'village': village,
      'district': district,
      'status': status,
      'admin_note': adminNote,
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }
}
