import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme_config.dart';
import '../../providers/honours_provider.dart';
import 'apply_honour_screen.dart';

class PratibhaDetailsScreen extends StatefulWidget {
  final PratibhaModel pratibha;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const PratibhaDetailsScreen({
    super.key,
    required this.pratibha,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  State<PratibhaDetailsScreen> createState() => _PratibhaDetailsScreenState();
}

class _PratibhaDetailsScreenState extends State<PratibhaDetailsScreen> {
  void _share() {
    Share.share('प्रतिभा विवरण: ${widget.pratibha.name} - ${widget.pratibha.achievement}\nयह गौरवशाली जानकारी मारू प्रजापत समाज ऐप पर देखें!');
  }

  void _edit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplyHonourScreen(
          isAdminOrMember: true,
          isBhamashah: false,
          editPratibha: widget.pratibha,
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
        content: const Text('क्या आप वाकई इस प्रतिभा को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('रद्द करें')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('डिलीट', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await context.read<HonoursProvider>().deletePratibha(widget.pratibha.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('प्रतिभा हटा दी गई')));
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
        title: const Text('प्रतिभा विवरण', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
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
                    backgroundImage: widget.pratibha.photoUrl != null && widget.pratibha.photoUrl!.isNotEmpty
                        ? NetworkImage(widget.pratibha.photoUrl!)
                        : null,
                    child: widget.pratibha.photoUrl == null || widget.pratibha.photoUrl!.isEmpty
                        ? const Icon(Icons.military_tech, color: ThemeConfig.primary, size: 50)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.pratibha.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 6),
                        Text(widget.pratibha.achievement, style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary)),
                        const SizedBox(height: 8),
                        if (widget.pratibha.year != null && widget.pratibha.year!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('वर्ष: ${widget.pratibha.year}', style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
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
                  _buildGridItem(Icons.school_outlined, 'श्रेणी', widget.pratibha.category),
                  _buildVerticalDivider(),
                  _buildGridItem(Icons.location_on_outlined, 'स्थान', widget.pratibha.location ?? 'उपलब्ध नहीं'),
                  _buildVerticalDivider(),
                  _buildGridItem(Icons.calendar_today_outlined, 'सम्मान वर्ष', widget.pratibha.year ?? 'उपलब्ध नहीं'),
                  _buildVerticalDivider(),
                  _buildGridItem(Icons.check_circle_outline, 'स्थिति', widget.pratibha.status == 'approved' ? 'प्रकाशित' : 'समीक्षा में'),
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
                  const Text('उपलब्धि विवरण', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text(
                    widget.pratibha.details != null && widget.pratibha.details!.isNotEmpty
                        ? widget.pratibha.details!
                        : '${widget.pratibha.name} ने ${widget.pratibha.achievement} में सफलता प्राप्त की और समाज का गौरव बढ़ाया।',
                    style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary, height: 1.5),
                  ),
                  
                  const Divider(height: 48, thickness: 1, color: ThemeConfig.border),
                  
                  const Text('प्रेरणा', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  const Text(
                    'इनकी मेहनत, लगन और समर्पण से समाज के युवाओं को प्रेरणा मिलती है।',
                    style: TextStyle(fontSize: 14, color: ThemeConfig.textSecondary, height: 1.5),
                  ),
                  
                  if (widget.pratibha.dob != null && widget.pratibha.dob!.isNotEmpty) ...[
                    const Divider(height: 48, thickness: 1, color: ThemeConfig.border),
                    const Text('व्यक्तिगत जानकारी', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, size: 16, color: ThemeConfig.textSecondary),
                        const SizedBox(width: 8),
                        Text('जन्म तिथि: ${widget.pratibha.dob}', style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary)),
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
