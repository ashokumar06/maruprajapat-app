class FormModel {
  final int id;
  final String title;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  FormModel({
    required this.id,
    required this.title,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
