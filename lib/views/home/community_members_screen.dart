import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';

class CommunityMembersScreen extends StatefulWidget {
  final int communityId;
  final bool isSelectionMode;
  final bool isCommunityAdmin;

  const CommunityMembersScreen({
    super.key,
    required this.communityId,
    this.isSelectionMode = false,
    this.isCommunityAdmin = false,
  });

  @override
  State<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _members = [];
  bool _isLoadingMembers = true;

  // Pending requests states
  List<dynamic> _requests = [];
  bool _isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _loadCachedMembers().then((_) {
      _fetchMembers();
    });
    if (widget.isCommunityAdmin) {
      _fetchRequests();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString('community_members_${widget.communityId}');
      if (cachedString != null) {
        final decoded = jsonDecode(cachedString);
        if (decoded is List) {
          setState(() {
            _members = decoded;
            _isLoadingMembers = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading cached members: $e");
    }
  }

  Future<void> _cacheMembers(List<dynamic> members) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('community_members_${widget.communityId}', jsonEncode(members));
    } catch (e) {
      debugPrint("Error caching members: $e");
    }
  }

  Future<void> _fetchMembers() async {
    if (_members.isEmpty) {
      setState(() => _isLoadingMembers = true);
    }
    try {
      final response = await ApiClient().dio.get('/api/v1/communities/${widget.communityId}/members');
      if (response.data != null && response.data['items'] != null) {
        final items = response.data['items'] as List;
        setState(() {
          _members = items;
        });
        _cacheMembers(items);
      }
    } catch (e) {
      debugPrint("Error fetching community members: $e");
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final response = await ApiClient().dio.get('/api/v1/communities/${widget.communityId}/members/requests');
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _requests = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching pending requests: $e");
    } finally {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _reviewMemberRequest(int userId, bool approve) async {
    try {
      final response = await ApiClient().dio.post(
        '/api/v1/communities/${widget.communityId}/members/$userId/review',
        data: {'approve': approve},
      );
      if (response.data != null && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(approve 
                ? (Localizations.localeOf(context).languageCode == 'en' ? 'Request approved!' : 'अनुरोध स्वीकृत!')
                : (Localizations.localeOf(context).languageCode == 'en' ? 'Request rejected!' : 'अनुरोध अस्वीकृत!')),
          ),
        );
        _fetchRequests();
        _fetchMembers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showAddMemberDialog(bool isEnglish) {
    showDialog(
      context: context,
      builder: (context) {
        return AddMemberDialog(
          communityId: widget.communityId,
          isEnglish: isEnglish,
          existingMembers: _members,
          onMemberAdded: _fetchMembers,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    if (widget.isCommunityAdmin) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              isEnglish ? 'Members & Requests' : 'सदस्य और अनुरोध',
              style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: TabBar(
              labelColor: ThemeConfig.primary,
              unselectedLabelColor: ThemeConfig.textSecondary,
              indicatorColor: ThemeConfig.primary,
              indicatorWeight: 3,
              tabs: [
                Tab(text: isEnglish ? 'Approved' : 'स्वीकृत सदस्य'),
                Tab(text: isEnglish ? 'Requests' : 'अनुरोध'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildApprovedMembersTab(isEnglish),
              _buildRequestsTab(isEnglish),
            ],
          ),
        ),
      );
    } else {
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
        body: _buildApprovedMembersTab(isEnglish),
      );
    }
  }

  Widget _buildApprovedMembersTab(bool isEnglish) {
    return _isLoadingMembers
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
                                m['user_district']?.toString() ?? (isEnglish ? 'Rajasthan' : 'राजस्थान'),
                                style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 11),
                              ),
                              trailing: null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
  }

  Widget _buildRequestsTab(bool isEnglish) {
    return _isLoadingRequests
        ? const Center(child: CircularProgressIndicator())
        : _requests.isEmpty
            ? Center(
                child: Text(
                  isEnglish ? 'No pending member requests.' : 'कोई लंबित सदस्यता अनुरोध नहीं है।',
                  style: const TextStyle(color: ThemeConfig.textSecondary),
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchRequests,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    final name = req['user_name'] ?? '';
                    final photo = req['user_photo'];

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: ThemeConfig.border),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: (photo != null && photo.toString().isNotEmpty)
                                  ? NetworkImage(photo)
                                  : null,
                              child: (photo == null || photo.toString().isEmpty)
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isEnglish ? 'Requested to join' : 'सदस्यता का अनुरोध किया',
                                    style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _reviewMemberRequest(req['user_id'] as int, true),
                              tooltip: isEnglish ? 'Approve' : 'स्वीकार करें',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: ThemeConfig.error),
                              onPressed: () => _reviewMemberRequest(req['user_id'] as int, false),
                              tooltip: isEnglish ? 'Reject' : 'अस्वीकार करें',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

class AddMemberDialog extends StatefulWidget {
  final int communityId;
  final bool isEnglish;
  final List<dynamic> existingMembers;
  final VoidCallback onMemberAdded;

  const AddMemberDialog({
    super.key,
    required this.communityId,
    required this.isEnglish,
    required this.existingMembers,
    required this.onMemberAdded,
  });

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  List<dynamic> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _search("");
  }

  Future<void> _search(String val) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiClient().dio.get(
        '/api/v1/users/',
        queryParameters: {
          if (val.isNotEmpty) 'query': val,
        },
      );
      if (response.data != null && response.data['items'] != null && mounted) {
        setState(() {
          _users = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error searching users: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addMember(int userId) async {
    try {
      final response = await ApiClient().dio.post(
        '/api/v1/communities/${widget.communityId}/members',
        data: {'user_id': userId, 'role': 'member'},
      );
      if (response.data != null && response.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(widget.isEnglish
                  ? 'Member added successfully!'
                  : 'सदस्य को सफलतापूर्वक जोड़ा गया!'),
            ),
          );
          Navigator.pop(context);
          widget.onMemberAdded();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.isEnglish ? 'Add Community Member' : 'सदस्य जोड़ें'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: widget.isEnglish ? 'Search user...' : 'उपयोगकर्ता खोजें...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? Center(
                          child: Text(widget.isEnglish ? 'No users found.' : 'कोई उपयोगकर्ता नहीं मिला।'),
                        )
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final u = _users[index];
                            final isAlreadyMember = widget.existingMembers.any((m) => m['user_id'] == u['id']);

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
                                      widget.isEnglish ? 'Joined' : 'शामिल है',
                                      style: const TextStyle(color: ThemeConfig.textHint, fontSize: 12),
                                    )
                                  : ElevatedButton(
                                      onPressed: () => _addMember(u['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ThemeConfig.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      child: Text(
                                        widget.isEnglish ? 'Add' : 'जोड़ें',
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
          child: Text(widget.isEnglish ? 'Cancel' : 'रद्द करें'),
        ),
      ],
    );
  }
}
