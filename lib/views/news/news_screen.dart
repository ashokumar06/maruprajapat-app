import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/news_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/post_model.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().fetchNewsFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('न्यूज़ / ट्रेंडिंग', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading && newsProvider.trendingPosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsProvider.error != null && newsProvider.trendingPosts.isEmpty) {
            return Center(child: Text('Error: ${newsProvider.error}'));
          }

          if (newsProvider.trendingPosts.isEmpty) {
            return const Center(child: Text('कोई समाचार नहीं मिला'));
          }

          return RefreshIndicator(
            onRefresh: () => newsProvider.fetchNewsFeed(),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: newsProvider.trendingPosts.length,
              itemBuilder: (context, index) {
                final post = newsProvider.trendingPosts[index];
                return _buildPostCard(post, index);
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final role = authProvider.currentUserModel?.role;
          if (role == 'member' || role == 'admin' || role == 'superadmin') {
            return FloatingActionButton.extended(
              onPressed: () {
                _showCreatePostSheet(context);
              },
              backgroundColor: ThemeConfig.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('पोस्ट करें', style: TextStyle(color: Colors.white)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const CreatePostForm(),
        );
      },
    );
  }

  Widget _buildPostCard(PostModel post, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: ThemeConfig.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: index < 3 ? ThemeConfig.error.withOpacity(0.5) : ThemeConfig.divider, width: index < 3 ? 1.5 : 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index < 3) ...[
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: ThemeConfig.error, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'ट्रेंडिंग #${index + 1}',
                    style: const TextStyle(color: ThemeConfig.error, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ThemeConfig.border,
                  backgroundImage: post.authorPhoto != null ? NetworkImage(post.authorPhoto!) : null,
                  child: post.authorPhoto == null ? const Icon(Icons.person, color: Colors.white) : null,
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ThemeConfig.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'सदस्य',
                              style: TextStyle(color: ThemeConfig.success, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'हाल ही में',
                        style: TextStyle(color: ThemeConfig.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: ThemeConfig.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.textContent ?? '',
              style: const TextStyle(fontSize: 15, color: ThemeConfig.textPrimary),
            ),
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(post.mediaUrl!, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: ThemeConfig.divider),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: ThemeConfig.error, size: 20),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}', style: const TextStyle(color: ThemeConfig.textSecondary)),
                  ],
                ),
                Text('${post.commentsCount} टिप्पणियाँ', style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, color: ThemeConfig.textSecondary),
                  label: const Text('लाइक', style: TextStyle(color: ThemeConfig.textSecondary)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, color: ThemeConfig.textSecondary),
                  label: const Text('टिप्पणी', style: TextStyle(color: ThemeConfig.textSecondary)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, color: ThemeConfig.textSecondary),
                  label: const Text('शेयर', style: TextStyle(color: ThemeConfig.textSecondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostForm extends StatefulWidget {
  const CreatePostForm({super.key});

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _textController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    
    try {
      final success = await context.read<NewsProvider>().createPost(text);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('पोस्ट सफलतापूर्वक बना दी गई है')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('पोस्ट बनाने में विफल रहा')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('नई पोस्ट बनाएं', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'आपके मन में क्या है?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('पोस्ट करें', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
