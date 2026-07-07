import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';
import '../../models/complaint_model.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';

import 'new_complaint_screen.dart';
import 'complaint_detail_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String? _statusFilter;
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  String _t(String hi, String en) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : hi;
  }

  bool _isAdmin(String? role) => role == 'admin' || role == 'superadmin' || role == 'member';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<ComplaintProvider>().fetchAllComplaints(status: _statusFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
      case 'open': return isEn ? 'Open' : 'नई';
      case 'assigned': return isEn ? 'Assigned' : 'सौंपी गई';
      case 'in_progress': return isEn ? 'In Progress' : 'प्रक्रिया में';
      case 'resolved': return isEn ? 'Resolved' : 'निस्तारित';
      case 'closed': return isEn ? 'Closed' : 'बंद';
      case 'cancelled': return isEn ? 'Cancelled' : 'रद्द';
      default: return status;
    }
  }

  String _categoryLabel(String cat) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    switch (cat) {
      case 'road': return isEn ? 'Road' : 'सड़क';
      case 'water': return isEn ? 'Water' : 'पानी';
      case 'electricity': return isEn ? 'Electricity' : 'बिजली';
      case 'sanitation': return isEn ? 'Sanitation' : 'स्वच्छता';
      case 'community_hall': return isEn ? 'Community Hall' : 'सामुदायिक भवन';
      case 'hostel': return isEn ? 'Hostel' : 'छात्रावास';
      case 'exam': return isEn ? 'Exam' : 'परीक्षा';
      case 'result': return isEn ? 'Result' : 'परिणाम';
      case 'app_feature': return isEn ? 'App Feature' : 'ऐप फीचर';
      case 'other': return isEn ? 'Other' : 'अन्य';
      default: return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final role = authProvider.currentUserModel?.role;
        final isAdmin = _isAdmin(role);

        return Scaffold(
          backgroundColor: ThemeConfig.background,
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: const TextStyle(color: ThemeConfig.textPrimary),
                    decoration: InputDecoration(
                      hintText: _t('खोजें...', 'Search...'),
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: ThemeConfig.textHint),
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Text(
                    _t('शिकायतें', 'Complaints'),
                    style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
                  ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _searchCtrl.clear();
                    }
                    _isSearching = !_isSearching;
                  });
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter Chips
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip(null, _t('सभी', 'All')),
                    _buildFilterChip('open', _t('नई', 'Open')),
                    _buildFilterChip('in_progress', _t('प्रक्रिया में', 'In Progress')),
                    _buildFilterChip('resolved', _t('निस्तारित', 'Resolved')),
                    _buildFilterChip('cancelled', _t('रद्द', 'Cancelled')),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Complaint List
              Expanded(
                child: Consumer<ComplaintProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: ThemeConfig.primary));
                    }
                    final list = provider.allComplaints;
                    final query = _searchCtrl.text.toLowerCase();
                    final filtered = list.where((c) {
                      if (query.isNotEmpty) {
                        return c.title.toLowerCase().contains(query) ||
                            (c.complaintNumber ?? '').toLowerCase().contains(query);
                      }
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: ThemeConfig.textHint.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(_t('कोई शिकायत नहीं मिली', 'No complaints found'), style: const TextStyle(color: ThemeConfig.textSecondary)),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: ThemeConfig.primary,
                      onRefresh: () async => _load(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildComplaintCard(filtered[index], isAdmin),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: !isAdmin
              ? FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NewComplaintScreen()))
                        .then((_) => _load());
                  },
                  backgroundColor: ThemeConfig.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(_t('नई शिकायत दर्ज करें', 'New Complaint'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              : null,
        );
      },
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : ThemeConfig.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          _load();
        },
        selectedColor: ThemeConfig.primary,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? ThemeConfig.primary : ThemeConfig.border)),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel c, bool isAdmin) {
    final dateStr = c.createdAt != null ? DateFormat('dd MMM yyyy - hh:mm a').format(c.createdAt!.toLocal()) : '';
    final sColor = _statusColor(c.status);

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ThemeConfig.divider, width: 1.0)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ComplaintDetailScreen(complaintId: c.id, isAdmin: isAdmin, onRefresh: _load),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Complaint Number
                    if (c.complaintNumber != null) ...[
                      Text('#${c.complaintNumber}', style: const TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                    ],
                    // Title
                    Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ThemeConfig.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: ThemeConfig.background, borderRadius: BorderRadius.circular(4)),
                      child: Text(_categoryLabel(c.category), style: const TextStyle(fontSize: 10, color: ThemeConfig.textSecondary, fontWeight: FontWeight.w500)),
                    ),
                    // Admin: Show user name
                    if (isAdmin && c.userName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 13, color: ThemeConfig.textHint),
                          const SizedBox(width: 4),
                          Expanded(child: Text(c.userName!, style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Date
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: ThemeConfig.textHint),
                        const SizedBox(width: 4),
                        Expanded(child: Text(dateStr, style: const TextStyle(color: ThemeConfig.textHint, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right Side: Status and Image
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_statusLabel(c.status), style: TextStyle(color: sColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  if (c.imageUrls != null && c.imageUrls!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        c.imageUrls!.first,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: ThemeConfig.background,
                          child: const Icon(Icons.image_not_supported, color: ThemeConfig.textHint, size: 20),
                        ),
                      ),
                    ),
                  ],
                  // Location under image
                  if (c.location != null && c.location!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: ThemeConfig.textHint),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              c.location!,
                              style: const TextStyle(fontSize: 10, color: ThemeConfig.textHint),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
