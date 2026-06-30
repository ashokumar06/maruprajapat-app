import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/news_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_model.dart';
import '../../services/api_client.dart';
import '../widgets/inline_youtube_player.dart';
import '../widgets/post_content_view.dart';
import '../widgets/poll_view.dart';
import 'create_post_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _showDrafts = false;
  List<PostModel> _drafts = [];
  bool _isLoadingDrafts = false;

  String _t(BuildContext context, String hi, String en) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : hi;
  }

  bool _isMemberOrAdmin(String? role) {
    return role == 'member' || role == 'admin' || role == 'superadmin';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNewsFeed();
    });
  }

  Future<void> _fetchDrafts() async {
    setState(() => _isLoadingDrafts = true);
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('/api/v1/posts/drafts');
      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data['items'] ?? [];
        setState(() {
          _drafts = items.map((e) => PostModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ड्राफ्ट लोड करने में विफल'),
          backgroundColor: ThemeConfig.error,
        ),
      );
    } finally {
      setState(() => _isLoadingDrafts = false);
    }
  }

  void _onTabChanged(bool showDrafts) {
    setState(() {
      _showDrafts = showDrafts;
    });
    if (showDrafts) {
      _fetchDrafts();
    } else {
      context.read<NewsProvider>().fetchNewsFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(
          _t(context, 'समाज फीड', 'Community Feed'),
          style: const TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final role = authProvider.currentUserModel?.role;
          return Column(
            children: [
              // Toggle Tabs
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      label: _t(context, 'सभी पोस्ट', 'All Posts'),
                      active: !_showDrafts,
                      onTap: () => _onTabChanged(false),
                    ),
                    if (_isMemberOrAdmin(role)) ...[
                      const SizedBox(width: 8),
                      _buildTabButton(
                        label: _t(context, 'मेरे ड्राफ्ट', 'My Drafts'),
                        active: _showDrafts,
                        onTap: () => _onTabChanged(true),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: ThemeConfig.divider),
              const SizedBox(height: 8),

              // Main Feed List
              Expanded(
                child: _showDrafts ? _buildDraftsList() : _buildPublicFeedList(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final role = authProvider.currentUserModel?.role;
          if (role == 'member' || role == 'admin' || role == 'superadmin') {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                ).then((_) {
                  // Refresh active list
                  _onTabChanged(_showDrafts);
                });
              },
              backgroundColor: ThemeConfig.primary,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'पोस्ट',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          height: 38,
          decoration: BoxDecoration(
            color: active ? ThemeConfig.primary : ThemeConfig.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? ThemeConfig.primary : ThemeConfig.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : ThemeConfig.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublicFeedList() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading && newsProvider.trendingPosts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ThemeConfig.primary),
          );
        }

        if (newsProvider.trendingPosts.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => newsProvider.fetchNewsFeed(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 160),
                Center(
                  child: Text(
                    'कोई पोस्ट नहीं मिली।',
                    style: TextStyle(color: ThemeConfig.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => newsProvider.fetchNewsFeed(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: newsProvider.trendingPosts.length,
            itemBuilder: (context, index) {
              final post = newsProvider.trendingPosts[index];
              return _buildPostCard(post, isTrending: index < 3);
            },
          ),
        );
      },
    );
  }

  Widget _buildDraftsList() {
    if (_isLoadingDrafts) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConfig.primary),
      );
    }

    if (_drafts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchDrafts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 160),
            Center(
              child: Text(
                'कोई ड्राफ्ट पोस्ट नहीं मिली।',
                style: TextStyle(color: ThemeConfig.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDrafts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _drafts.length,
        itemBuilder: (context, index) {
          final post = _drafts[index];
          return _buildPostCard(post, isTrending: false);
        },
      ),
    );
  }

  Widget _buildPostCard(PostModel post, {required bool isTrending}) {
    final currentUserId = context.read<AuthProvider>().currentUserModel?.id;
    final isAuthor = post.authorId == currentUserId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: isTrending
                ? ThemeConfig.error.withOpacity(0.4)
                : ThemeConfig.divider,
            width: isTrending ? 1.5 : 0.8,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            if (post.isPinned) ...[
              Row(
                children: [
                  const Icon(Icons.push_pin, color: Colors.orange, size: 14),
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
            ] else if (isTrending) ...[
              const Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: ThemeConfig.error,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'लोकप्रिय पोस्ट',
                    style: TextStyle(
                      color: ThemeConfig.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Author Info Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ThemeConfig.border,
                  backgroundImage: post.authorPhoto != null
                      ? NetworkImage(post.authorPhoto!)
                      : null,
                  child: post.authorPhoto == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName ?? 'अज्ञात',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        post.isDraft ? 'ड्राफ्ट मोड' : 'हाल ही में',
                        style: const TextStyle(
                          color: ThemeConfig.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Author/Admin options popup menu
                Builder(
                  builder: (context) {
                    final isAdmin =
                        context.read<AuthProvider>().currentUserModel?.role ==
                        'admin';
                    if (isAuthor || isAdmin) {
                      return PopupMenuButton<String>(
                        onSelected: (val) => _handlePostMenuOption(val, post),
                        icon: const Icon(
                          Icons.more_vert,
                          color: ThemeConfig.textSecondary,
                        ),
                        itemBuilder: (context) => [
                          if (post.isDraft && isAuthor)
                            const PopupMenuItem(
                              value: 'publish',
                              child: Text('प्रकाशित करें (Publish)'),
                            ),
                          if (isAuthor)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('संपादित करें (Edit)'),
                            ),
                          if (isAdmin)
                            PopupMenuItem(
                              value: 'pin',
                              child: Text(
                                post.isPinned
                                    ? 'अनपिन करें (Unpin)'
                                    : 'पिन करें (Pin)',
                              ),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'हटाएं (Delete)',
                              style: TextStyle(color: ThemeConfig.error),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Text Content (polls render their text inside PollView)
            if (post.textContent != null && post.textContent!.isNotEmpty && post.postType != 'poll') ...[
              Builder(
                builder: (context) {
                  final text = post.textContent!;
                  final parts = text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
                  if (parts.length > 1 && post.textContent!.contains('\n\n')) {
                    final title = parts[0];
                    final body = parts.sublist(1).join('\n\n');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeConfig.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PostContentView(
                          text: body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ThemeConfig.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return PostContentView(
                      text: text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeConfig.textPrimary,
                        height: 1.45,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
            ],

            if (post.postType == 'poll') ...[
              PollView(post: post),
              const SizedBox(height: 12),
            ],

            // Video Player
            if (post.youtubeUrl != null && post.youtubeUrl!.isNotEmpty) ...[
              InlineYoutubePlayer(videoUrl: post.youtubeUrl!),
              const SizedBox(height: 12),
            ]
            // Image Content
            else if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.mediaUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12),
            ],

            Builder(
              builder: (context) {
                final hasLocation = post.locationName != null && post.locationName!.isNotEmpty;
                final text = post.textContent ?? '';
                final hashtagRegex = RegExp(r'#\w+');
                final hashtags = hashtagRegex.allMatches(text).map((m) => m.group(0)!).toList();
                
                if (!hasLocation && hashtags.isEmpty) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasLocation)
                        InkWell(
                          onTap: () async {
                            final lat = post.latitude ?? 25.75;
                            final lon = post.longitude ?? 71.38;
                            final url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_outlined, color: Colors.brown, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  post.locationName!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.brown.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ...hashtags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.brown.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }
            ),

            const SizedBox(height: 12),

            // Likes/Comments indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 18,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 7,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.thumb_up,
                                  size: 7,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 9,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 7,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.favorite,
                                  size: 7,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount}',
                      style: const TextStyle(
                        color: ThemeConfig.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${post.commentsCount} टिप्पणियाँ  •  12 शेयर',
                  style: const TextStyle(
                    color: ThemeConfig.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Like Button
                TextButton.icon(
                  onPressed: () => _toggleLike(post.id),
                  icon: const Icon(
                    Icons.thumb_up_outlined,
                    color: ThemeConfig.textSecondary,
                    size: 18,
                  ),
                  label: const Text(
                    'लाइक',
                    style: TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                // Comment Button
                TextButton.icon(
                  onPressed: () => _showCommentsSheet(post),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: ThemeConfig.textSecondary,
                    size: 18,
                  ),
                  label: const Text(
                    'टिप्पणी',
                    style: TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Share Button
                TextButton.icon(
                  onPressed: () => _sharePost(post.id),
                  icon: const Icon(
                    Icons.share_outlined,
                    color: ThemeConfig.textSecondary,
                    size: 18,
                  ),
                  label: const Text(
                    'शेयर',
                    style: TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                // Save Button
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('पोस्ट सेव की गई।'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bookmark_border,
                    color: ThemeConfig.textSecondary,
                    size: 18,
                  ),
                  label: const Text(
                    'सेव करें',
                    style: TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  void _handlePostMenuOption(String option, PostModel post) async {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    if (option == 'publish') {
      final success = await newsProvider.publishDraft(post.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('पोस्ट सफलतापूर्वक प्रकाशित हो गई है।'),
            backgroundColor: ThemeConfig.success,
          ),
        );
        _onTabChanged(_showDrafts);
      }
    } else if (option == 'delete') {
      final success = await newsProvider.deletePost(post.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('पोस्ट हटा दी गई है।'),
            backgroundColor: ThemeConfig.success,
          ),
        );
        _onTabChanged(_showDrafts);
      }
    } else if (option == 'pin') {
      try {
        final dio = ApiClient().dio;
        final response = await dio.put(
          '/api/v1/posts/${post.id}',
          data: {'is_pinned': !post.isPinned},
        );
        if (response.statusCode == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                post.isPinned
                    ? 'पोस्ट को अनपिन कर दिया गया है।'
                    : 'पोस्ट को पिन कर दिया गया है।',
              ),
              backgroundColor: ThemeConfig.success,
            ),
          );
          _onTabChanged(_showDrafts);
        }
      } catch (e) {
        print('Error toggling pin status: $e');
      }
    } else if (option == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostScreen(postToEdit: post),
        ),
      );
    }
  }

  void _toggleLike(int postId) async {
    try {
      final dio = ApiClient().dio;
      final response = await dio.post('/api/v1/posts/$postId/like');
      if (response.statusCode == 200 && mounted) {
        _onTabChanged(_showDrafts);
      }
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  void _sharePost(int postId) {
    final link = 'maruprajapat://posts/$postId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('शेयर लिंक कॉपी कर लिया गया है! इसे शेयर करें।'),
        backgroundColor: ThemeConfig.success,
      ),
    );
  }

  void _showCommentsSheet(PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CommentsSheetContent(
            post: post,
            onCommentAdded: () => _onTabChanged(_showDrafts),
          ),
        );
      },
    );
  }
}

// Comments sheet dialog view
class CommentsSheetContent extends StatefulWidget {
  final PostModel post;
  final VoidCallback onCommentAdded;
  const CommentsSheetContent({
    super.key,
    required this.post,
    required this.onCommentAdded,
  });

  @override
  State<CommentsSheetContent> createState() => _CommentsSheetContentState();
}

class _CommentsSheetContentState extends State<CommentsSheetContent> {
  final List<dynamic> _comments = [];
  bool _isLoading = false;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    try {
      final dio = ApiClient().dio;
      final response = await dio.get(
        '/api/v1/posts/${widget.post.id}/comments?page=1&per_page=100',
      );
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _comments.clear();
          _comments.addAll(response.data['items'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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
        '/api/v1/posts/${widget.post.id}/comments',
        data: {'content': text},
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        _fetchComments();
        widget.onCommentAdded();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('टिप्पणी जोड़ने में त्रुटि'),
          backgroundColor: ThemeConfig.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasHitLimit = _comments.length >= 100;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'टिप्पणियाँ (${_comments.length}/100)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),

          if (_isLoading)
            const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: ThemeConfig.primary),
              ),
            )
          else if (_comments.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: Text('कोई टिप्पणी नहीं है। पहली टिप्पणी लिखें!'),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final item = _comments[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item['author_name'] ?? 'अज्ञात',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      item['content'] ?? '',
                      style: const TextStyle(
                        color: ThemeConfig.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),

          const Divider(),
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
                textAlign: TextAlign.center,
              ),
            ),

          // Comment input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  enabled: !hasHitLimit,
                  decoration: InputDecoration(
                    hintText: hasHitLimit
                        ? 'सीमा समाप्त'
                        : 'अपनी टिप्पणी लिखें...',
                    hintStyle: const TextStyle(color: ThemeConfig.textHint),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: ThemeConfig.primary),
                onPressed: hasHitLimit ? null : _submitComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
