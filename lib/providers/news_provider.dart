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

  Future<bool> createPost(String text) async {
    try {
      final client = ApiClient().dio;
      final response = await client.post('/api/v1/posts/', data: {
        'post_type': 'text',
        'text_content': text,
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
}
