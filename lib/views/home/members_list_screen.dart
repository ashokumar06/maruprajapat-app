import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({super.key});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  final List<UserModel> _members = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _fetchMembers();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _members.clear();
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      final client = ApiClient().dio;
      final response = await client.get(
        '/api/v1/users/public',
        queryParameters: {
          'page': _page,
          'per_page': 20,
          if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          final List items = data['items'] ?? [];
          final int totalPages = data['total_pages'] ?? 1;

          setState(() {
            _members.addAll(items.map((e) => UserModel.fromJson(e, e['firebase_uid'] ?? e['id']?.toString() ?? '')).toList());
            _page++;
            _hasMore = _page <= totalPages;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('सदस्य सूची लोड करने में विफल'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearch(String val) {
    setState(() {
      _searchQuery = val;
    });
    _fetchMembers(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().currentUserModel;
    final isVerifiedMember = currentUser != null &&
        (currentUser.role == 'member' ||
            currentUser.role == 'admin' ||
            currentUser.role == 'superadmin');

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('सदस्य सूची', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'सदस्य का नाम या गोत्र खोजें...',
                hintStyle: const TextStyle(color: ThemeConfig.textHint),
                prefixIcon: const Icon(Icons.search, color: ThemeConfig.textHint),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: ThemeConfig.textHint),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: ThemeConfig.border, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: ThemeConfig.border, width: 1),
                ),
              ),
            ),
          ),

          // Member List
          Expanded(
            child: _members.isEmpty && !_isLoading
                ? const Center(child: Text('कोई सदस्य नहीं मिला।', style: TextStyle(color: ThemeConfig.textSecondary)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _members.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _members.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator(color: ThemeConfig.primary)),
                        );
                      }

                      final member = _members[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: ThemeConfig.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: ThemeConfig.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: ThemeConfig.border,
                                backgroundImage: member.profilePhotoUrl.isNotEmpty
                                    ? NetworkImage(member.profilePhotoUrl)
                                    : null,
                                child: member.profilePhotoUrl.isEmpty
                                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.fullName.isNotEmpty ? member.fullName : 'अनाम',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeConfig.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'गोत्र: ${member.gotra.isNotEmpty ? member.gotra : 'अप्राप्य'}',
                                      style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'स्थान: ${member.village.isNotEmpty ? member.village : 'अप्राप्य'}, ${member.district.isNotEmpty ? member.district : 'अप्राप्य'}',
                                      style: const TextStyle(fontSize: 12, color: ThemeConfig.textHint),
                                    ),
                                  ],
                                ),
                              ),

                              // Action Call / Info (Only show if current user is a verified member)
                              if (isVerifiedMember && member.contactNumber.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.phone, color: ThemeConfig.success),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('संपर्क नंबर: ${member.contactNumber}'),
                                        action: SnackBarAction(
                                          label: 'कॉपी करें',
                                          textColor: Colors.white,
                                          onPressed: () {
                                            // Copy to clipboard
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
