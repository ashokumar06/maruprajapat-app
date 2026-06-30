class PostModel {
  final int id;
  final int authorId;
  final String? authorName;
  final String? authorPhoto;
  final String postType;
  final String? textContent;
  final String? mediaUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.authorId,
    this.authorName,
    this.authorPhoto,
    required this.postType,
    this.textContent,
    this.mediaUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      authorId: json['author_id'] ?? 0,
      authorName: json['author_name'],
      authorPhoto: json['author_photo'],
      postType: json['post_type'] ?? 'text',
      textContent: json['text_content'],
      mediaUrl: json['media_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
