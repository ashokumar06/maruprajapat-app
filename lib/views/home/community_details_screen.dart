import 'package:flutter/material.dart';
import 'event_list_widget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/news_provider.dart';
import '../news/news_screen.dart';
import '../widgets/inline_youtube_player.dart';
import '../widgets/poll_view.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../models/post_model.dart';
import '../news/create_post_screen.dart';
import '../widgets/post_content_view.dart';
import 'community_members_screen.dart';

class CommunityDetailsScreen extends StatefulWidget {
  final int communityId;
  const CommunityDetailsScreen({super.key, required this.communityId});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic _community;
  List<PostModel> _posts = [];
  
  bool _isLoadingDetails = true;
  bool _isLoadingPosts = false;
  bool _isJoining = false;

  Future<void> _loadCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('cached_community_posts_${widget.communityId}');
      if (jsonStr != null && mounted) {
        final List decoded = json.decode(jsonStr);
        setState(() {
          _posts = decoded.map((e) => PostModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading cached community posts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Posts, Events, Gallery, Documents
    _fetchDetails();
    _loadCachedPosts().then((_) => _fetchPosts());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final response = await ApiClient().dio.get('/api/v1/communities/${widget.communityId}');
      if (response.data != null) {
        setState(() {
          _community = response.data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching community details: $e");
    } finally {
      setState(() => _isLoadingDetails = false);
    }
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final response = await ApiClient().dio.get('/api/v1/communities/${widget.communityId}/posts');
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _posts = (response.data['items'] as List)
              .map((e) => PostModel.fromJson(e))
              .toList();
        });
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final jsonStr = json.encode(_posts.map((p) => p.toJson()).toList());
          await prefs.setString('cached_community_posts_${widget.communityId}', jsonStr);
        } catch (e) {
          debugPrint('Error caching community posts: $e');
        }
      }
    } catch (e) {
      debugPrint("Error fetching community posts: $e");
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _joinCommunity() async {
    setState(() => _isJoining = true);
    try {
      final response = await ApiClient().dio.post('/api/v1/communities/${widget.communityId}/join');
      if (response.data != null && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'en'
              ? 'Successfully joined community!'
              : 'समुदाय सफलतापूर्वक जॉइन किया गया!')),
        );
        _fetchDetails();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (_isLoadingDetails && _community == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_community == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(isEnglish ? 'Failed to load details' : 'विवरण लोड करने में विफल')),
      );
    }

    final int membersCount = _community['members_count'] ?? 0;
    final int postsCount = _community['posts_count'] ?? 0;
    final String? roleInCommunity = _community['role_in_community'] as String?;
    final String roleStr = (roleInCommunity ?? '').toLowerCase();
    final isApproved = _community['is_approved'] as bool;
    final isMember = roleInCommunity != null && roleStr != 'pending';
    final isPending = roleStr == 'pending';
    final isCommunityAdmin = roleStr == 'admin' || roleStr == 'manager';

    // Calculate years old
    int yearsOld = 1;
    try {
      final created = DateTime.parse(_community['created_at']);
      final diff = DateTime.now().difference(created).inDays;
      yearsOld = (diff / 365).ceil();
      if (yearsOld < 1) yearsOld = 1;
    } catch (e) {
      // fallback
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _community['name'] ?? '',
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (roleInCommunity != null)
            _buildRoleBadge(roleInCommunity, isEnglish),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchDetails();
          await _fetchPosts();
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          (_community['logo_url'] != null &&
                                  _community['logo_url'].toString().isNotEmpty)
                              ? CircleAvatar(
                                  radius: 36,
                                  backgroundImage: NetworkImage(_community['logo_url']),
                                )
                              : _buildCategoryIcon(_community['category'] ?? ''),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _community['name'] ?? '',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _community['category'] ?? '',
                                  style: const TextStyle(fontSize: 13, color: ThemeConfig.primary, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _community['description'] ?? '',
                                  style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Stats Grid (3 columns or 4 columns)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ThemeConfig.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeConfig.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('$membersCount', isEnglish ? 'Members' : 'सदस्य'),
                            _buildStatItem('$postsCount', isEnglish ? 'Posts' : 'पोस्ट'),
                            _buildStatItem('$yearsOld ${isEnglish ? 'Yrs' : 'साल'}', isEnglish ? 'Old' : 'पुराना'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons Grid (Visible to members only, or Join button if guest)
                      if (!isMember)
                        ElevatedButton(
                          onPressed: _isJoining || !isApproved || isPending ? null : _joinCommunity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.primary,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isJoining
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  isPending
                                      ? (isEnglish ? 'Awaiting Member Approval' : 'सदस्यता स्वीकृति का इंतजार है')
                                      : (isApproved 
                                          ? (isEnglish ? 'Join Community' : 'समुदाय जॉइन करें')
                                          : (isEnglish ? 'Awaiting Approval' : 'स्वीकृति का इंतजार है')),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        )
                      else
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                          children: [
                            _buildActionItem(
                              Icons.person_add_outlined,
                              isCommunityAdmin
                                  ? (isEnglish ? 'Members/Reqs' : 'सदस्य/अनुरोध')
                                  : (isEnglish ? 'Add Member' : 'सदस्य जोड़ें'),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityMembersScreen(
                                      communityId: widget.communityId,
                                      isSelectionMode: true,
                                      isCommunityAdmin: isCommunityAdmin,
                                    ),
                                  ),
                                ).then((_) => _fetchDetails());
                              },
                            ),
                            _buildActionItem(
                              Icons.edit_note_outlined,
                              isEnglish ? 'Post' : 'पोस्ट करें',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreatePostScreen(
                                      communityId: widget.communityId,
                                    ),
                                  ),
                                ).then((_) {
                                  _fetchDetails();
                                  _fetchPosts();
                                });
                              },
                            ),
                            _buildActionItem(
                              Icons.calendar_today_outlined,
                              isEnglish ? 'Event' : 'कार्यक्रम बनाएं',
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('कार्यक्रम बनाएं सुविधा जल्द ही उपलब्ध होगी।')),
                                );
                              },
                            ),
                            _buildActionItem(
                              Icons.settings_outlined,
                              isEnglish ? 'Settings' : 'सेटिंग्स',
                              () {
                                if (isCommunityAdmin) {
                                  _showCommunitySettingsBottomSheet(isEnglish);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEnglish
                                            ? 'Only admins can access settings.'
                                            : 'केवल एडमिन ही सेटिंग्स देख सकते हैं।',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: const Divider(height: 1, color: ThemeConfig.border),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: ThemeConfig.primary,
                    unselectedLabelColor: ThemeConfig.textSecondary,
                    indicatorColor: ThemeConfig.primary,
                    indicatorWeight: 2.5,
                    tabs: [
                      Tab(text: isEnglish ? 'All Posts' : 'सभी पोस्ट'),
                      Tab(text: isEnglish ? 'Events' : 'कार्यक्रम'),
                      Tab(text: isEnglish ? 'Gallery' : 'गैलरी'),
                      Tab(text: isEnglish ? 'Documents' : 'दस्तावेज'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsList(isEnglish),
              EventListWidget(
                communityId: widget.communityId,
                canCreate: roleStr == 'admin' || roleStr == 'manager' || roleStr == 'member',
              ),
              _buildMockTab('', true, isEnglish),
              _buildMockTab('', true, isEnglish),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: ThemeConfig.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeConfig.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ThemeConfig.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(bool isEnglish) {
    if (_isLoadingPosts && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_posts.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: 300,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              isEnglish ? 'No posts inside this community yet.' : 'इस समुदाय में अभी कोई पोस्ट नहीं है।',
              style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostCard(post, isEnglish);
      },
    );
  }

  Widget _buildPostCard(PostModel post, bool isEnglish) {
    final currentUserId = context.read<AuthProvider>().currentUserModel?.id;
    final isAuthor = post.authorId == currentUserId;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: ThemeConfig.divider,
            width: 0.8,
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName ?? 'अज्ञात',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.communityName != null && post.communityName!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: ThemeConfig.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.communityName!,
                                style: const TextStyle(
                                  color: ThemeConfig.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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
            if (post.textContent != null && post.textContent!.isNotEmpty) ...[
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

            if (post.postType == 'poll') ...[
              PollView(post: post),
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
                  isEnglish 
                      ? '${post.commentsCount} comments'
                      : '${post.commentsCount} टिप्पणियाँ',
                  style: const TextStyle(
                    color: ThemeConfig.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: ThemeConfig.border),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Like Button
                TextButton.icon(
                  onPressed: () => _toggleLike(post.id),
                  icon: Icon(
                    post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: post.isLiked ? ThemeConfig.primary : ThemeConfig.textSecondary,
                    size: 18,
                  ),
                  label: Text(
                    isEnglish ? 'Like' : 'लाइक',
                    style: TextStyle(
                      color: post.isLiked ? ThemeConfig.primary : ThemeConfig.textSecondary,
                      fontSize: 11,
                      fontWeight: post.isLiked ? FontWeight.bold : FontWeight.normal,
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
                  label: Text(
                    isEnglish ? 'Comment' : 'टिप्पणी',
                    style: const TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 11,
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
                  label: Text(
                    isEnglish ? 'Share' : 'शेयर',
                    style: const TextStyle(
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

  void _toggleLike(int postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final originalIsLiked = post.isLiked;
    final originalLikesCount = post.likesCount;

    // Optimistically update the UI state immediately
    setState(() {
      post.isLiked = !post.isLiked;
      post.likesCount += post.isLiked ? 1 : -1;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_posts.map((p) => p.toJson()).toList());
      await prefs.setString('cached_community_posts_${widget.communityId}', jsonStr);
    } catch (e) {
      debugPrint('Error updating cached community posts: $e');
    }

    try {
      final dio = ApiClient().dio;
      final response = await dio.post('/api/v1/posts/$postId/like');
      if (response.statusCode == 200 && response.data != null) {
        final newLikesCount = int.tryParse(response.data['likes_count'].toString()) ?? post.likesCount;
        final String action = response.data['action'] ?? '';
        setState(() {
          post.likesCount = newLikesCount;
          post.isLiked = (action == 'liked');
        });
        
        try {
          final prefs = await SharedPreferences.getInstance();
          final jsonStr = json.encode(_posts.map((p) => p.toJson()).toList());
          await prefs.setString('cached_community_posts_${widget.communityId}', jsonStr);
        } catch (e) {
          debugPrint('Error updating cached community posts: $e');
        }
      } else {
        // Rollback
        setState(() {
          post.isLiked = originalIsLiked;
          post.likesCount = originalLikesCount;
        });
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
      // Rollback
      setState(() {
        post.isLiked = originalIsLiked;
        post.likesCount = originalLikesCount;
      });
    }
  }

  void _sharePost(int postId) {
    final link = 'maruprajapat://posts/$postId';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Localizations.localeOf(context).languageCode == 'en'
            ? 'Share link copied to clipboard!'
            : 'शेयर link कॉपी कर लिया गया है! इसे शेयर करें।'),
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
            onCommentAdded: () => _fetchPosts(),
          ),
        );
      },
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
        _fetchPosts();
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
        _fetchPosts();
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
          _fetchPosts();
        }
      } catch (e) {
        debugPrint('Error toggling pin status: $e');
      }
    } else if (option == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePostScreen(postToEdit: post),
        ),
      ).then((_) => _fetchPosts());
    }
  }

  Widget _buildMockTab(String msg, bool isComingSoon, bool isEnglish) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isComingSoon ? Icons.hourglass_empty_rounded : Icons.info_outline,
              size: 40,
              color: ThemeConfig.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              isComingSoon
                  ? (isEnglish ? 'Coming Soon' : 'जल्द आ रहा है')
                  : msg,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ThemeConfig.textPrimary),
            ),
            if (isComingSoon) ...[
              const SizedBox(height: 6),
              Text(
                isEnglish
                    ? 'Contact Developer to activate this section.'
                    : 'इस अनुभाग को सक्रिय करने के लिए डेवलपर से संपर्क करें।',
                style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    Color bgColor = Colors.grey[200]!;
    IconData iconData = Icons.groups;
    Color iconColor = Colors.grey[700]!;

    final cat = category.trim();
    if (cat.contains('शिक्षा • सेवा')) {
      bgColor = const Color(0xFFE3ECEF);
      iconData = Icons.apartment;
      iconColor = const Color(0xFF5A7B8C);
    } else if (cat.contains('सेवा • सहयोग')) {
      bgColor = const Color(0xFFFFF2E6);
      iconData = Icons.handshake_outlined;
      iconColor = const Color(0xFFE28B43);
    } else if (cat.contains('शिक्षा • मार्गदर्शन')) {
      bgColor = const Color(0xFFECEFF1);
      iconData = Icons.school_outlined;
      iconColor = const Color(0xFF37474F);
    } else if (cat.contains('सेवा • स्वास्थ्य')) {
      bgColor = const Color(0xFFFFEBEE);
      iconData = Icons.local_hospital_outlined;
      iconColor = const Color(0xFFD32F2F);
    } else if (cat.contains('युवा • विकास')) {
      bgColor = const Color(0xFFE8F5E9);
      iconData = Icons.trending_up;
      iconColor = const Color(0xFF2E7D32);
    } else if (cat.contains('महिला • उत्थान')) {
      bgColor = const Color(0xFFF3E5F5);
      iconData = Icons.face_3_outlined;
      iconColor = const Color(0xFF7B1FA2);
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role, bool isEnglish) {
    String label = isEnglish ? 'Member' : 'सदस्य';
    Color color = Colors.grey;
    if (role == 'admin') {
      label = isEnglish ? 'Admin' : 'एडमिन';
      color = Colors.orange;
    } else if (role == 'manager') {
      label = isEnglish ? 'Manager' : 'मैनेजर';
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCommunitySettingsBottomSheet(bool isEnglish) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isEnglish ? 'Community Settings' : 'समुदाय सेटिंग्स',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: ThemeConfig.primary),
                title: Text(isEnglish ? 'Edit Community Details' : 'समुदाय विवरण संपादित करें'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCommunityDialog(isEnglish);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline, color: ThemeConfig.primary),
                title: Text(isEnglish ? 'Manage Members' : 'सदस्य प्रबंधन'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityMembersScreen(
                        communityId: widget.communityId,
                        isSelectionMode: true,
                        isCommunityAdmin: true,
                      ),
                    ),
                  ).then((_) => _fetchDetails());
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showEditCommunityDialog(bool isEnglish) {
    final nameController = TextEditingController(text: _community['name']);
    final descController = TextEditingController(text: _community['description']);
    final locController = TextEditingController(text: _community['location']);
    String selectedCategory = _community['category'] ?? 'शिक्षा • सेवा';

    final categories = [
      'शिक्षा • सेवा',
      'सेवा • सहयोग',
      'शिक्षा • मार्गदर्शन',
      'सेवा • स्वास्थ्य',
      'युवा • विकास',
      'महिला • उत्थान'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEnglish ? 'Edit Community' : 'समुदाय संपादित करें',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: isEnglish ? 'Community Name' : 'समुदाय का नाम',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: categories.contains(selectedCategory) ? selectedCategory : categories[0],
                      decoration: InputDecoration(
                        labelText: isEnglish ? 'Category' : 'श्रेणी',
                        border: const OutlineInputBorder(),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: isEnglish ? 'Description' : 'विवरण',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: locController,
                      decoration: InputDecoration(
                        labelText: isEnglish ? 'Location' : 'स्थान (Location)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isEnglish ? 'Cancel' : 'रद्द करें'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEnglish ? 'Fields cannot be empty' : 'विवरण खाली नहीं हो सकते'),
                          backgroundColor: ThemeConfig.error,
                        ),
                      );
                      return;
                    }
                    try {
                      final response = await ApiClient().dio.put(
                        '/api/v1/communities/${widget.communityId}',
                        data: {
                          'name': nameController.text.trim(),
                          'category': selectedCategory,
                          'description': descController.text.trim(),
                          'location': locController.text.trim(),
                        },
                      );
                      if (response.statusCode == 200) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEnglish ? 'Community updated successfully!' : 'समुदाय विवरण सफलतापूर्वक अपडेट किया गया!'),
                              backgroundColor: ThemeConfig.success,
                            ),
                          );
                          Navigator.pop(context);
                          _fetchDetails();
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: ThemeConfig.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    isEnglish ? 'Save' : 'सहेजें',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
