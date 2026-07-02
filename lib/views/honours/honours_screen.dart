import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/honours_provider.dart';
import '../../providers/auth_provider.dart';
import 'apply_honour_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('सम्मान रत्न (गौरव)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
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
          tabs: const [
            Tab(text: 'भामाशाह'),
            Tab(text: 'प्रतिभा'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: ThemeConfig.background,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: const InputDecoration(
                            hintText: 'खोजें...',
                            hintStyle: TextStyle(color: ThemeConfig.textHint),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: ThemeConfig.textHint),
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeConfig.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.filter_list, color: ThemeConfig.primary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                    _buildBhamashahTab(provider.bhamashahs),
                    _buildPratibhaTab(provider.pratibhas),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final isBhamashahTab = _tabController.index == 0;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApplyHonourScreen(
                isAdminOrMember: (isAdmin || isMember),
                isBhamashah: isBhamashahTab,
              ),
            ),
          ).then((value) {
            if (value == true) _fetchData();
          });
        },
        backgroundColor: ThemeConfig.primary,
        icon: const Icon(Icons.military_tech, color: Colors.white),
        label: const Text('सम्मान हेतु आवेदन करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBhamashahTab(List<BhamashahModel> list) {
    // Basic search filter
    final query = _searchCtrl.text.toLowerCase();
    final filtered = list.where((i) => i.name.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) return const Center(child: Text('कोई भामाशाह नहीं मिला।', style: TextStyle(color: ThemeConfig.textSecondary)));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: ThemeConfig.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ThemeConfig.background,
                  backgroundImage: item.photoUrl != null && item.photoUrl!.isNotEmpty ? NetworkImage(item.photoUrl!) : null,
                  child: item.photoUrl == null || item.photoUrl!.isEmpty ? const Icon(Icons.person, color: ThemeConfig.textSecondary, size: 28) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      if (item.district != null && item.district!.isNotEmpty)
                        Text(item.district!, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12)),
                      if (item.donationAmount != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('योगदान: ₹${item.donationAmount}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: ThemeConfig.textHint),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPratibhaTab(List<PratibhaModel> list) {
    final query = _searchCtrl.text.toLowerCase();
    final filtered = list.where((i) => i.name.toLowerCase().contains(query)).toList();

    if (filtered.isEmpty) return const Center(child: Text('कोई प्रतिभा नहीं मिली।', style: TextStyle(color: ThemeConfig.textSecondary)));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: ThemeConfig.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ThemeConfig.background,
                  backgroundImage: item.photoUrl != null && item.photoUrl!.isNotEmpty ? NetworkImage(item.photoUrl!) : null,
                  child: item.photoUrl == null || item.photoUrl!.isEmpty ? const Icon(Icons.military_tech, color: ThemeConfig.primary, size: 28) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(item.category, style: TextStyle(color: Colors.orange.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.achievement, style: const TextStyle(color: ThemeConfig.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (item.year != null && item.year!.isNotEmpty)
                        Text('वर्ष: ${item.year}', style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: ThemeConfig.textHint),
              ],
            ),
          ),
        );
      },
    );
  }
}
