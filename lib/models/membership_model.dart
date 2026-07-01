class MembershipRequestModel {
  final int id;
  final int userId;
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final String village;
  final String district;
  final String? gotra;
  final String? occupation;
  final String? education;
  final String? contactNumber;
  final String? referencePerson;
  final String? profilePhotoUrl;
  final String? aadhaarFrontUrl;
  final String? aadhaarBackUrl;
  final String status; // pending, approved, rejected, correction_needed
  final String? adminNote;
  final DateTime? submittedAt;

  MembershipRequestModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.fatherName,
    this.motherName,
    required this.village,
    required this.district,
    this.gotra,
    this.occupation,
    this.education,
    this.contactNumber,
    this.referencePerson,
    this.profilePhotoUrl,
    this.aadhaarFrontUrl,
    this.aadhaarBackUrl,
    required this.status,
    this.adminNote,
    this.submittedAt,
  });

  factory MembershipRequestModel.fromJson(Map<String, dynamic> json) {
    return MembershipRequestModel(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'] ?? 0,
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      fatherName: json['father_name'] ?? json['fatherName'],
      motherName: json['mother_name'] ?? json['motherName'],
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      gotra: json['gotra'] ?? '',
      occupation: json['occupation'],
      education: json['education'],
      contactNumber: json['contact_number'] ?? json['contactNumber'],
      referencePerson: json['reference_person'] ?? json['referencePerson'],
      profilePhotoUrl: json['profile_photo_url'] ?? json['profilePhotoUrl'],
      aadhaarFrontUrl: json['aadhaar_front_url'] ?? json['aadhaarFrontUrl'],
      aadhaarBackUrl: json['aadhaar_back_url'] ?? json['aadhaarBackUrl'],
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
      'father_name': fatherName,
      'mother_name': motherName,
      'village': village,
      'district': district,
      'gotra': gotra,
      'occupation': occupation,
      'education': education,
      'contact_number': contactNumber,
      'reference_person': referencePerson,
      'profile_photo_url': profilePhotoUrl,
      'aadhaar_front_url': aadhaarFrontUrl,
      'aadhaar_back_url': aadhaarBackUrl,
      'status': status,
      'admin_note': adminNote,
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }
}
