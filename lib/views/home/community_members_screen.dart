import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';

class CommunityMembersScreen extends StatefulWidget {
  final int communityId;
  final bool isSelectionMode; // if true, can add members

  const CommunityMembersScreen({
    super.key,
    required this.communityId,
    this.isSelectionMode = false,
  });

  @override
  State<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _members = [];
  bool _isLoadingMembers = true;
  
  // Invite dialog states
  List<dynamic> _allUsers = [];
  bool _isLoadingUsers = false;
  String _userSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final response = await ApiClient().dio.get('/communities/${widget.communityId}/members');
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _members = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching community members: $e");
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoadingUsers = true;
      _userSearchQuery = query;
    });
    try {
      final response = await ApiClient().dio.get(
        '/api/v1/users/',
        queryParameters: {
          if (query.isNotEmpty) 'query': query,
        },
      );
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _allUsers = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error searching users: $e");
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _addMemberToCommunity(int userId) async {
    try {
      final response = await ApiClient().dio.post(
        '/communities/${widget.communityId}/members',
        data: {'user_id': userId, 'role': 'member'},
      );
      if (response.data != null && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(Localizations.localeOf(context).languageCode == 'en'
                ? 'Member added successfully!'
                : 'सदस्य को सफलतापूर्वक जोड़ा गया!'),
          ),
        );
        Navigator.pop(context); // Close dialog
        _fetchMembers(); // Refresh members list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showAddMemberDialog(bool isEnglish) {
    _searchUsers(""); // initial fetch of first few users
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEnglish ? 'Add Community Member' : 'सदस्य जोड़ें'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: isEnglish ? 'Search user...' : 'उपयोगकर्ता खोजें...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) {
                        _searchUsers(val).then((_) {
                          setDialogState(() {});
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _isLoadingUsers
                          ? const Center(child: CircularProgressIndicator())
                          : _allUsers.isEmpty
                              ? Center(
                                  child: Text(isEnglish ? 'No users found.' : 'कोई उपयोगकर्ता नहीं मिला।'),
                                )
                              : ListView.builder(
                                  itemCount: _allUsers.length,
                                  itemBuilder: (context, index) {
                                    final u = _allUsers[index];
                                    // Check if already a member
                                    final isAlreadyMember = _members.any((m) => m['user_id'] == u['id']);

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundImage: (u['profile_photo_url'] != null &&
                                                u['profile_photo_url'].toString().isNotEmpty)
                                            ? NetworkImage(u['profile_photo_url'])
                                            : null,
                                        child: (u['profile_photo_url'] == null ||
                                                u['profile_photo_url'].toString().isEmpty)
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      title: Text(u['full_name'] ?? ''),
                                      subtitle: Text(u['district'] ?? ''),
                                      trailing: isAlreadyMember
                                          ? Text(
                                              isEnglish ? 'Joined' : 'शामिल है',
                                              style: const TextStyle(color: ThemeConfig.textHint, fontSize: 12),
                                            )
                                          : ElevatedButton(
                                              onPressed: () => _addMemberToCommunity(u['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: ThemeConfig.primary,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                minimumSize: Size.zero,
                                              ),
                                              child: Text(
                                                isEnglish ? 'Add' : 'जोड़ें',
                                                style: const TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                            ),
                                    );
                                  },
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
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Members' : 'सदस्य सूची',
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingMembers
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Search & [+] button row matching Screen 5
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: isEnglish ? 'Search member...' : 'सदस्य खोजें...',
                            prefixIcon: const Icon(Icons.search, color: ThemeConfig.textHint),
                            filled: true,
                            fillColor: ThemeConfig.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (val) {
                            setState(() {});
                          },
                        ),
                      ),
                      if (widget.isSelectionMode) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _showAddMemberDialog(isEnglish),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ThemeConfig.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Members List
                Expanded(
                  child: _members.isEmpty
                      ? Center(child: Text(isEnglish ? 'No members found' : 'कोई सदस्य नहीं है।'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final m = _members[index];
                            final name = m['user_name'] ?? '';
                            // Filter by search controller
                            if (_searchController.text.isNotEmpty &&
                                !name.toLowerCase().contains(_searchController.text.toLowerCase())) {
                              return const SizedBox.shrink();
                            }

                            final role = m['role'] as String;

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: ThemeConfig.border),
                              ),
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: (m['user_photo'] != null &&
                                          m['user_photo'].toString().isNotEmpty)
                                      ? NetworkImage(m['user_photo'])
                                      : null,
                                  child: (m['user_photo'] == null ||
                                          m['user_photo'].toString().isEmpty)
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildRoleBadge(role, isEnglish),
                                  ],
                                ),
                                subtitle: Text(
                                  isEnglish ? 'Rajasthan' : 'राजस्थान',
                                  style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 4,
                                      backgroundColor: Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEnglish ? 'Online' : 'ऑनलाइन',
                                      style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
