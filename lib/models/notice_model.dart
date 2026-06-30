class NoticeModel {
  final int id;
  final int authorId;
  final String? authorName;
  final String title;
  final String content;
  final String category;
  final String? mediaUrl;
  final bool isPinned;
  final DateTime? createdAt;

  NoticeModel({
    required this.id,
    required this.authorId,
    this.authorName,
    required this.title,
    required this.content,
    required this.category,
    this.mediaUrl,
    required this.isPinned,
    this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? 0,
      authorId: json['author_id'] ?? 0,
      authorName: json['author_name'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'general',
      mediaUrl: json['media_url'],
      isPinned: json['is_pinned'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
