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
  final String? visibility;
  final bool isPinned;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final List<String>? pollOptions;
  final Map<String, dynamic>? pollVotes;
  final int? communityId;

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
    this.visibility,
    this.isPinned = false,
    this.locationName,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.pollOptions,
    this.pollVotes,
    this.communityId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      authorId: int.tryParse(json['author_id'].toString()) ?? 0,
      authorName: json['author_name']?.toString(),
      authorPhoto: json['author_photo']?.toString(),
      postType: json['post_type']?.toString() ?? 'text',
      textContent: json['text_content']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      likesCount: int.tryParse(json['likes_count'].toString()) ?? 0,
      commentsCount: int.tryParse(json['comments_count'].toString()) ?? 0,
      isDraft: json['is_draft'] == true,
      youtubeUrl: json['youtube_url']?.toString(),
      visibility: json['visibility']?.toString(),
      isPinned: json['is_pinned'] == true,
      locationName: json['location_name']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      pollOptions: json['poll_options'] != null
          ? List<String>.from(json['poll_options'].map((x) => x.toString()))
          : null,
      pollVotes: json['poll_votes'] != null
          ? Map<String, dynamic>.from(json['poll_votes'])
          : null,
      communityId: json['community_id'] != null
          ? int.tryParse(json['community_id'].toString())
          : null,
    );
  }
}
