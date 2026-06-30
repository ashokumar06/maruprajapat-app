import 'dart:convert';

/// Meta data for Youtube Video.
class YoutubeMetaData {
  /// Youtube video ID of the currently loaded video.
  final String videoId;

  /// Video title of the currently loaded video.
  final String title;

  /// Channel name or uploader of the currently loaded video.
  final String author;

  /// Total duration of the currently loaded video.
  final Duration duration;

  /// Creates [YoutubeMetaData] for Youtube Video.
  const YoutubeMetaData({
    this.videoId = '',
    this.title = '',
    this.author = '',
    this.duration = const Duration(),
  });

  /// Creates [YoutubeMetaData] from raw json video data.
  factory YoutubeMetaData.fromRawData(dynamic rawData) {
    final Map<String, dynamic> data = rawData is String
        ? Map<String, dynamic>.from(jsonDecode(rawData) as Map)
        : Map<String, dynamic>.from(rawData as Map);
    final durationInMs =
        (double.tryParse(data['duration'].toString()) ?? 0) * 1000;
    return YoutubeMetaData(
      videoId: data['videoId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      author: data['author']?.toString() ?? '',
      duration: Duration(milliseconds: durationInMs.floor()),
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'videoId: $videoId, '
        'title: $title, '
        'author: $author, '
        'duration: ${duration.inSeconds} sec.)';
  }
}
