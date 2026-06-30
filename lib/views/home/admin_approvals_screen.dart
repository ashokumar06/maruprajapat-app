import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/api_client.dart';

class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<dynamic> _pendingList = [];
  final List<dynamic> _approvedList = [];
  final List<dynamic> _rejectedList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    _pendingList.clear();
    _approvedList.clear();
    _rejectedList.clear();

    try {
      final client = ApiClient().dio;
      final response = await client.get('/api/v1/memberships/', queryParameters: {'per_page': 100});

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true) {
          final List items = data['items'] ?? [];
          for (var item in items) {
            final status = item['status'];
            if (status == 'pending') {
              _pendingList.add(item);
            } else if (status == 'approved') {
              _approvedList.add(item);
            } else {
              _rejectedList.add(item);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('अनुमोदन सूची लोड करने में विफल'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reviewApplication(int id, String status, String? note) async {
    setState(() => _isLoading = true);
    try {
      final client = ApiClient().dio;
      final response = await client.patch(
        '/api/v1/memberships/$id/review',
        data: {
          'status': status,
          'admin_note': note,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('आवेदन सफलतापूर्वक अपडेट कर दिया गया'),
              backgroundColor: ThemeConfig.success,
            ),
          );
        }
        await _fetchRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('आवेदन अपडेट करने में विफल'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showReviewDialog(int id, String status) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(status == 'approved' ? 'आवेदन स्वीकार करें' : 'आवेदन अस्वीकार/सुधार करें'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'टिप्पणी दर्ज करें (वैकल्पिक)...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('रद्द करें'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _reviewApplication(id, status, noteController.text.trim().isNotEmpty ? noteController.text : null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'approved' ? ThemeConfig.success : ThemeConfig.error,
              ),
              child: const Text('पुष्टि करें', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(List<dynamic> list) {
    if (list.isEmpty) {
      return const Center(child: Text('कोई आवेदन नहीं मिला।', style: TextStyle(color: ThemeConfig.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final req = list[index];
        final id = req['id'];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: ThemeConfig.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: ThemeConfig.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      req['full_name'] ?? 'अज्ञात',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                    ),
                    _buildStatusBadge(req['status']),
                  ],
                ),
                const SizedBox(height: 8),
                Text('स्थान: ${req['village'] ?? ''}, ${req['district'] ?? ''}', style: const TextStyle(fontSize: 14, color: ThemeConfig.textSecondary)),
                if (req['admin_note'] != null) ...[
                  const SizedBox(height: 8),
                  Text('एडमिन टिप्पणी: ${req['admin_note']}', style: const TextStyle(fontSize: 13, color: ThemeConfig.error, fontStyle: FontStyle.italic)),
                ],
                if (req['status'] == 'pending') ...[
                  const SizedBox(height: 16),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _showReviewDialog(id, 'correction_needed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeConfig.primary,
                          side: const BorderSide(color: ThemeConfig.primary),
                        ),
                        child: const Text('सुधार आवश्यक'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _showReviewDialog(id, 'rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ThemeConfig.error,
                          side: const BorderSide(color: ThemeConfig.error),
                        ),
                        child: const Text('अस्वीकार करें'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showReviewDialog(id, 'approved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeConfig.success,
                        ),
                        child: const Text('स्वीकार करें', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    String label = "लंबित";
    if (status == 'approved') {
      color = ThemeConfig.success;
      label = "स्वीकृत";
    } else if (status == 'rejected') {
      color = ThemeConfig.error;
      label = "अस्वीकृत";
    } else if (status == 'correction_needed') {
      color = Colors.blue;
      label = "सुधार आवश्यक";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('सदस्यता अनुमोदन', style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.primary,
          unselectedLabelColor: ThemeConfig.textSecondary,
          indicatorColor: ThemeConfig.primary,
          tabs: const [
            Tab(text: 'लंबित (Pending)'),
            Tab(text: 'स्वीकृत (Approved)'),
            Tab(text: 'अस्वीकृत/सुधार'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ThemeConfig.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_pendingList),
                _buildList(_approvedList),
                _buildList(_rejectedList),
              ],
            ),
    );
  }
}
