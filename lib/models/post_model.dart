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
  final bool isDraft;
  final String? youtubeUrl;
  final bool isPinned;
  final String? locationName;
  final double? latitude;
  final double? longitude;
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
    this.isDraft = false,
    this.youtubeUrl,
    this.isPinned = false,
    this.locationName,
    this.latitude,
    this.longitude,
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
      isDraft: json['is_draft'] ?? false,
      youtubeUrl: json['youtube_url'],
      isPinned: json['is_pinned'] ?? false,
      locationName: json['location_name'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
