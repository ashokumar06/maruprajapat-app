import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import 'create_community_screen.dart';
import 'community_details_screen.dart';

class CommunityGroupsTab extends StatefulWidget {
  const CommunityGroupsTab({super.key});

  @override
  State<CommunityGroupsTab> createState() => _CommunityGroupsTabState();
}

class _CommunityGroupsTabState extends State<CommunityGroupsTab> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _myCommunities = [];
  List<dynamic> _allCommunities = [];
  List<dynamic> _pendingRequests = [];
  
  bool _isLoadingMy = false;
  bool _isLoadingAll = false;
  bool _isLoadingRequests = false;
  
  String _searchQuery = "";
  String? _selectedCategory;
  
  int _tabLength = 2;
  bool _isAdmin = false;
  bool _isMember = false;
  bool _isRegularUser = false;
  dynamic _lastUser;

  final List<String> _categories = [
    'सभी', 'शिक्षा • सेवा', 'सेवा • सहयोग', 'शिक्षा • मार्गदर्शन', 'सेवा • स्वास्थ्य', 'युवा • विकास', 'महिला • उत्थान'
  ];

  void _updateRoles(dynamic user) {
    if (user == _lastUser) return;
    _lastUser = user;

    final role = (user?.role ?? 'guest').toString().toLowerCase();
    final newAdmin = role == 'admin' || role == 'superadmin';
    final newMember = role == 'member';
    final newRegular = !newAdmin && !newMember;

    int newTabLength = 1;
    if (newAdmin) {
      newTabLength = 3;
    } else if (newMember) {
      newTabLength = 2;
    } else {
      newTabLength = 1;
    }

    if (newTabLength != _tabLength) {
      _isAdmin = newAdmin;
      _isMember = newMember;
      _isRegularUser = newRegular;
      _tabLength = newTabLength;
      _tabController.dispose();
      _tabController = TabController(length: _tabLength, vsync: this);
      _tabController.addListener(() {
        if (_tabLength == 1) return;
        if (_tabController.index == 0) {
          _fetchMyCommunities();
        } else if (_tabController.index == 1) {
          _fetchAllCommunities();
        } else if (_tabController.index == 2 && _isAdmin) {
          _fetchPendingRequests();
        }
      });

      // Fetch data after the current frame is laid out
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            if (!_isRegularUser) {
              _fetchMyCommunities();
            }
            _fetchAllCommunities();
            if (_isAdmin) {
              _fetchPendingRequests();
            }
          });
        }
      });
    } else {
      _isAdmin = newAdmin;
      _isMember = newMember;
      _isRegularUser = newRegular;
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUserModel;
    final role = (user?.role ?? 'guest').toString().toLowerCase();
    _isAdmin = role == 'admin' || role == 'superadmin';
    _isMember = role == 'member';
    _isRegularUser = !_isAdmin && !_isMember;
    _lastUser = user;

    if (_isAdmin) {
      _tabLength = 3;
    } else if (_isMember) {
      _tabLength = 2;
    } else {
      _tabLength = 1;
    }

    _tabController = TabController(length: _tabLength, vsync: this);
    _tabController.addListener(() {
      if (_tabLength == 1) return;
      
      if (_tabController.index == 0) {
        _fetchMyCommunities();
      } else if (_tabController.index == 1) {
        _fetchAllCommunities();
      } else if (_tabController.index == 2 && _isAdmin) {
        _fetchPendingRequests();
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      if (_tabLength == 1 || _tabController.index == 1) {
        _fetchAllCommunities();
      }
    });

    if (!_isRegularUser) {
      _fetchMyCommunities();
    }
    _fetchAllCommunities();
    if (_isAdmin) {
      _fetchPendingRequests();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyCommunities() async {
    setState(() => _isLoadingMy = true);
    try {
      final response = await ApiClient().dio.get('/api/v1/communities/my');
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _myCommunities = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching my communities: $e");
    } finally {
      setState(() => _isLoadingMy = false);
    }
  }

  Future<void> _fetchAllCommunities() async {
    setState(() => _isLoadingAll = true);
    try {
      final categoryFilter = (_selectedCategory == null || _selectedCategory == 'सभी') ? null : _selectedCategory;
      final response = await ApiClient().dio.get(
        '/api/v1/communities/',
        queryParameters: {
          if (_searchQuery.isNotEmpty) 'query': _searchQuery,
          if (categoryFilter != null) 'category': categoryFilter,
        },
      );
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _allCommunities = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching all communities: $e");
    } finally {
      setState(() => _isLoadingAll = false);
    }
  }

  Future<void> _fetchPendingRequests() async {
    setState(() => _isLoadingRequests = true);
    try {
      final response = await ApiClient().dio.get('/api/v1/communities/requests');
      if (response.data != null && response.data['items'] != null) {
        setState(() {
          _pendingRequests = response.data['items'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching pending requests: $e");
    } finally {
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _joinCommunity(int id) async {
    try {
      final response = await ApiClient().dio.post('/api/v1/communities/$id/join');
      if (response.data != null && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'en' 
              ? 'Successfully joined community!' 
              : 'समुदाय सफलतापूर्वक जॉइन किया गया!')),
        );
        _fetchMyCommunities();
        _fetchAllCommunities();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _reviewRequest(int id, bool approve) async {
    try {
      final response = await ApiClient().dio.post('/api/v1/communities/$id/review', data: {
        'approve': approve
      });
      if (response.data != null && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(approve ? 'समुदाय स्वीकृत किया गया!' : 'समुदाय अस्वीकृत किया गया।')),
        );
        _fetchPendingRequests();
        _fetchAllCommunities();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final user = context.watch<AuthProvider>().currentUserModel;
    _updateRoles(user);

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Samaj Communities' : 'समाज समुदाय',
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: _tabLength > 1
            ? TabBar(
                controller: _tabController,
                labelColor: ThemeConfig.primary,
                unselectedLabelColor: ThemeConfig.textSecondary,
                indicatorColor: ThemeConfig.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: isEnglish ? 'My Communities' : 'मेरे समुदाय'),
                  Tab(text: isEnglish ? 'All Communities' : 'सभी समुदाय'),
                  if (_isAdmin) Tab(text: isEnglish ? 'Requests' : 'अनुरोध'),
                ],
              )
            : null,
      ),
      body: _tabLength > 1
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildMyCommunitiesTab(isEnglish),
                _buildAllCommunitiesTab(isEnglish),
                if (_isAdmin) _buildRequestsTab(isEnglish),
              ],
            )
          : _buildAllCommunitiesTab(isEnglish),
    );
  }

  Widget _buildMyCommunitiesTab(bool isEnglish) {
    return RefreshIndicator(
      onRefresh: _fetchMyCommunities,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerCard(isEnglish),
                const SizedBox(height: 20),
                Text(
                  isEnglish ? 'My Communities (${_myCommunities.length})' : 'मेरे समुदाय (${_myCommunities.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                ),
              ],
            ),
          ),
          if (_isLoadingMy && _myCommunities.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_myCommunities.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildEmptyState(isEnglish ? 'You are not in any communities yet.' : 'आप अभी तक किसी समुदाय में शामिल नहीं हैं।'),
            )
          else
            ..._myCommunities.map((c) => _buildCommunityCard(c, isEnglish, isMy: true)),
        ],
      ),
    );
  }

  Widget _buildAllCommunitiesTab(bool isEnglish) {
    return RefreshIndicator(
      onRefresh: _fetchAllCommunities,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: isEnglish ? 'Search community...' : 'समुदाय खोजें...',
                      prefixIcon: const Icon(Icons.search, color: ThemeConfig.textHint),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ThemeConfig.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: ThemeConfig.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ThemeConfig.border),
                    ),
                    child: const Icon(Icons.filter_list, color: ThemeConfig.primary),
                  ),
                  onSelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                    _fetchAllCommunities();
                  },
                  itemBuilder: (context) {
                    return _categories.map((cat) {
                      return PopupMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoadingAll && _allCommunities.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _allCommunities.isEmpty
                    ? _buildEmptyState(isEnglish ? 'No communities found.' : 'कोई समुदाय नहीं मिला।')
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _allCommunities.length,
                        itemBuilder: (context, index) {
                          final c = _allCommunities[index];
                          return _buildCommunityCard(c, isEnglish, isMy: false);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTab(bool isEnglish) {
    return RefreshIndicator(
      onRefresh: _fetchPendingRequests,
      child: _isLoadingRequests && _pendingRequests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? _buildEmptyState(isEnglish ? 'No pending approval requests.' : 'कोई लंबित स्वीकृति अनुरोध नहीं है।')
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final c = _pendingRequests[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: ThemeConfig.border),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: ThemeConfig.primaryLight,
                                  child: const Icon(Icons.group_work, color: ThemeConfig.primary, size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c['name'] ?? '',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c['category'] ?? '',
                                        style: const TextStyle(fontSize: 12, color: ThemeConfig.primary, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              c['description'] ?? '',
                              style: const TextStyle(fontSize: 13, color: ThemeConfig.textSecondary, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _reviewRequest(c['id'], false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ThemeConfig.error,
                                    side: const BorderSide(color: ThemeConfig.error),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(isEnglish ? 'Reject' : 'अस्वीकार करें'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _reviewRequest(c['id'], true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(isEnglish ? 'Approve' : 'स्वीकार करें'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildBannerCard(bool isEnglish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeConfig.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeConfig.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups, color: ThemeConfig.primary, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish ? 'Connect with Communities' : 'समुदाय से जुड़ें, समाज को मजबूत बनाएं',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnglish 
                      ? 'Create groups, add members, post updates, and lead your community.' 
                      : 'समुदाय बनाएं, सदस्य जोड़ें, गतिविधियां चलाएं और समाज को एक नई दिशा दें।',
                  style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateCommunityScreen()),
                        ).then((_) {
                          _fetchMyCommunities();
                          _fetchAllCommunities();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(isEnglish ? 'Create' : 'समुदाय बनाएं', style: const TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        _tabController.animateTo(1);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeConfig.primary,
                        side: const BorderSide(color: ThemeConfig.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: Text(isEnglish ? 'Join' : 'समुदाय जॉइन करें', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCommunityCard(dynamic c, bool isEnglish, {required bool isMy}) {
    final role = c['role_in_community'] as String?;
    final isApproved = c['is_approved'] as bool;
    final int membersCount = c['members_count'] ?? 0;
    final int postsCount = c['posts_count'] ?? 0;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildCategoryIcon(c['category'] ?? ''),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    c['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ThemeConfig.textPrimary),
                  ),
                ),
                if (role != null) ...[
                  const SizedBox(width: 6),
                  _buildRoleBadge(role, isEnglish),
                ],
                if (!isApproved) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isEnglish ? 'Pending' : 'लंबित',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  c['category'] ?? '',
                  style: const TextStyle(fontSize: 12, color: ThemeConfig.primary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 11, color: ThemeConfig.textSecondary),
                    children: [
                      TextSpan(
                        text: isEnglish
                            ? 'Members: $membersCount   Posts: $postsCount   Activity: '
                            : 'सदस्य: $membersCount   पोस्ट: $postsCount   गतिविधि: ',
                      ),
                      TextSpan(
                        text: isEnglish ? 'Active' : 'सक्रिय',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: isMy || role != null
                ? const Icon(Icons.chevron_right, color: ThemeConfig.textHint)
                : ElevatedButton(
                    onPressed: () => _joinCommunity(c['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      isEnglish ? 'Join' : 'जॉइन',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
            onTap: isMy || role != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CommunityDetailsScreen(communityId: c['id'])),
                    ).then((_) {
                      _fetchMyCommunities();
                      _fetchAllCommunities();
                    });
                  }
                : null,
          ),
          const Divider(height: 1, color: ThemeConfig.border, indent: 16, endIndent: 16),
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_work_outlined, size: 64, color: ThemeConfig.textHint.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
