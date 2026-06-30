import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme_config.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_model.dart';
import '../widgets/inline_youtube_player.dart';
import '../widgets/post_content_view.dart';
import '../widgets/poll_view.dart';
import '../profile/profile_screen.dart';
import '../explore/explore_screen.dart';
import 'members_list_screen.dart';
import 'community_screen.dart';
import 'events_screen.dart';
import 'complaints_screen.dart';
import 'notices_screen.dart';
import 'market_screen.dart';
import 'schemes_screen.dart';
import 'admin_approvals_screen.dart';
import 'all_people_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      body: SafeArea(
        child: Consumer2<HomeProvider, AuthProvider>(
          builder: (context, homeProvider, authProvider, child) {
            if (homeProvider.isLoading &&
                homeProvider.notices.isEmpty &&
                homeProvider.posts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authProvider.currentUserModel;
            final displayText = (user != null && user.fullName.isNotEmpty)
                ? user.fullName
                : 'श्री मारू प्रजापत समाज';

            return RefreshIndicator(
              onRefresh: () => context.read<HomeProvider>().fetchHomeData(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1. Top Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(
                                  'assets/images/logo.png',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                displayText,
                                style: const TextStyle(
                                  color: ThemeConfig.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isSearching ? Icons.close : Icons.search,
                                  color: ThemeConfig.textPrimary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isSearching = !_isSearching;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Badge(
                                  backgroundColor: ThemeConfig.error,
                                  label: Text('3'),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: ThemeConfig.textPrimary,
                                  ),
                                ),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: ThemeConfig.primaryLight,
                                  backgroundImage:
                                      (user?.profilePhotoUrl != null &&
                                          user!.profilePhotoUrl.isNotEmpty)
                                      ? NetworkImage(user.profilePhotoUrl)
                                      : null,
                                  child:
                                      (user?.profilePhotoUrl == null ||
                                          user!.profilePhotoUrl.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          color: ThemeConfig.primary,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Search Bar & Filter Row (Mockup Style)
                  if (_isSearching)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: ThemeConfig.border),
                                ),
                                child: TextField(
                                  onSubmitted: (val) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MembersListScreen(),
                                      ),
                                    );
                                  },
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'खोजें...',
                                    hintStyle: TextStyle(
                                      color: ThemeConfig.textHint,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: ThemeConfig.textHint,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: ThemeConfig.border),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: ThemeConfig.primary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. Important Notices (महत्वपूर्ण सूचना)
                  if (homeProvider.notices.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionHeader(
                        'महत्वपूर्ण सूचना',
                        'सभी देखें >',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: homeProvider.notices.length,
                          itemBuilder: (context, index) {
                            final notice = homeProvider.notices[index];
                            // Map category to icon and color
                            IconData icon = Icons.description;
                            Color color = Colors.blue;
                            if (notice.category == 'scholarship') {
                              icon = Icons.school;
                              color = ThemeConfig.primary;
                            } else if (notice.category == 'blood_request') {
                              icon = Icons.bloodtype;
                              color = ThemeConfig.error;
                            } else if (notice.category == 'meeting') {
                              icon = Icons.groups;
                              color = ThemeConfig.success;
                            }
                            return _buildNoticeCard(
                              notice.title,
                              notice.content,
                              icon,
                              color,
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // 4. Banner Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/banner.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. Quick Actions (त्वरित कार्य)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('त्वरित कार्य', 'सभी देखें >'),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.count(
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildActionIcon(Icons.people, 'सदस्य सूची', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MembersListScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.account_balance, 'समाज', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CommunityScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.event, 'कार्यक्रम', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EventsScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.storefront, 'व्यवसाय', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExploreScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.report_problem, 'शिकायत', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ComplaintsScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.campaign, 'नोटिस', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NoticesScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.shopping_bag, 'बाजार', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MarketScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.school, 'योजनाएं', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SchemesScreen(),
                              ),
                            );
                          }),
                          _buildActionIcon(Icons.more_horiz, 'और सेवांए', () {
                            _showMoreServicesSheet(context, user);
                          }),
                        ],
                      ),
                    ),
                  ),

                  // 6. Community Updates (समाज अपडेट)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'समाज अपडेट',
                      'सभी पोस्ट देखें >',
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = homeProvider.posts[index];
                      return _buildPostCard(post);
                    }, childCount: homeProvider.posts.length),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ), // Bottom padding
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.textPrimary,
            ),
          ),
          Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeConfig.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: ThemeConfig.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeConfig.textSecondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '15 जून 2026 | 11:00 AM',
                style: TextStyle(fontSize: 10, color: ThemeConfig.textHint),
              ),
              Icon(Icons.chevron_right, color: color, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ThemeConfig.primary, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ThemeConfig.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showMoreServicesSheet(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isAdmin = user?.role == 'admin' || user?.role == 'superadmin';
        final isMemberOrAdmin = user?.role == 'member' || isAdmin;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'और सेवाएं (More Services)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeConfig.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: ThemeConfig.divider),
              const SizedBox(height: 8),

              // Standard Services
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMoreServiceItem(context, Icons.favorite, 'विवाह', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('वैवाहिक सेवा जल्द ही उपलब्ध होगी।'),
                      ),
                    );
                  }),
                  _buildMoreServiceItem(
                    context,
                    Icons.bloodtype,
                    'रक्त दान',
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('रक्तदान सेवा जल्द ही उपलब्ध होगी।'),
                        ),
                      );
                    },
                  ),
                  _buildMoreServiceItem(
                    context,
                    Icons.account_balance_outlined,
                    'मन्दिर/मठ',
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('मन्दिर सूची जल्द ही उपलब्ध होगी।'),
                        ),
                      );
                    },
                  ),
                  _buildMoreServiceItem(context, Icons.work, 'नौकरियाँ', () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('रोजगार सूचनाएं जल्द ही उपलब्ध होंगी।'),
                      ),
                    );
                  }),
                ],
              ),

              if (isAdmin) ...[
                const SizedBox(height: 24),
                const Divider(color: ThemeConfig.divider),
                const SizedBox(height: 12),
                const Text(
                  'प्रशासनिक कार्य (Admin Controls)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'सदस्यता अनुमोदन',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminApprovalsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (isMemberOrAdmin) ...[
                const SizedBox(height: 24),
                const Divider(color: ThemeConfig.divider),
                const SizedBox(height: 12),
                const Text(
                  'विशेष सेवाएं (Special Directory)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.people_outline,
                          color: ThemeConfig.primary,
                        ),
                        label: const Text(
                          'सभी प्रोफाइल (All Profiles)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllPeopleScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeConfig.primary,
                          side: const BorderSide(color: ThemeConfig.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreServiceItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ThemeConfig.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: ThemeConfig.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
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
      padding: const EdgeInsets.all(16.0),
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
                          Text(
                            post.authorName ?? 'अज्ञात',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeConfig.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'सदस्य',
                              style: TextStyle(
                                color: ThemeConfig.success,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '2 घंटे पहले',
                        style: TextStyle(
                          color: ThemeConfig.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: ThemeConfig.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              PollView(post: post),
            ],
            if (post.youtubeUrl != null && post.youtubeUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InlineYoutubePlayer(videoUrl: post.youtubeUrl!),
            ],
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
              ),
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
            const SizedBox(height: 16),
            const SizedBox(height: 12),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {},
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
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: ThemeConfig.textSecondary,
                    size: 18,
                  ),
                  label: const Text(
                    'टिप्पणी',
                    style: TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
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
}
