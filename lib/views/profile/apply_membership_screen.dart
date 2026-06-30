import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/membership_provider.dart';

class ApplyMembershipScreen extends StatefulWidget {
  const ApplyMembershipScreen({super.key});

  @override
  State<ApplyMembershipScreen> createState() => _ApplyMembershipScreenState();
}

class _ApplyMembershipScreenState extends State<ApplyMembershipScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _villageController;
  late TextEditingController _districtController;
  late TextEditingController _gotraController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;
  late TextEditingController _educationController;
  late TextEditingController _referenceController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUserModel;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _fatherNameController = TextEditingController(text: user?.fatherName ?? '');
    _motherNameController = TextEditingController();
    _villageController = TextEditingController(text: user?.village ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _gotraController = TextEditingController(text: user?.gotra ?? '');
    _phoneController = TextEditingController(text: user?.contactNumber ?? '');
    _occupationController = TextEditingController();
    _educationController = TextEditingController();
    _referenceController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _gotraController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthProvider>().currentUserModel;
      final success = await context.read<MembershipProvider>().applyForMembership({
        'full_name': _fullNameController.text.trim(),
        'father_name': _fatherNameController.text.trim(),
        'mother_name': _motherNameController.text.trim(),
        'village': _villageController.text.trim(),
        'district': _districtController.text.trim(),
        'gotra': _gotraController.text.trim(),
        'contact_number': _phoneController.text.trim(),
        'occupation': _occupationController.text.trim().isEmpty ? null : _occupationController.text.trim(),
        'education': _educationController.text.trim().isEmpty ? null : _educationController.text.trim(),
        'reference_person': _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
        'profile_photo_url': user?.profilePhotoUrl ?? '',
        'aadhaar_front_url': null,
        'aadhaar_back_url': null,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('सदस्यता आवेदन सफलतापूर्वक जमा हो गया है। व्यवस्थापक द्वारा समीक्षा की जाएगी।'),
            backgroundColor: ThemeConfig.success,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        final errorMsg = context.read<MembershipProvider>().error ?? 'आवेदन जमा करने में विफल रहा।';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('त्रुटि: $e'),
            backgroundColor: ThemeConfig.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'सदस्यता के लिए आवेदन',
          style: TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeConfig.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ThemeConfig.primary.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: ThemeConfig.primary, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'कृपया सभी जानकारी सही भरें। आपके विवरण की व्यवस्थापक (Admin) द्वारा जाँच की जाएगी, जिसके बाद आपकी सदस्यता स्वीकृत की जाएगी।',
                        style: TextStyle(
                          color: ThemeConfig.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'व्यक्तिगत विवरण',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField('पूरा नाम (Full Name) *', _fullNameController, Icons.person, true),
              const SizedBox(height: 16),
              _buildTextField('पिता का नाम (Father\'s Name) *', _fatherNameController, Icons.person_outline, true),
              const SizedBox(height: 16),
              _buildTextField('माता का नाम (Mother\'s Name) *', _motherNameController, Icons.person_outline, true),
              const SizedBox(height: 16),
              _buildTextField('फोन नंबर (Phone Number) *', _phoneController, Icons.phone, true, TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('गोत्र (Gotra) *', _gotraController, Icons.groups_outlined, true),

              const SizedBox(height: 24),
              Text(
                'पता (Address)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField('गाँव (Village) *', _villageController, Icons.home_outlined, true),
              const SizedBox(height: 16),
              _buildTextField('जिला (District) *', _districtController, Icons.location_city_outlined, true),

              const SizedBox(height: 24),
              Text(
                'अन्य विवरण (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField('व्यवसाय (Occupation)', _occupationController, Icons.work_outline, false),
              const SizedBox(height: 16),
              _buildTextField('शिक्षा (Education)', _educationController, Icons.school_outlined, false),
              const SizedBox(height: 16),
              _buildTextField('संदर्भ व्यक्ति (Reference Person) — समाज का कोई सदस्य', _referenceController, Icons.handshake_outlined, false),

              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'आवेदन जमा करें',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isRequired, [
    TextInputType type = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ThemeConfig.textHint),
        filled: true,
        fillColor: ThemeConfig.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label अनिवार्य है';
        }
        return null;
      },
    );
  }
}
