import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _villageController;
  late TextEditingController _districtController;
  late TextEditingController _gotraController;
  late TextEditingController _phoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUserModel;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _fatherNameController = TextEditingController(text: user?.fatherName ?? '');
    _villageController = TextEditingController(text: user?.village ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _gotraController = TextEditingController(text: user?.gotra ?? '');
    _phoneController = TextEditingController(text: user?.contactNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _gotraController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateProfile({
        'full_name': _nameController.text.trim(),
        'father_name': _fatherNameController.text.trim(),
        'village': _villageController.text.trim(),
        'district': _districtController.text.trim(),
        'gotra': _gotraController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('प्रोफाइल सफलतापूर्वक अपडेट हो गई')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('त्रुटि: $e'), backgroundColor: ThemeConfig.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text('प्रोफाइल एडिट करें', style: TextStyle(color: ThemeConfig.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('पूरा नाम', _nameController, Icons.person, true),
              const SizedBox(height: 16),
              _buildTextField('पिता का नाम', _fatherNameController, Icons.person_outline, false),
              const SizedBox(height: 16),
              _buildTextField('फोन नंबर', _phoneController, Icons.phone, false, TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField('गाँव', _villageController, Icons.home, false),
              const SizedBox(height: 16),
              _buildTextField('जिला', _districtController, Icons.location_city, false),
              const SizedBox(height: 16),
              _buildTextField('गोत्र', _gotraController, Icons.groups, false),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('सुरक्षित करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isRequired, [TextInputType type = TextInputType.text]) {
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
