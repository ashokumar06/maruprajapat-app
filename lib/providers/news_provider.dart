import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/post_model.dart';

class NewsProvider extends ChangeNotifier {
  List<PostModel> _trendingPosts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get trendingPosts => _trendingPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNewsFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient().dio;
      final response = await client.get('/api/v1/posts/trending?page=1&per_page=20');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          _trendingPosts = (data['items'] as List)
              .map((e) => PostModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      _error = 'सर्वर रखरखाव के अधीन है, इसे जल्द ही अपडेट किया जाएगा।';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String text,
    String? mediaUrl,
    bool isDraft = false,
    String? youtubeUrl,
    String postType = 'text',
    bool isPinned = false,
    String? locationName,
    double? latitude,
    double? longitude,
    List<String>? pollOptions,
    String? visibility,
  }) async {
    try {
      final client = ApiClient().dio;
      final response = await client.post('/api/v1/posts/', data: {
        'post_type': postType,
        'text_content': text,
        'media_url': mediaUrl,
        'is_draft': isDraft,
        'youtube_url': youtubeUrl,
        'is_pinned': isPinned,
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'poll_options': pollOptions,
        'visibility': visibility,
      });

      if (response.statusCode == 201) {
        await fetchNewsFeed();
        return true;
      }
    } catch (e) {
      print('Error creating post: $e');
    }
    return false;
  }

  Future<bool> updatePost(int postId, {
    String? text,
    String? mediaUrl,
    bool? isDraft,
    String? youtubeUrl,
    bool? isPinned,
    String? locationName,
    double? latitude,
    double? longitude,
    List<String>? pollOptions,
    String? visibility,
  }) async {
    try {
      final client = ApiClient().dio;
      final response = await client.put('/api/v1/posts/$postId', data: {
        'text_content': text,
        'media_url': mediaUrl,
        'is_draft': isDraft,
        'youtube_url': youtubeUrl,
        'is_pinned': isPinned,
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'poll_options': pollOptions,
        'visibility': visibility,
      });
      if (response.statusCode == 200) {
        await fetchNewsFeed();
        return true;
      }
    } catch (e) {
      print('Error updating post: $e');
    }
    return false;
  }

  Future<bool> publishDraft(int postId) async {
    return updatePost(postId, isDraft: false);
  }

  Future<bool> deletePost(int postId) async {
    try {
      final client = ApiClient().dio;
      final response = await client.delete('/api/v1/posts/$postId');
      if (response.statusCode == 200) {
        await fetchNewsFeed();
        return true;
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
    return false;
  }

  Future<PostModel?> votePoll(int postId, int optionIndex) async {
    try {
      final client = ApiClient().dio;
      final response = await client.post(
        '/api/v1/posts/$postId/vote',
        queryParameters: {'option_index': optionIndex},
      );
      if (response.statusCode == 200) {
        final updatedPost = PostModel.fromJson(response.data);
        final index = _trendingPosts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _trendingPosts[index] = updatedPost;
          notifyListeners();
        }
        return updatedPost;
      }
    } catch (e) {
      print('Error voting on poll: $e');
    }
    return null;
  }
}
