import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme_config.dart';
import '../../models/post_model.dart';
import '../../services/api_client.dart';
import '../widgets/inline_youtube_player.dart';
import '../widgets/post_content_view.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? _post;
  List<dynamic> _comments = [];
  bool _isLoading = false;
  bool _isLoadingComments = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPostDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostDetails() async {
    setState(() => _isLoading = true);
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('/api/v1/posts/${widget.postId}');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _post = PostModel.fromJson(response.data);
        });
        _fetchComments();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पोस्ट विवरण लोड करने में विफल'),
          backgroundColor: ThemeConfig.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final dio = ApiClient().dio;
      final response = await dio.get(
        '/api/v1/posts/${widget.postId}/comments?page=1&per_page=50',
      );
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _comments = response.data['items'] ?? [];
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    try {
      final dio = ApiClient().dio;
      final response = await dio.post('/api/v1/posts/${_post!.id}/like');
      if (response.statusCode == 200) {
        _fetchPostDetails();
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  void _sharePost() {
    final link = 'maruprajapat://posts/${widget.postId}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('शेयर लिंक कॉपी कर लिया गया है! इसे शेयर करें।'),
        backgroundColor: ThemeConfig.success,
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_comments.length >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'एक पोस्ट पर अधिकतम 100 टिप्पणियाँ ही जोड़ी जा सकती हैं।',
          ),
          backgroundColor: ThemeConfig.error,
        ),
      );
      return;
    }

    try {
      final dio = ApiClient().dio;
      final response = await dio.post(
        '/api/v1/posts/${widget.postId}/comments',
        data: {'content': text},
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        _fetchComments();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('टिप्पणी जोड़ने में विफल'),
          backgroundColor: ThemeConfig.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _post == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: ThemeConfig.primary),
        ),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('त्रुटि')),
        body: const Center(child: Text('पोस्ट नहीं मिली या हटा दी गई है।')),
      );
    }

    final hasHitLimit = _comments.length >= 100;

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'पोस्ट विवरण',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPostDetails,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Post Details Card
                    Card(
                      color: ThemeConfig.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: ThemeConfig.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_post!.isPinned) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.push_pin,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'पिन की गई पोस्ट',
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: ThemeConfig.border,
                                  backgroundImage: _post!.authorPhoto != null
                                      ? NetworkImage(_post!.authorPhoto!)
                                      : null,
                                  child: _post!.authorPhoto == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _post!.authorName ?? 'अज्ञात',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Text(
                                        'हाल ही में',
                                        style: TextStyle(
                                          color: ThemeConfig.textHint,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_post!.textContent != null &&
                                _post!.textContent!.isNotEmpty) ...[
                              PostContentView(
                                text: _post!.textContent!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: ThemeConfig.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_post!.youtubeUrl != null &&
                                _post!.youtubeUrl!.isNotEmpty) ...[
                              InlineYoutubePlayer(videoUrl: _post!.youtubeUrl!),
                              const SizedBox(height: 12),
                            ] else if (_post!.mediaUrl != null &&
                                _post!.mediaUrl!.isNotEmpty) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _post!.mediaUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_post!.locationName != null &&
                                _post!.locationName!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final lat = _post!.latitude ?? 25.75;
                                  final lon = _post!.longitude ?? 71.38;
                                  final url = Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _post!.locationName!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            const Divider(color: ThemeConfig.divider),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_post!.likesCount} लाइक्स',
                                  style: const TextStyle(
                                    color: ThemeConfig.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${_comments.length} टिप्पणियाँ',
                                  style: const TextStyle(
                                    color: ThemeConfig.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: _toggleLike,
                                  icon: const Icon(
                                    Icons.thumb_up_outlined,
                                    color: ThemeConfig.textSecondary,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'लाइक',
                                    style: TextStyle(
                                      color: ThemeConfig.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _sharePost,
                                  icon: const Icon(
                                    Icons.share_outlined,
                                    color: ThemeConfig.textSecondary,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'शेयर',
                                    style: TextStyle(
                                      color: ThemeConfig.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Comments Header
                    const Text(
                      'टिप्पणियाँ (Comments)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Comments List
                    if (_isLoadingComments && _comments.isEmpty)
                      const Center(
                        child: CircularProgressIndicator(
                          color: ThemeConfig.primary,
                        ),
                      )
                    else if (_comments.isEmpty)
                      const Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'कोई टिप्पणी नहीं है। पहली टिप्पणी लिखें!',
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final item = _comments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: ThemeConfig.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: ThemeConfig.border),
                            ),
                            child: ListTile(
                              title: Text(
                                item['author_name'] ?? 'अज्ञात',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              subtitle: Text(
                                item['content'] ?? '',
                                style: const TextStyle(
                                  color: ThemeConfig.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Message input bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasHitLimit)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'टिप्पणियों की अधिकतम सीमा (100) पूरी हो चुकी है।',
                          style: TextStyle(
                            color: ThemeConfig.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            enabled: !hasHitLimit,
                            decoration: InputDecoration(
                              hintText: hasHitLimit
                                  ? 'सीमा समाप्त (Max 100)'
                                  : 'टिप्पणी लिखें...',
                              hintStyle: const TextStyle(
                                color: ThemeConfig.textHint,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: hasHitLimit
                              ? Colors.grey
                              : ThemeConfig.primary,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: hasHitLimit ? null : _submitComment,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
