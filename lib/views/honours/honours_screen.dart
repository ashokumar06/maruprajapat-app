import 'package:flutter/material.dart';
import '../../config/theme_config.dart';

import 'package:provider/provider.dart';
import '../../providers/honours_provider.dart';

class HonoursScreen extends StatefulWidget {
  const HonoursScreen({super.key});

  @override
  State<HonoursScreen> createState() => _HonoursScreenState();
}

class _HonoursScreenState extends State<HonoursScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HonoursProvider>().fetchHonours();
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
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('समाज रत्न (गौरव)', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
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
      body: Consumer<HonoursProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Open Apply Form
          _showApplyModal(context);
        },
        backgroundColor: ThemeConfig.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('आवेदन करें', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildBhamashahTab(List<BhamashahModel> list) {
    if (list.isEmpty) return const Center(child: Text('कोई भामाशाह नहीं मिला।'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: item.photoUrl != null ? NetworkImage(item.photoUrl!) : null,
              child: item.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.donationAmount != null) Text('योगदान: ₹${item.donationAmount}', style: const TextStyle(color: Colors.green)),
                if (item.details != null) Text(item.details!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPratibhaTab(List<PratibhaModel> list) {
    if (list.isEmpty) return const Center(child: Text('कोई प्रतिभा नहीं मिली।'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: item.photoUrl != null ? NetworkImage(item.photoUrl!) : null,
              child: item.photoUrl == null ? const Icon(Icons.star, color: Colors.orange) : null,
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.achievement, style: const TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.w600)),
                if (item.details != null) Text(item.details!, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showApplyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: const ApplyHonourForm(),
        );
      },
    );
  }
}

class ApplyHonourForm extends StatefulWidget {
  const ApplyHonourForm({super.key});
  @override
  State<ApplyHonourForm> createState() => _ApplyHonourFormState();
}

class _ApplyHonourFormState extends State<ApplyHonourForm> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Bhamashah';
  final _nameCtrl = TextEditingController();
  final _achievementCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<HonoursProvider>();
    bool success = false;
    
    if (_type == 'Bhamashah') {
      success = await provider.applyBhamashah({
        'name': _nameCtrl.text,
        'details': _detailsCtrl.text,
        'donation_amount': double.tryParse(_amountCtrl.text) ?? 0,
      });
    } else {
      success = await provider.applyPratibha({
        'name': _nameCtrl.text,
        'achievement': _achievementCtrl.text,
        'details': _detailsCtrl.text,
      });
    }
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('आवेदन सफलतापूर्वक जमा कर दिया गया है।')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('आवेदन विफल रहा। पुनः प्रयास करें।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('नया आवेदन', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'Bhamashah', child: Text('भामाशाह')),
                DropdownMenuItem(value: 'Pratibha', child: Text('प्रतिभा')),
              ],
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'श्रेणी'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'पूरा नाम'),
              validator: (v) => v!.isEmpty ? 'नाम आवश्यक है' : null,
            ),
            if (_type == 'Bhamashah') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'योगदान राशि (₹)'),
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _achievementCtrl,
                decoration: const InputDecoration(labelText: 'उपलब्धि (Achievement)'),
                validator: (v) => v!.isEmpty ? 'उपलब्धि आवश्यक है' : null,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailsCtrl,
              decoration: const InputDecoration(labelText: 'अन्य विवरण'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('जमा करें', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
