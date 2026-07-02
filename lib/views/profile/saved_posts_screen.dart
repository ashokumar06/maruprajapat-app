import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_provider.dart';
import '../../config/theme_config.dart';
import '../news/post_detail_screen.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadSavedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('सेव की गई पोस्ट', style: TextStyle(color: ThemeConfig.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final posts = newsProvider.savedPosts;
          if (posts.isEmpty) {
            return const Center(child: Text('कोई सेव की गई पोस्ट नहीं है', style: TextStyle(color: ThemeConfig.textSecondary)));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(post.textContent ?? 'पोस्ट'),
                subtitle: Text(post.authorName ?? 'अज्ञात'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: ThemeConfig.error),
                  onPressed: () => newsProvider.toggleSavePost(post),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
