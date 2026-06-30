import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';
import '../../models/user_model.dart';

class AllPeopleScreen extends StatefulWidget {
  const AllPeopleScreen({super.key});

  @override
  State<AllPeopleScreen> createState() => _AllPeopleScreenState();
}

class _AllPeopleScreenState extends State<AllPeopleScreen> {
  final List<UserModel> _people = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPeople();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!_isLoading && _hasMore) {
          _fetchPeople();
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

  Future<void> _fetchPeople({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _people.clear();
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      final client = ApiClient().dio;
      final response = await client.get(
        '/api/v1/users/',
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
            _people.addAll(items.map((e) => UserModel.fromJson(e, e['firebase_uid'] ?? e['id']?.toString() ?? '')).toList());
            _page++;
            _hasMore = _page <= totalPages;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('उपयोगकर्ता सूची लोड करने में विफल'),
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
    _fetchPeople(refresh: true);
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
      case 'superadmin':
        return 'व्यवस्थापक';
      case 'member':
        return 'सदस्य';
      case 'guest':
      default:
        return 'अतिथि (Guest)';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
      case 'superadmin':
        return ThemeConfig.primary;
      case 'member':
        return ThemeConfig.success;
      case 'guest':
      default:
        return ThemeConfig.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('सभी प्रोफाइल (All Profiles)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
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
                hintText: 'नाम या ईमेल खोजें...',
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

          // People List
          Expanded(
            child: _people.isEmpty && !_isLoading
                ? const Center(child: Text('कोई प्रोफाइल नहीं मिली।', style: TextStyle(color: ThemeConfig.textSecondary)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _people.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _people.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator(color: ThemeConfig.primary)),
                        );
                      }

                      final person = _people[index];
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
                                backgroundImage: person.profilePhotoUrl.isNotEmpty
                                    ? NetworkImage(person.profilePhotoUrl)
                                    : null,
                                child: person.profilePhotoUrl.isEmpty
                                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          person.fullName.isNotEmpty ? person.fullName : 'अनाम',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: ThemeConfig.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getRoleColor(person.role).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getRoleLabel(person.role),
                                            style: TextStyle(color: _getRoleColor(person.role), fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'गोत्र: ${person.gotra.isNotEmpty ? person.gotra : 'अप्राप्य'}',
                                      style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'स्थान: ${person.village.isNotEmpty ? person.village : 'अप्राप्य'}, ${person.district.isNotEmpty ? person.district : 'अप्राप्य'}',
                                      style: const TextStyle(fontSize: 12, color: ThemeConfig.textHint),
                                    ),
                                  ],
                                ),
                              ),

                              // Phone Action
                              if (person.contactNumber.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.phone, color: ThemeConfig.success),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('संपर्क नंबर: ${person.contactNumber}'),
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
