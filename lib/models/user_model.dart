class UserModel {
  final String uid;
  final String fullName;
  final String fatherName;
  final String village;
  final String district;
  final String gotra;
  final String role;
  final bool isVerified;
  final bool isBanned;
  final String profilePhotoUrl;
  final String contactNumber;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    this.fatherName = '',
    this.village = '',
    this.district = '',
    this.gotra = '',
    this.role = 'guest',
    this.isVerified = false,
    this.isBanned = false,
    this.profilePhotoUrl = '',
    this.contactNumber = '',
    this.createdAt,
  });

  // Convert Firestore JSON to model
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      uid: id,
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      fatherName: json['father_name'] ?? json['fatherName'] ?? '',
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      gotra: json['gotra'] ?? '',
      role: json['role'] ?? 'guest',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isBanned: json['is_banned'] ?? json['isBanned'] ?? false,
      profilePhotoUrl: json['profile_photo_url'] ?? json['profilePhotoUrl'] ?? '',
      contactNumber: json['phone'] ?? json['contactNumber'] ?? '',
      createdAt: (json['created_at'] != null || json['createdAt'] != null)
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
          : null,
    );
  }

  // Convert model to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'fatherName': fatherName,
      'village': village,
      'district': district,
      'gotra': gotra,
      'role': role,
      'isVerified': isVerified,
      'isBanned': isBanned,
      'profilePhotoUrl': profilePhotoUrl,
      'contactNumber': contactNumber,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
