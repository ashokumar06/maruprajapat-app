import 'package:flutter/material.dart';
import '../../main.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/membership_provider.dart';
import '../../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../services/api_client.dart';
import '../auth/login_screen.dart';
import "edit_profile_screen.dart";
import 'apply_membership_screen.dart';
import 'my_applications_screen.dart';
import 'app_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUserModel;
      if (user != null && user.role == 'guest') {
        context.read<MembershipProvider>().fetchMyRequests();
      }
    });
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final membershipProvider = Provider.of<MembershipProvider>(context);
    final user = authProvider.currentUserModel;
    final firebaseUser = authProvider.firebaseUser;

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'प्रोफाइल',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: ThemeConfig.textPrimary),
            onPressed: () {
              // Navigate to Settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Profile Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: ThemeConfig.border,
                    backgroundImage: (!_isUploadingPhoto && user?.profilePhotoUrl != null && user!.profilePhotoUrl.isNotEmpty)
                        ? NetworkImage(user.profilePhotoUrl)
                        : null,
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : (user?.profilePhotoUrl == null || user!.profilePhotoUrl.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Colors.white)
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingPhoto ? null : () => _pickAndUploadPhoto(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ThemeConfig.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName.isNotEmpty == true ? user!.fullName : (firebaseUser?.displayName ?? 'अतिथि'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ThemeConfig.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleName(user?.role ?? 'guest'),
                    style: const TextStyle(color: ThemeConfig.success, fontSize: 12),
                  ),
                ),
                if (user != null && user.role != 'guest') ...[
                  const SizedBox(width: 8),
                  Text(
                    'सदस्य ID: MP${user.uid.substring(0, 4).toUpperCase()}',
                    style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 12),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 16),

            // Membership application status section
            _buildMembershipSection(context, user, membershipProvider),

            // 3. Menu Items
            Material(
              color: ThemeConfig.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: ThemeConfig.divider),
              ),
              child: Column(
                children: [
                  if (user?.role == 'member' || user?.role == 'admin' || user?.role == 'superadmin') ...[
                    _buildMenuItem(Icons.edit_document, 'मेरी पोस्ट', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('आपकी पोस्ट की सूची जल्द ही उपलब्ध होगी।')),
                      );
                    }),
                    _buildMenuDivider(),
                  ],
                  _buildMenuItem(Icons.assignment_outlined, 'मेरे आवेदन', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
                    );
                  }),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.bookmark_border, 'सेव की गई पोस्ट', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('आपने अभी तक कोई पोस्ट सेव नहीं की है।')),
                    );
                  }),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.person_outline, 'मेरी जानकारी', () {
                    _showMyInfoSheet(context, user);
                  }),
                  _buildMenuDivider(),
                  _buildMenuItem(Icons.settings_outlined, 'सेटिंग्स', () {
                    _showSettingsSheet(context);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: authProvider.isLoading ? null : () => _handleLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeConfig.error,
                  side: const BorderSide(color: ThemeConfig.error),
                ),
                child: authProvider.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.error),
                        ),
                      )
                    : const Text('लॉगआउट', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'admin':
      case 'superadmin':
        return 'व्यवस्थापक';
      case 'member':
        return 'सदस्य';
      case 'guest':
      default:
        return 'अतिथि';
    }
  }

  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 50,
      );
      if (image == null) return;

      final length = await image.length();
      final fileSizeInKb = length / 1024;

      if (fileSizeInKb > 10.0) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('फ़ाइल बहुत बड़ी है (10 KB अधिकतम, चयनित: ${fileSizeInKb.toStringAsFixed(1)} KB)'),
            backgroundColor: ThemeConfig.error,
          ),
        );
        return;
      }

      setState(() => _isUploadingPhoto = true);

      final dio = ApiClient().dio;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
        'folder': 'profile_photos',
      });

      final response = await dio.post('/api/v1/upload/image', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newUrl = response.data['url'] as String;
        if (!context.mounted) return;
        await context.read<AuthProvider>().updateProfile({
          'profile_photo_url': newUrl,
        });

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('प्रोफ़ाइल फ़ोटो सफलतापूर्वक अपडेट हो गई है।'),
            backgroundColor: ThemeConfig.success,
          ),
        );
      } else {
        throw Exception('सर्वर त्रुटि code: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('फ़ोटो अपलोड करने में विफल: $e'),
          backgroundColor: ThemeConfig.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.textSecondary),
      title: Text(
        title,
        style: const TextStyle(
          color: ThemeConfig.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: ThemeConfig.textHint),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: ThemeConfig.divider,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildMembershipSection(BuildContext context, UserModel? user, MembershipProvider membershipProvider) {
    if (user == null || user.role != 'guest') {
      return const SizedBox.shrink();
    }

    if (membershipProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final request = membershipProvider.latestRequest;

    if (request == null) {
      // No application yet
      return Card(
        color: ThemeConfig.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ThemeConfig.divider),
        ),
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_membership, color: ThemeConfig.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'सदस्यता आवेदन',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'सत्यापित सदस्य बनने के लिए आवेदन करें',
                          style: TextStyle(fontSize: 12, color: ThemeConfig.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'आप अभी इस समाज के सत्यापित सदस्य नहीं हैं। समुदाय की सुविधाओं (जैसे पोस्ट करना) का उपयोग करने के लिए सदस्यता का आवेदन करें।',
                style: TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApplyMembershipScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('आवेदन करें', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (request.status == 'pending') {
      return Card(
        color: ThemeConfig.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ThemeConfig.warning),
        ),
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeConfig.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_empty, color: ThemeConfig.warning, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'आवेदन समीक्षा के अधीन है',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'सत्यापन लंबित (Pending Verification)',
                          style: TextStyle(fontSize: 12, color: ThemeConfig.warning),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'आपका सदस्यता आवेदन प्राप्त हो गया है। व्यवस्थापक (Admin) द्वारा आपके विवरण की जांच की जा रही है। कृपया कुछ समय प्रतीक्षा करें।',
                style: TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, height: 1.4),
              ),
              if (request.submittedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'जमा करने की तिथि: ${request.submittedAt!.day}/${request.submittedAt!.month}/${request.submittedAt!.year}',
                  style: const TextStyle(fontSize: 11, color: ThemeConfig.textHint),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (request.status == 'correction_needed') {
      return Card(
        color: ThemeConfig.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ThemeConfig.error),
        ),
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeConfig.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note, color: ThemeConfig.error, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'सुधार की आवश्यकता है',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'विवरण में सुधार आवश्यक है',
                          style: TextStyle(fontSize: 12, color: ThemeConfig.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'व्यवस्थापक ने आपके आवेदन में सुधार की मांग की है।\nटिप्पणी: ${request.adminNote ?? "अज्ञात"}',
                style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApplyMembershipScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('आवेदन में सुधार करें', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (request.status == 'rejected') {
      return Card(
        color: ThemeConfig.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ThemeConfig.error),
        ),
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeConfig.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, color: ThemeConfig.error, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'आवेदन अस्वीकृत',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'अस्वीकृत (Rejected)',
                          style: TextStyle(fontSize: 12, color: ThemeConfig.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'आपका सदस्यता आवेदन अस्वीकृत कर दिया गया है।\nकारण: ${request.adminNote ?? "अज्ञात"}',
                style: const TextStyle(fontSize: 12, color: ThemeConfig.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ApplyMembershipScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('पुनः आवेदन करें', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showMyInfoSheet(BuildContext context, UserModel? user) {
    if (user == null) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'मेरी जानकारी (My Profile Info)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: ThemeConfig.divider),
              const SizedBox(height: 8),
              _buildDetailRow('पूरा नाम', user.fullName.isNotEmpty ? user.fullName : 'अतिथि'),
              _buildDetailRow('पिता का नाम', user.fatherName.isNotEmpty ? user.fatherName : 'अप्राप्य'),
              _buildDetailRow('फोन नंबर', user.contactNumber.isNotEmpty ? user.contactNumber : 'अप्राप्य'),
              _buildDetailRow('गाँव', user.village.isNotEmpty ? user.village : 'अप्राप्य'),
              _buildDetailRow('जिला', user.district.isNotEmpty ? user.district : 'अप्राप्य'),
              _buildDetailRow('गोत्र', user.gotra.isNotEmpty ? user.gotra : 'अप्राप्य'),
              _buildDetailRow('भूमिका (Role)', _getRoleName(user.role)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('जानकारी संपादित करें (Edit Info)', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final currentLocale = Localizations.localeOf(context);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'भाषा चुनें / Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.language, color: ThemeConfig.primary),
                title: const Text('हिंदी (Hindi)', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: currentLocale.languageCode == 'hi' ? const Icon(Icons.check, color: ThemeConfig.success) : null,
                onTap: () {
                  MyApp.setLocale(context, const Locale('hi', ''));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.language, color: ThemeConfig.primary),
                title: const Text('English', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: currentLocale.languageCode == 'en' ? const Icon(Icons.check, color: ThemeConfig.success) : null,
                onTap: () {
                  MyApp.setLocale(context, const Locale('en', ''));
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline, color: ThemeConfig.primary),
                title: const Text('ऐप जानकारी (App Info)', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppInfoScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConfig.textPrimary, fontSize: 14)),
        ],
      ),
    );
  }
}

