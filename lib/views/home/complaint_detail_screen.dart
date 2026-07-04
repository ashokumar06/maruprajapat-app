import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final int complaintId;
  final bool isAdmin;
  final VoidCallback? onRefresh;

  const ComplaintDetailScreen({super.key, required this.complaintId, this.isAdmin = false, this.onRefresh});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  ComplaintModel? _complaint;
  bool _isLoading = true;

  String _t(String hi, String en) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : hi;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final c = await context.read<ComplaintProvider>().fetchDetail(widget.complaintId);
    if (mounted) setState(() { _complaint = c; _isLoading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return Colors.blue;
      case 'assigned': return Colors.purple;
      case 'in_progress': return Colors.orange;
      case 'resolved': return ThemeConfig.success;
      case 'closed': return ThemeConfig.textSecondary;
      case 'cancelled': return ThemeConfig.error;
      default: return ThemeConfig.textHint;
    }
  }

  String _statusLabel(String status) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    switch (status) {
      case 'open': return isEn ? 'Complaint Filed' : 'शिकायत दर्ज की गई';
      case 'assigned': return isEn ? 'Complaint Assigned' : 'शिकायत सौंपी गई';
      case 'in_progress': return isEn ? 'Under Review' : 'जांच जारी है';
      case 'resolved': return isEn ? 'Resolved' : 'समाधान हो गया';
      case 'closed': return isEn ? 'Closed' : 'बंद';
      case 'cancelled': return isEn ? 'Cancelled' : 'रद्द';
      default: return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'open': return Icons.fiber_new;
      case 'assigned': return Icons.assignment_ind;
      case 'in_progress': return Icons.timelapse;
      case 'resolved': return Icons.check_circle;
      case 'closed': return Icons.lock;
      case 'cancelled': return Icons.cancel;
      default: return Icons.circle;
    }
  }

  void _showCancelDialog() {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('शिकायत रद्द करें', 'Cancel Complaint'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeConfig.textPrimary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              if (_complaint != null) ...[
                const SizedBox(height: 8),
                Text('#${_complaint!.complaintNumber ?? _complaint!.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.primary)),
                Text(_complaint!.title, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              Text(_t('रद्द करने का कारण *', 'Reason for cancellation *'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border))),
                items: [
                  DropdownMenuItem(value: 'duplicate', child: Text(_t('डुप्लीकेट शिकायत', 'Duplicate complaint'))),
                  DropdownMenuItem(value: 'resolved_self', child: Text(_t('समस्या स्वयं हल हो गई', 'Issue resolved by itself'))),
                  DropdownMenuItem(value: 'wrong', child: Text(_t('गलती से दर्ज हुई', 'Submitted by mistake'))),
                  DropdownMenuItem(value: 'other', child: Text(_t('अन्य', 'Other'))),
                ],
                onChanged: (v) {
                  if (v == 'other') {
                    reasonCtrl.clear();
                  } else {
                    final labels = {'duplicate': 'डुप्लीकेट शिकायत', 'resolved_self': 'समस्या स्वयं हल हो गई', 'wrong': 'गलती से दर्ज हुई'};
                    reasonCtrl.text = labels[v] ?? v ?? '';
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(_t('विवरण (ऐच्छिक)', 'Details (Optional)'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: reasonCtrl,
                maxLines: 3,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: _t('कारण लिखें...', 'Write reason...'),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final reason = reasonCtrl.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('कृपया कारण चुनें', 'Please select a reason')), backgroundColor: ThemeConfig.error));
                      return;
                    }
                    Navigator.pop(ctx);
                    final ok = await context.read<ComplaintProvider>().cancelComplaint(_complaint!.id, reason);
                    if (mounted && ok) {
                      widget.onRefresh?.call();
                      _load();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('शिकायत रद्द कर दी गई', 'Complaint cancelled')), backgroundColor: ThemeConfig.success));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeConfig.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_t('रद्द करें', 'Cancel'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusUpdateDialog() {
    String? selectedStatus;
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_t('स्थिति अपडेट करें', 'Update Status'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: _t('नई स्थिति', 'New Status'),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                ),
                items: [
                  DropdownMenuItem(value: 'assigned', child: Text(_t('सौंपी गई', 'Assigned'))),
                  DropdownMenuItem(value: 'in_progress', child: Text(_t('प्रक्रिया में', 'In Progress'))),
                  DropdownMenuItem(value: 'resolved', child: Text(_t('समाधान', 'Resolved'))),
                  DropdownMenuItem(value: 'closed', child: Text(_t('बंद', 'Closed'))),
                ],
                onChanged: (v) => selectedStatus = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _t('टिप्पणी (ऐच्छिक)', 'Note (Optional)'),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedStatus == null) return;
                    Navigator.pop(ctx);
                    final ok = await context.read<ComplaintProvider>().updateStatus(
                      _complaint!.id, selectedStatus!, note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                    );
                    if (mounted && ok) {
                      widget.onRefresh?.call();
                      _load();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeConfig.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_t('अपडेट करें', 'Update'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ThemeConfig.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: ThemeConfig.textPrimary)),
        body: const Center(child: CircularProgressIndicator(color: ThemeConfig.primary)),
      );
    }
    if (_complaint == null) {
      return Scaffold(
        backgroundColor: ThemeConfig.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: ThemeConfig.textPrimary)),
        body: Center(child: Text(_t('शिकायत नहीं मिली', 'Complaint not found'))),
      );
    }
    final c = _complaint!;
    final sColor = _statusColor(c.status);
    final dateStr = c.createdAt != null ? DateFormat('dd MMM yyyy - hh:mm a').format(c.createdAt!.toLocal()) : '';
    final canCancel = !widget.isAdmin && !['resolved', 'closed', 'cancelled'].contains(c.status);

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(_t('शिकायत विवरण', 'Complaint Detail'), style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_note, color: ThemeConfig.primary),
              onPressed: _showStatusUpdateDialog,
              tooltip: _t('स्थिति बदलें', 'Change Status'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ThemeConfig.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (c.complaintNumber != null)
                        Text('#${c.complaintNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.primary, fontSize: 16)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: sColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(_statusLabel(c.status), style: TextStyle(color: sColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: ThemeConfig.textPrimary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: ThemeConfig.textHint),
                      const SizedBox(width: 4),
                      Text(dateStr, style: const TextStyle(color: ThemeConfig.textHint, fontSize: 13)),
                    ],
                  ),
                  if (c.location != null && c.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: ThemeConfig.textHint),
                        const SizedBox(width: 4),
                        Expanded(child: Text(c.location!, style: const TextStyle(color: ThemeConfig.textHint, fontSize: 13))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Complainant Info (Admin view)
            if (widget.isAdmin && c.userName != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ThemeConfig.border)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: ThemeConfig.background,
                      backgroundImage: c.userPhoto != null ? NetworkImage(c.userPhoto!) : null,
                      child: c.userPhoto == null ? const Icon(Icons.person, color: ThemeConfig.textHint) : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('शिकायतकर्ता', 'Complainant'), style: const TextStyle(color: ThemeConfig.textHint, fontSize: 11)),
                        Text(c.userName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),

            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ThemeConfig.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('विवरण', 'Description'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeConfig.textPrimary)),
                  const SizedBox(height: 8),
                  Text(c.description, style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Images
            if (c.imageUrls != null && c.imageUrls!.isNotEmpty) ...[
              Text(_t('संलग्नक', 'Attachments'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.imageUrls!.length,
                  itemBuilder: (ctx, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _showFullImage(c.imageUrls![i]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(c.imageUrls![i], width: 100, height: 100, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status Timeline
            Text(_t('स्थिति अपडेट', 'Status Updates'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ThemeConfig.textPrimary)),
            const SizedBox(height: 12),
            ...c.statusHistory.asMap().entries.map((entry) {
              final h = entry.value;
              final isLast = entry.key == c.statusHistory.length - 1;
              final hColor = _statusColor(h.newStatus);
              final hDate = h.createdAt != null ? DateFormat('dd MMM yyyy - hh:mm a').format(h.createdAt!.toLocal()) : '';
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline line + dot
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(color: hColor, shape: BoxShape.circle),
                          ),
                          if (!isLast)
                            Expanded(child: Container(width: 2, color: ThemeConfig.border)),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_statusLabel(h.newStatus), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: hColor)),
                            const SizedBox(height: 4),
                            Text(hDate, style: const TextStyle(color: ThemeConfig.textHint, fontSize: 12)),
                            if (h.note != null && h.note!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(h.note!, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13)),
                            ],
                            if (h.changedByName != null) ...[
                              const SizedBox(height: 2),
                              Text('${_t('द्वारा', 'By')}: ${h.changedByName}', style: const TextStyle(color: ThemeConfig.textHint, fontSize: 11)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Cancel button (for non-admin, only if not resolved/closed/cancelled)
            if (canCancel)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _showCancelDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: ThemeConfig.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_t('शिकायत रद्द करें', 'Cancel Complaint'), style: const TextStyle(color: ThemeConfig.error, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.contain)),
            Positioned(top: 8, right: 8, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 28), onPressed: () => Navigator.pop(ctx))),
          ],
        ),
      ),
    );
  }
}
