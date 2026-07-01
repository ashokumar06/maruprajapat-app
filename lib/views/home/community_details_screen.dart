import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Posts, Events, Gallery, Documents
    _fetchDetails();
    _fetchPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final response = await ApiClient().dio.get('/communities/${widget.communityId}');
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
      final response = await ApiClient().dio.get('/communities/${widget.communityId}/posts');
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _posts = (response.data['items'] as List)
              .map((e) => PostModel.fromJson(e))
              .toList();
        });
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
      final response = await ApiClient().dio.post('/communities/${widget.communityId}/join');
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
    final role = _community['role_in_community'] as String?;
    final isApproved = _community['is_approved'] as bool;
    final isMember = role != null;

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
          if (role != null)
            _buildRoleBadge(role, isEnglish),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _fetchDetails();
                await _fetchPosts();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Header Card matching Screen 4
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: ThemeConfig.primaryLight,
                              backgroundImage: (_community['logo_url'] != null &&
                                      _community['logo_url'].toString().isNotEmpty)
                                  ? NetworkImage(_community['logo_url'])
                                  : null,
                              child: (_community['logo_url'] == null ||
                                      _community['logo_url'].toString().isEmpty)
                                  ? const Icon(Icons.group_work, color: ThemeConfig.primary, size: 36)
                                  : null,
                            ),
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
                              _buildStatItem('12', isEnglish ? 'Events' : 'कार्यक्रम'),
                              _buildStatItem('$yearsOld ${isEnglish ? 'Yrs' : 'साल'}', isEnglish ? 'Old' : 'पुराना'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons Grid (Visible to members only, or Join button if guest)
                        if (!isMember)
                          ElevatedButton(
                            onPressed: _isJoining || !isApproved ? null : _joinCommunity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConfig.primary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isJoining
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    isApproved 
                                        ? (isEnglish ? 'Join Community' : 'समुदाय जॉइन करें')
                                        : (isEnglish ? 'Awaiting Approval' : 'स्वीकृति का इंतजार है'),
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
                                isEnglish ? 'Add Member' : 'सदस्य जोड़ें',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommunityMembersScreen(
                                        communityId: widget.communityId,
                                        isSelectionMode: true,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('सेटिंग्स सुविधा जल्द ही उपलब्ध होगी।')),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Divider
                  const Divider(height: 1, color: ThemeConfig.border),

                  // Tab Bar (All Posts, Events, Gallery, Documents)
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

                  // Content view dynamically loaded
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsList(isEnglish),
                        _buildMockTab(isEnglish ? 'No events yet.' : 'कोई कार्यक्रम नहीं है।'),
                        _buildMockTab(isEnglish ? 'No media files.' : 'कोई गैलरी फ़ाइल नहीं है।'),
                        _buildMockTab(isEnglish ? 'No documents.' : 'कोई दस्तावेज नहीं है।'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            isEnglish ? 'No posts inside this community yet.' : 'इस समुदाय में अभी कोई पोस्ट नहीं है।',
            style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostCard(post, isEnglish);
      },
    );
  }

  Widget _buildPostCard(PostModel post, bool isEnglish) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeConfig.border, width: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ThemeConfig.border,
                backgroundImage: post.authorPhoto != null ? NetworkImage(post.authorPhoto!) : null,
                child: post.authorPhoto == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName ?? (isEnglish ? 'Unknown' : 'अज्ञात'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeConfig.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnglish ? '2 hours ago' : '2 घंटे पहले',
                      style: const TextStyle(color: ThemeConfig.textHint, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (post.textContent != null && post.textContent!.isNotEmpty)
            PostContentView(
              text: post.textContent!,
              style: const TextStyle(fontSize: 13, color: ThemeConfig.textPrimary, height: 1.45),
            ),
          if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(post.mediaUrl!, fit: BoxFit.cover, width: double.infinity, height: 180),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMockTab(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
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
}
