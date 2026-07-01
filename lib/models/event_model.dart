class EventModel {
  final int id;
  final String title;
  final String? description;
  final String eventType;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final String? coverImageUrl;
  final bool registrationOpen;
  final int registrationsCount;
  final DateTime? createdAt;
  final int? communityId;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.eventType = 'general',
    this.location,
    required this.startDate,
    this.endDate,
    this.coverImageUrl,
    this.registrationOpen = true,
    this.registrationsCount = 0,
    this.createdAt,
    this.communityId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      eventType: json['event_type']?.toString() ?? 'general',
      location: json['location']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString()).toLocal()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString()).toLocal()
          : null,
      coverImageUrl: json['cover_image_url']?.toString(),
      registrationOpen: json['registration_open'] == true,
      registrationsCount: int.tryParse(json['registrations_count'].toString()) ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()).toLocal() : null,
      communityId: json['community_id'] != null ? int.tryParse(json['community_id'].toString()) : null,
    );
  }
}
