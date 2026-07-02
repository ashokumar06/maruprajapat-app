import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/honours_provider.dart';
import 'apply_honour_screen.dart';

class AdminHonoursScreen extends StatefulWidget {
  const AdminHonoursScreen({super.key});

  @override
  State<AdminHonoursScreen> createState() => _AdminHonoursScreenState();
}

class _AdminHonoursScreenState extends State<AdminHonoursScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HonoursProvider>().fetchAdminDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('सम्मान रत्न (गौरव) - Admin', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HonoursProvider>().fetchAdminDashboard();
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
      backgroundColor: ThemeConfig.background,
      body: Consumer<HonoursProvider>(
        builder: (context, provider, child) {
          final dash = provider.adminDashboard;
          if (dash == null) {
            return const Center(child: CircularProgressIndicator(color: ThemeConfig.primary));
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboard(dash['bhamashah']),
              _buildDashboard(dash['pratibha']),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              final isBhamashahTab = _tabController.index == 0;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ApplyHonourScreen(isAdminOrMember: true, isBhamashah: isBhamashahTab)),
              ).then((_) {
                context.read<HonoursProvider>().fetchAdminDashboard();
                context.read<HonoursProvider>().fetchHonours();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('नया जोड़ें', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(Map<String, dynamic> data) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('कुल सूचीबद्ध', data['total_listed'].toString(), Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('नए आवेदन', data['new_applications'].toString(), Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('स्वीकृत', data['approved'].toString(), Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('अस्वीकृत', data['rejected'].toString(), Colors.red)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('प्रतिष्ठित प्रतिभाएं / भामाशाह', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary)),
        const SizedBox(height: 12),
        // Placeholder for detailed list
        const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('सभी आवेदनों की विस्तृत सूची यहाँ दिखाई देगी (आगामी अपडेट)।', style: TextStyle(color: ThemeConfig.textSecondary)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeConfig.border),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
