/// Complaint model for the flutter app.

class ComplaintModel {
  final int id;
  final String? complaintNumber;
  final int userId;
  final String? userName;
  final String? userPhoto;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? location;
  final List<String>? imageUrls;
  final String? resolutionNote;
  final String? cancelReason;
  final int? assignedTo;
  final String? assigneeName;
  final List<StatusHistoryItem> statusHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ComplaintModel({
    required this.id,
    this.complaintNumber,
    required this.userId,
    this.userName,
    this.userPhoto,
    required this.title,
    required this.description,
    this.category = 'other',
    this.priority = 'medium',
    this.status = 'open',
    this.location,
    this.imageUrls,
    this.resolutionNote,
    this.cancelReason,
    this.assignedTo,
    this.assigneeName,
    this.statusHistory = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'],
      complaintNumber: json['complaint_number'],
      userId: json['user_id'],
      userName: json['user_name'],
      userPhoto: json['user_photo'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'other',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      location: json['location'],
      imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : null,
      resolutionNote: json['resolution_note'],
      cancelReason: json['cancel_reason'],
      assignedTo: json['assigned_to'],
      assigneeName: json['assignee_name'],
      statusHistory: json['status_history'] != null
          ? (json['status_history'] as List).map((e) => StatusHistoryItem.fromJson(e)).toList()
          : [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}

class StatusHistoryItem {
  final String? oldStatus;
  final String newStatus;
  final String? note;
  final int changedBy;
  final String? changedByName;
  final DateTime? createdAt;

  StatusHistoryItem({
    this.oldStatus,
    required this.newStatus,
    this.note,
    required this.changedBy,
    this.changedByName,
    this.createdAt,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      oldStatus: json['old_status'],
      newStatus: json['new_status'] ?? 'open',
      note: json['note'],
      changedBy: json['changed_by'] ?? 0,
      changedByName: json['changed_by_name'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
