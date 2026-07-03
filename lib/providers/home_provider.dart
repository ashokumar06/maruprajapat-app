import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/notice_model.dart';
import '../models/post_model.dart';

class HomeProvider extends ChangeNotifier {
  List<NoticeModel> _notices = [];
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<NoticeModel> get notices => _notices;
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final client = ApiClient().dio;
      
      // Fetch both in parallel
      final results = await Future.wait([
        client.get('/api/v1/notices/important'),
        client.get('/api/v1/posts/feed?page=1&per_page=10'),
      ]);

      final noticeResponse = results[0];
      final postResponse = results[1];

      if (noticeResponse.statusCode == 200) {
        _notices = (noticeResponse.data as List)
            .map((e) => NoticeModel.fromJson(e))
            .toList();
      }

      if (postResponse.statusCode == 200) {
        final data = postResponse.data;
        if (data is Map && data['success'] == true) {
          _posts = (data['items'] as List)
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

  void updatePostLocally(PostModel updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }
  
  void toggleLikeLocally(int postId, {required bool isLiked, required int likesCount}) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      var jsonMap = _posts[index].toJson();
      jsonMap['is_liked'] = isLiked;
      jsonMap['likes_count'] = likesCount;
      _posts[index] = PostModel.fromJson(jsonMap);
      notifyListeners();
    }
  }

  void incrementCommentCountLocally(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      var jsonMap = _posts[index].toJson();
      jsonMap['comments_count'] = (jsonMap['comments_count'] ?? 0) + 1;
      _posts[index] = PostModel.fromJson(jsonMap);
      notifyListeners();
    }
  }
}
