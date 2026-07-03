import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme_config.dart';
import '../../providers/honours_provider.dart';
import 'apply_honour_screen.dart';

class BhamashahDetailsScreen extends StatefulWidget {
  final BhamashahModel bhamashah;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const BhamashahDetailsScreen({
    super.key,
    required this.bhamashah,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  State<BhamashahDetailsScreen> createState() => _BhamashahDetailsScreenState();
}

class _BhamashahDetailsScreenState extends State<BhamashahDetailsScreen> {
  void _share() {
    Share.share('भामाशाह विवरण: ${widget.bhamashah.name} ${widget.bhamashah.district != null ? '- ${widget.bhamashah.district}' : ''}\nयह गौरवशाली जानकारी मारू प्रजापत समाज ऐप पर देखें!');
  }

  void _edit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyHonourScreen(
          isAdminOrMember: true,
          isBhamashah: true,
          editBhamashah: widget.bhamashah,
        ),
      ),
    ).then((val) {
      if (val == true) {
        widget.onRefresh();
        Navigator.pop(context);
      }
    });
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('डिलीट करें?'),
        content: const Text('क्या आप वाकई इस भामाशाह को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('रद्द करें')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('डिलीट', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await context.read<HonoursProvider>().deleteBhamashah(widget.bhamashah.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('भामाशाह हटा दिया गया')));
        widget.onRefresh();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('भामाशाह विवरण', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.orange.shade50,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _edit,
              tooltip: 'एडिट करें',
            ),
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
              tooltip: 'डिलीट करें',
            ),
          IconButton(
            icon: const Icon(Icons.share, color: ThemeConfig.textPrimary),
            onPressed: _share,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: widget.bhamashah.photoUrl != null && widget.bhamashah.photoUrl!.isNotEmpty
                        ? NetworkImage(widget.bhamashah.photoUrl!)
                        : null,
                    child: widget.bhamashah.photoUrl == null || widget.bhamashah.photoUrl!.isEmpty
                        ? const Icon(Icons.person, color: ThemeConfig.textSecondary, size: 50)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.bhamashah.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 6),
                        if (widget.bhamashah.district != null && widget.bhamashah.district!.isNotEmpty)
                          Text(widget.bhamashah.district!, style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary)),
                        const SizedBox(height: 8),
                        if (widget.bhamashah.donationAmount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('योगदान: ₹${widget.bhamashah.donationAmount}', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildGridItem(Icons.location_city_outlined, 'ज़िला', widget.bhamashah.district ?? 'उपलब्ध नहीं'),
                  _buildVerticalDivider(),
                  _buildGridItem(Icons.phone_outlined, 'मोबाइल', widget.bhamashah.mobileNumber ?? 'उपलब्ध नहीं'),
                  _buildVerticalDivider(),
                  _buildGridItem(Icons.email_outlined, 'ईमेल', (widget.bhamashah.email != null && widget.bhamashah.email!.isNotEmpty) ? widget.bhamashah.email! : 'उपलब्ध नहीं'),
                  _buildVerticalDivider(),
                  _buildGridItem(Icons.check_circle_outline, 'स्थिति', widget.bhamashah.status == 'approved' ? 'प्रकाशित' : 'समीक्षा में'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('योगदान विवरण', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text(
                    widget.bhamashah.details != null && widget.bhamashah.details!.isNotEmpty
                        ? widget.bhamashah.details!
                        : '${widget.bhamashah.name} जी ने समाज के विकास में अपना बहुमूल्य योगदान दिया है। समाज उनके इस सहयोग के लिए सदैव आभारी रहेगा।',
                    style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary, height: 1.5),
                  ),
                  
                  if (widget.bhamashah.dob != null && widget.bhamashah.dob!.isNotEmpty || widget.bhamashah.address != null && widget.bhamashah.address!.isNotEmpty) ...[
                    const Divider(height: 48, thickness: 1, color: ThemeConfig.border),
                    const Text('व्यक्तिगत जानकारी', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    if (widget.bhamashah.dob != null && widget.bhamashah.dob!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.cake_outlined, size: 16, color: ThemeConfig.textSecondary),
                          const SizedBox(width: 8),
                          Text('जन्म तिथि: ${widget.bhamashah.dob}', style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary)),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (widget.bhamashah.address != null && widget.bhamashah.address!.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.home_outlined, size: 16, color: ThemeConfig.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(child: Text('पता: ${widget.bhamashah.address}', style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary))),
                        ],
                      ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: ThemeConfig.primary, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 11, color: ThemeConfig.textSecondary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.orange.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
