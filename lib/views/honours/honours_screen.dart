import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/honours_provider.dart';
import 'apply_honour_screen.dart';
import 'bhamashah_details_screen.dart';
import 'pratibha_details_screen.dart';
import 'admin_honours_screen.dart';

class HonoursScreen extends StatefulWidget {
  const HonoursScreen({super.key});

  @override
  State<HonoursScreen> createState() => _HonoursScreenState();
}

class _HonoursScreenState extends State<HonoursScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  
  final List<String> _filters = ['सभी', 'शिक्षा', 'सेवा', 'सरकारी सेवा', 'प्रतियोगी परीक्षा', 'खेल', 'कला', 'व्यवसाय', 'अन्य'];
  String _selectedFilter = 'सभी';

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }
  
  void _fetchData() {
    context.read<HonoursProvider>().fetchHonours(
      category: _selectedFilter == 'सभी' ? null : _selectedFilter
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUserModel;
    final isAdmin = user?.role == 'admin' || user?.role == 'superadmin';
    final isMember = user?.role == 'member';
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: isEnglish ? 'Search name...' : 'नाम से खोजें...',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() {}),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEnglish ? 'Honours (Gaurav)' : 'सम्मान रत्न (गौरव)', style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(isEnglish ? 'Honoring outstanding individuals' : 'समाज के उत्कृष्ट व्यक्तियों का सम्मान', style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12)),
                ],
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: ThemeConfig.primary),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchCtrl.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: ThemeConfig.primary),
            onPressed: () {},
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: ThemeConfig.primary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHonoursScreen()));
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.primary,
          unselectedLabelColor: ThemeConfig.textSecondary,
          indicatorColor: ThemeConfig.primary,
          tabs: [
            Tab(text: isEnglish ? 'Bhamashah' : 'भामाशाह'),
            Tab(text: isEnglish ? 'Pratibha' : 'प्रतिभा'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Area - Only for Pratibha Tab
          if (_tabController.index == 1)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            _fetchData();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? ThemeConfig.primary : ThemeConfig.background,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? ThemeConfig.primary : ThemeConfig.border),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : ThemeConfig.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          
          Expanded(
            child: Consumer<HonoursProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: ThemeConfig.primary));
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBhamashahTab(provider.bhamashahs, isAdmin, isEnglish),
                    _buildPratibhaTab(provider.pratibhas, isAdmin, isEnglish),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          final isBhamashahTab = _tabController.index == 0;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ApplyHonourScreen(isAdminOrMember: (isAdmin || isMember), isBhamashah: isBhamashahTab)),
          ).then((_) => _fetchData());
        },
        backgroundColor: ThemeConfig.primary,
        icon: Icon((isAdmin || isMember) ? Icons.add : Icons.military_tech, color: Colors.white),
        label: Text((isAdmin || isMember) ? 'नया जोड़ें' : 'आवेदन करें', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBhamashahTab(List<BhamashahModel> list, bool isAdmin, bool isEnglish) {
    final query = _searchCtrl.text.toLowerCase();
    final filtered = list.where((i) => i.name.toLowerCase().contains(query)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(isEnglish ? 'Eminent Bhamashahs' : 'प्रतिष्ठित भामाशाह', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (filtered.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(isEnglish ? 'No Bhamashah found.' : 'कोई भामाशाह नहीं मिला।', style: const TextStyle(color: ThemeConfig.textSecondary))))
        else
          ...filtered.map((item) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ThemeConfig.border),
            ),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BhamashahDetailsScreen(bhamashah: item, isAdmin: isAdmin, onRefresh: _fetchData),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ThemeConfig.background,
                        borderRadius: BorderRadius.circular(12),
                        image: item.photoUrl != null && item.photoUrl!.isNotEmpty
                            ? DecorationImage(image: NetworkImage(item.photoUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: item.photoUrl == null || item.photoUrl!.isEmpty
                          ? const Icon(Icons.person, color: ThemeConfig.textSecondary, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: ThemeConfig.textHint),
                              const SizedBox(width: 4),
                              Expanded(child: Text(item.district != null && item.district!.isNotEmpty ? item.district! : '-', style: const TextStyle(color: ThemeConfig.textHint, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          if (item.donationAmount != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade100),
                                ),
                                child: Text(
                                  isEnglish ? 'Donation: ₹${item.donationAmount}' : 'योगदान: ₹${item.donationAmount}',
                                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.chevron_right, color: ThemeConfig.textHint),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildPratibhaTab(List<PratibhaModel> list, bool isAdmin, bool isEnglish) {
    final query = _searchCtrl.text.toLowerCase();
    final filtered = list.where((i) => i.name.toLowerCase().contains(query)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(isEnglish ? 'Eminent Talents' : 'प्रतिष्ठित प्रतिभाएं', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (filtered.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(isEnglish ? 'No talent found.' : 'कोई प्रतिभा नहीं मिली।', style: const TextStyle(color: ThemeConfig.textSecondary))))
        else
          ...filtered.map((item) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: ThemeConfig.border),
            ),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PratibhaDetailsScreen(pratibha: item, isAdmin: isAdmin, onRefresh: _fetchData),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ThemeConfig.background,
                        borderRadius: BorderRadius.circular(12),
                        image: item.photoUrl != null && item.photoUrl!.isNotEmpty
                            ? DecorationImage(image: NetworkImage(item.photoUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: item.photoUrl == null || item.photoUrl!.isEmpty
                          ? const Icon(Icons.military_tech, color: ThemeConfig.primary, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))),
                              if (item.year != null && item.year!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.orange.shade200)),
                                  child: Text(isEnglish ? 'Year: ${item.year}' : 'वर्ष: ${item.year}', style: TextStyle(color: Colors.orange.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.achievement, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: ThemeConfig.textHint),
                              const SizedBox(width: 4),
                              Text(item.district != null && item.district!.isNotEmpty ? item.district! : '-', style: const TextStyle(color: ThemeConfig.textHint, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.chevron_right, color: ThemeConfig.textHint),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
      ],
    );
  }
}
