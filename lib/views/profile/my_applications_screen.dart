import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/membership_provider.dart';
import 'apply_membership_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null) {
        context.read<MembershipProvider>().fetchMyRequests();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membershipProvider = Provider.of<MembershipProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUserModel;

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'मेरे आवेदन',
          style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeConfig.primary,
          unselectedLabelColor: ThemeConfig.textSecondary,
          indicatorColor: ThemeConfig.primary,
          tabs: const [
            Tab(text: 'सदस्यता'),
            Tab(text: 'फ़ॉर्म'),
            Tab(text: 'सम्मान'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembershipTab(context, user, membershipProvider),
          _buildFormsTab(),
          _buildHonoursTab(),
        ],
      ),
    );
  }

  Widget _buildMembershipTab(BuildContext context, dynamic user, MembershipProvider membershipProvider) {
    if (membershipProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final request = membershipProvider.latestRequest;

    if (request == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeConfig.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_membership, size: 64, color: ThemeConfig.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'कोई सदस्यता आवेदन नहीं मिला',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'आप अभी इस समाज के सत्यापित सदस्य नहीं हैं। सदस्यता के लिए आवेदन करें।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ThemeConfig.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApplyMembershipScreen()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('आवेदन करें', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Determine status text, color, and icons
    String statusText = 'लंबित (Pending)';
    Color statusColor = ThemeConfig.warning;
    IconData statusIcon = Icons.hourglass_empty;
    String remarks = 'आपके विवरण की व्यवस्थापक (Admin) द्वारा जाँच की जा रही है।';

    if (request.status == 'approved') {
      statusText = 'स्वीकृत (Approved)';
      statusColor = ThemeConfig.success;
      statusIcon = Icons.check_circle_outline;
      remarks = 'बधाई हो! आपका सदस्यता आवेदन स्वीकृत हो गया है।';
    } else if (request.status == 'correction_needed') {
      statusText = 'सुधार आवश्यक (Correction Required)';
      statusColor = ThemeConfig.error;
      statusIcon = Icons.edit_note;
      remarks = request.adminNote ?? 'कृपया विवरण अपडेट करें।';
    } else if (request.status == 'rejected') {
      statusText = 'अस्वीकृत (Rejected)';
      statusColor = ThemeConfig.error;
      statusIcon = Icons.cancel_outlined;
      remarks = request.adminNote ?? 'आवेदन अस्वीकृत कर दिया गया है।';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: ThemeConfig.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: statusColor.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        statusText,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  _buildDetailRow('आवेदक का नाम', request.fullName),
                  _buildDetailRow('गाँव', request.village),
                  _buildDetailRow('जिला', request.district),
                  if (request.submittedAt != null)
                    _buildDetailRow(
                      'जमा तिथि',
                      '${request.submittedAt!.day}/${request.submittedAt!.month}/${request.submittedAt!.year}',
                    ),
                  const SizedBox(height: 8),
                  const Divider(color: ThemeConfig.divider),
                  const SizedBox(height: 8),
                  const Text('व्यवस्थापक की टिप्पणी:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    remarks,
                    style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          if (request.status == 'correction_needed' || request.status == 'rejected') ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplyMembershipScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                request.status == 'correction_needed' ? 'आवेदन में सुधार करें' : 'पुनः आवेदन करें',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildFormsTab() {
    // Render static history list (forms applications)
    final mockFormSubmissions = [
      {
        'title': 'ऋण योजना आवेदन फ़ॉर्म',
        'desc': 'व्यवसाय ऋण सहायता के लिए आवेदन फ़ॉर्म',
        'date': '28/06/2026',
        'status': 'प्राप्त हुआ',
        'color': ThemeConfig.info,
      },
      {
        'title': 'प्रतिभाशाली छात्र छात्रवृत्ति योजना',
        'desc': 'उच्च शिक्षा प्रोत्साहन हेतु छात्रवृत्ति फ़ॉर्म',
        'date': '15/05/2026',
        'status': 'समीक्षा जारी',
        'color': ThemeConfig.warning,
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockFormSubmissions.length,
      itemBuilder: (context, index) {
        final form = mockFormSubmissions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: ThemeConfig.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: ThemeConfig.divider),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(form['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(form['desc'] as String, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Text('जमा तिथि: ${form['date']}', style: const TextStyle(color: ThemeConfig.textHint, fontSize: 11)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (form['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                form['status'] as String,
                style: TextStyle(color: form['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHonoursTab() {
    // Render static history list (honours applications)
    final mockHonourSubmissions = [
      {
        'title': 'भामाशाह सम्मान आवेदन',
        'desc': 'समाज कल्याण निधि में योगदान देने हेतु सम्मान श्रेणी',
        'date': '10/06/2026',
        'status': 'स्वीकृत',
        'color': ThemeConfig.success,
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockHonourSubmissions.length,
      itemBuilder: (context, index) {
        final honour = mockHonourSubmissions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: ThemeConfig.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: ThemeConfig.divider),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(honour['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(honour['desc'] as String, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Text('जमा तिथि: ${honour['date']}', style: const TextStyle(color: ThemeConfig.textHint, fontSize: 11)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (honour['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                honour['status'] as String,
                style: TextStyle(color: honour['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary, fontSize: 13)),
        ],
      ),
    );
  }
}
