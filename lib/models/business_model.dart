class BusinessModel {
  final int id;
  final String businessName;
  final String ownerName;
  final String category;
  final String? description;
  final String? address;
  final String? mobile;
  final List<String>? images;
  final bool isApproved;
  final DateTime? createdAt;

  BusinessModel({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.category,
    this.description,
    this.address,
    this.mobile,
    this.images,
    required this.isApproved,
    this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] ?? 0,
      businessName: json['business_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      address: json['address'],
      mobile: json['mobile'],
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      isApproved: json['is_approved'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
