import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final Set<int> _expandedCardIds = {};
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
      final response = await client.get('/api/v1/memberships/', queryParameters: {'per_page': 50});

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
        final isEnglish = Localizations.localeOf(context).languageCode == 'en';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnglish ? 'Failed to load approval list' : 'अनुमोदन सूची लोड करने में विफल'),
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

  Future<void> _reviewApplication(int id, String status, String? note, bool isEnglish) async {
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
            SnackBar(
              content: Text(isEnglish ? 'Application updated successfully' : 'आवेदन सफलतापूर्वक अपडेट कर दिया गया'),
              backgroundColor: ThemeConfig.success,
            ),
          );
        }
        await _fetchRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnglish ? 'Failed to update application' : 'आवेदन अपडेट करने में विफल'),
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

  void _showReviewDialog(int id, String status, bool isEnglish) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        if (status == 'approved') {
          title = isEnglish ? 'Approve Application' : 'आवेदन स्वीकार करें';
        } else if (status == 'rejected') {
          title = isEnglish ? 'Reject Application' : 'आवेदन अस्वीकार करें';
        } else {
          title = isEnglish ? 'Request Correction' : 'सुधार के लिए भेजें';
        }

        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: isEnglish ? 'Enter note (optional)...' : 'टिप्पणी दर्ज करें (वैकल्पिक)...',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isEnglish ? 'Cancel' : 'रद्द करें'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _reviewApplication(
                  id, 
                  status, 
                  noteController.text.trim().isNotEmpty ? noteController.text.trim() : null, 
                  isEnglish
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'approved' ? ThemeConfig.success : ThemeConfig.error,
              ),
              child: Text(isEnglish ? 'Confirm' : 'पुष्टि करें', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ThemeConfig.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              style: const TextStyle(
                fontSize: 13,
                color: ThemeConfig.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(String label, String? url, bool isEnglish) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return OutlinedButton.icon(
      icon: const Icon(Icons.file_present, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEnglish ? 'Could not open document' : 'दस्तावेज़ खोलने में असमर्थ'),
                backgroundColor: ThemeConfig.error,
              ),
            );
          }
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConfig.primary,
        side: const BorderSide(color: ThemeConfig.primary, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: const Size(100, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildList(List<dynamic> list, bool isEnglish) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isEnglish ? 'No applications found.' : 'कोई आवेदन नहीं मिला।',
          style: const TextStyle(color: ThemeConfig.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final req = list[index];
        final id = req['id'];
        final isExpanded = _expandedCardIds.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: ThemeConfig.surface,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: ThemeConfig.border.withOpacity(0.5)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: PageStorageKey(id),
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  if (expanded) {
                    _expandedCardIds.add(id);
                  } else {
                    _expandedCardIds.remove(id);
                  }
                });
              },
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: ThemeConfig.primaryLight.withOpacity(0.3),
                backgroundImage: (req['profile_photo_url'] != null &&
                        req['profile_photo_url'].toString().isNotEmpty)
                    ? NetworkImage(req['profile_photo_url'])
                    : null,
                child: (req['profile_photo_url'] == null ||
                        req['profile_photo_url'].toString().isEmpty)
                    ? const Icon(Icons.person, color: ThemeConfig.primary)
                    : null,
              ),
              title: Text(
                req['full_name'] ?? (isEnglish ? 'Unknown' : 'अज्ञात'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.textPrimary,
                ),
              ),
              subtitle: Text(
                '${isEnglish ? "Location" : "स्थान"}: ${req['village'] ?? ''}, ${req['district'] ?? ''}',
                style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusBadge(req['status'], isEnglish),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: ThemeConfig.textSecondary,
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: ThemeConfig.divider),
                      const SizedBox(height: 12),
                      
                      // User Details Grid
                      _buildDetailRow(isEnglish ? "Father's Name" : "पिता का नाम", req['father_name']),
                      _buildDetailRow(isEnglish ? "Mother's Name" : "माता का नाम", req['mother_name']),
                      _buildDetailRow(isEnglish ? "Gotra" : "गोत्र", req['gotra']),
                      _buildDetailRow(isEnglish ? "Phone Number" : "मोबाइल नंबर", req['contact_number']),
                      _buildDetailRow(isEnglish ? "Occupation" : "व्यवसाय", req['occupation']),
                      _buildDetailRow(isEnglish ? "Education" : "शिक्षा", req['education']),
                      _buildDetailRow(isEnglish ? "Reference Person" : "संदर्भ व्यक्ति", req['reference_person']),

                      // Documents Row
                      if ((req['aadhaar_front_url'] != null && req['aadhaar_front_url'].toString().isNotEmpty) ||
                          (req['aadhaar_back_url'] != null && req['aadhaar_back_url'].toString().isNotEmpty)) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildDocumentButton(
                              isEnglish ? "Aadhaar Front" : "आधार फ्रंट", 
                              req['aadhaar_front_url'], 
                              isEnglish
                            ),
                            _buildDocumentButton(
                              isEnglish ? "Aadhaar Back" : "आधार बैक", 
                              req['aadhaar_back_url'], 
                              isEnglish
                            ),
                          ],
                        ),
                      ],

                      if (req['admin_note'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ThemeConfig.error.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ThemeConfig.error.withOpacity(0.15)),
                          ),
                          child: Text(
                            '${isEnglish ? "Admin Note" : "एडमिन टिप्पणी"}: ${req['admin_note']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: ThemeConfig.error,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],

                      if (req['status'] == 'pending') ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: ThemeConfig.divider),
                        const SizedBox(height: 12),
                        
                        // Smaller, Clean Buttons
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => _showReviewDialog(id, 'correction_needed', isEnglish),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeConfig.primary,
                                side: const BorderSide(color: ThemeConfig.primary, width: 1.2),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(80, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(isEnglish ? 'Correction' : 'सुधार आवश्यक'),
                            ),
                            OutlinedButton(
                              onPressed: () => _showReviewDialog(id, 'rejected', isEnglish),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeConfig.error,
                                side: const BorderSide(color: ThemeConfig.error, width: 1.2),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(80, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(isEnglish ? 'Reject' : 'अस्वीकार करें'),
                            ),
                            ElevatedButton(
                              onPressed: () => _showReviewDialog(id, 'approved', isEnglish),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeConfig.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: const Size(80, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                elevation: 1,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(isEnglish ? 'Approve' : 'स्वीकार करें'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status, bool isEnglish) {
    Color color = Colors.orange;
    String label = isEnglish ? "Pending" : "लंबित";
    if (status == 'approved') {
      color = ThemeConfig.success;
      label = isEnglish ? "Approved" : "स्वीकृत";
    } else if (status == 'rejected') {
      color = ThemeConfig.error;
      label = isEnglish ? "Rejected" : "अस्वीकृत";
    } else if (status == 'correction_needed') {
      color = Colors.blue;
      label = isEnglish ? "Correction" : "सुधार आवश्यक";
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
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Membership Approvals' : 'सदस्यता अनुमोदन', 
          style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.primary,
          unselectedLabelColor: ThemeConfig.textSecondary,
          indicatorColor: ThemeConfig.primary,
          tabs: [
            Tab(text: isEnglish ? 'Pending' : 'लंबित'),
            Tab(text: isEnglish ? 'Approved' : 'स्वीकृत'),
            Tab(text: isEnglish ? 'Rejected/Correction' : 'अस्वीकार/सुधार'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ThemeConfig.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_pendingList, isEnglish),
                _buildList(_approvedList, isEnglish),
                _buildList(_rejectedList, isEnglish),
              ],
            ),
    );
  }
}
