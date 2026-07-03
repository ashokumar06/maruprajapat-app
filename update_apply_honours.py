import re

file_path = "lib/views/honours/apply_honour_screen.dart"
with open(file_path, "r") as f:
    content = f.read()

# 1. Imports
imports = """import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../config/theme_config.dart';
import 'package:provider/provider.dart';
import '../../providers/honours_provider.dart';
import '../../services/api_client.dart';
"""
content = re.sub(r"import 'package:flutter/material.dart';.*?import '../../providers/honours_provider.dart';", imports, content, flags=re.DOTALL)

# 2. Add Edit Mode properties
edit_props = """class ApplyHonourScreen extends StatefulWidget {
  final bool isAdminOrMember;
  final bool isBhamashah;
  final BhamashahModel? editBhamashah;
  final PratibhaModel? editPratibha;
  
  const ApplyHonourScreen({
    super.key, 
    this.isAdminOrMember = false,
    this.isBhamashah = false,
    this.editBhamashah,
    this.editPratibha,
  });"""
content = re.sub(r"class ApplyHonourScreen extends StatefulWidget \{.*?\}\);", edit_props, content, flags=re.DOTALL)

# 3. Add state variables for photo upload and form keys
state_vars = """class _ApplyHonourScreenState extends State<ApplyHonourScreen> {
  int _currentStep = 0;
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  
  String? _photoUrl;
  bool _isUploading = false;
  
  bool get _isEditMode => widget.editBhamashah != null || widget.editPratibha != null;
"""
content = content.replace("class _ApplyHonourScreenState extends State<ApplyHonourScreen> {\n  int _currentStep = 0;\n  final _formKey = GlobalKey<FormState>();", state_vars)

# 4. Populate controllers if edit mode
init_state = """
  @override
  void initState() {
    super.initState();
    if (widget.editBhamashah != null) {
      _nameCtrl.text = widget.editBhamashah!.name;
      _fatherNameCtrl.text = widget.editBhamashah!.fatherHusbandName ?? '';
      _dobCtrl.text = widget.editBhamashah!.dob ?? '';
      _addressCtrl.text = widget.editBhamashah!.address ?? '';
      _districtCtrl.text = widget.editBhamashah!.district ?? '';
      _mobileCtrl.text = widget.editBhamashah!.mobileNumber ?? '';
      _emailCtrl.text = widget.editBhamashah!.email ?? '';
      _donationAmountCtrl.text = widget.editBhamashah!.donationAmount?.toString() ?? '';
      _detailsCtrl.text = widget.editBhamashah!.details ?? '';
      _photoUrl = widget.editBhamashah!.photoUrl;
    } else if (widget.editPratibha != null) {
      _nameCtrl.text = widget.editPratibha!.name;
      _fatherNameCtrl.text = widget.editPratibha!.fatherHusbandName ?? '';
      _dobCtrl.text = widget.editPratibha!.dob ?? '';
      _addressCtrl.text = widget.editPratibha!.address ?? '';
      _districtCtrl.text = widget.editPratibha!.district ?? '';
      _mobileCtrl.text = widget.editPratibha!.mobileNumber ?? '';
      _emailCtrl.text = widget.editPratibha!.email ?? '';
      _selectedCategory = widget.editPratibha!.category;
      _achievementCtrl.text = widget.editPratibha!.achievement;
      _yearCtrl.text = widget.editPratibha!.year ?? '';
      _instituteCtrl.text = widget.editPratibha!.instituteDept ?? '';
      _rankCtrl.text = widget.editPratibha!.rankPlace ?? '';
      _locationCtrl.text = widget.editPratibha!.location ?? '';
      _detailsCtrl.text = widget.editPratibha!.details ?? '';
      _photoUrl = widget.editPratibha!.photoUrl;
    }
  }
"""
content = content.replace("  final _donationAmountCtrl = TextEditingController();", "  final _donationAmountCtrl = TextEditingController();\n" + init_state)


# 5. Pick Image method
pick_image = """
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(pickedFile.path),
          'folder': 'honours',
        });
        
        final client = ApiClient().dio;
        final res = await client.post('/api/v1/upload/image', data: formData);
        
        if (res.statusCode == 200 && res.data['success'] == true) {
          setState(() {
            _photoUrl = res.data['url'];
          });
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('फोटो अपलोड हो गया!')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('फोटो अपलोड विफल रहा')));
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  void _submit() async {
"""
content = content.replace("  void _submit() async {", pick_image)


# 6. Submit logic update to use photoUrl and update endpoints
submit_logic_old = """    if (!_formKey.currentState!.validate()) return;"""
submit_logic_new = """    // Validation is done per step.
    if (_photoUrl == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया फोटो अपलोड करें')));
       return;
    }"""
content = content.replace(submit_logic_old, submit_logic_new)

payload_b = """'email': _emailCtrl.text,
        'photo_url': _photoUrl,
        'donation_amount': double.tryParse(_donationAmountCtrl.text),"""
content = content.replace("'email': _emailCtrl.text,\n        'donation_amount': double.tryParse(_donationAmountCtrl.text),", payload_b)

payload_p = """'email': _emailCtrl.text,
        'photo_url': _photoUrl,
        'category': _selectedCategory,"""
content = content.replace("'email': _emailCtrl.text,\n        'category': _selectedCategory,", payload_p)

submit_calls_old = """    if (widget.isBhamashah) {
      success = await provider.applyBhamashah({"""
submit_calls_new = """    if (widget.isBhamashah) {
      if (_isEditMode) {
        success = await provider.updateBhamashah(widget.editBhamashah!.id, {"""
content = content.replace(submit_calls_old, submit_calls_new)

submit_calls_p_old = """    } else {
      success = await provider.applyPratibha({"""
submit_calls_p_new = """      });
      } else {
        success = await provider.applyBhamashah({"""
content = content.replace("""        'details': _detailsCtrl.text,
      });
    } else {""", """        'details': _detailsCtrl.text,
      });
      }
    } else {
      if (_isEditMode) {
        success = await provider.updatePratibha(widget.editPratibha!.id, {""")

content = content.replace("""        'details': _detailsCtrl.text,
      });
    }

    if (success && mounted) {""", """        'details': _detailsCtrl.text,
      });
      } else {
        success = await provider.applyPratibha({
          'name': _nameCtrl.text,
          'father_husband_name': _fatherNameCtrl.text,
          'dob': _dobCtrl.text,
          'address': _addressCtrl.text,
          'district': _districtCtrl.text,
          'mobile_number': _mobileCtrl.text,
          'email': _emailCtrl.text,
          'photo_url': _photoUrl,
          'category': _selectedCategory,
          'achievement': _achievementCtrl.text,
          'year': _yearCtrl.text,
          'institute_dept': _instituteCtrl.text,
          'rank_place': _rankCtrl.text,
          'location': _locationCtrl.text,
          'details': _detailsCtrl.text,
        });
      }
    }

    if (success && mounted) {""")


# 7. Edit Title
appbar_title_old = """        title: Text(widget.isAdminOrMember 
          ? (widget.isBhamashah ? 'नए भामाशाह जोड़ें' : 'नई प्रतिभा जोड़ें') 
          : (widget.isBhamashah ? 'भामाशाह आवेदन' : 'प्रतिभा आवेदन')),"""
appbar_title_new = """        title: Text(_isEditMode 
          ? (widget.isBhamashah ? 'भामाशाह अपडेट करें' : 'प्रतिभा अपडेट करें') 
          : widget.isAdminOrMember 
            ? (widget.isBhamashah ? 'नए भामाशाह जोड़ें' : 'नई प्रतिभा जोड़ें') 
            : (widget.isBhamashah ? 'भामाशाह आवेदन' : 'प्रतिभा आवेदन')),"""
content = content.replace(appbar_title_old, appbar_title_new)

# 8. Step Validation logic
stepper_old = """            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                _submit();
              }
            },"""
stepper_new = """            onStepContinue: () {
              if (_currentStep == 0) {
                if (!_formKey0.currentState!.validate()) return;
              } else if (_currentStep == 1) {
                if (!_formKey1.currentState!.validate()) return;
              } else if (_currentStep == 2) {
                if (_photoUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया फोटो अपलोड करें')));
                  return;
                }
              }
              
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                _submit();
              }
            },"""
content = content.replace(stepper_old, stepper_new)

content = content.replace("child: Form(\n          key: _formKey,\n          child: Stepper(", "child: Stepper(")

# Wrap step 0 and 1 in Forms
step1_old = """  Widget _buildStep1Info() {
    return Column("""
step1_new = """  Widget _buildStep1Info() {
    return Form(
      key: _formKey0,
      child: Column("""
content = content.replace(step1_old, step1_new)
content = content.replace("        ),\n      ],\n    );\n  }\n\n  Widget _buildStep2Achievement() {", "        ),\n      ],\n    ));\n  }\n\n  Widget _buildStep2Achievement() {")


step2a_old = """  Widget _buildStep2Achievement() {
    return Column("""
step2a_new = """  Widget _buildStep2Achievement() {
    return Form(
      key: _formKey1,
      child: Column("""
content = content.replace(step2a_old, step2a_new)
content = content.replace("        ),\n      ],\n    );\n  }\n\n  Widget _buildStep2Donation() {", "        ),\n      ],\n    ));\n  }\n\n  Widget _buildStep2Donation() {")


step2b_old = """  Widget _buildStep2Donation() {
    return Column("""
step2b_new = """  Widget _buildStep2Donation() {
    return Form(
      key: _formKey1,
      child: Column("""
content = content.replace(step2b_old, step2b_new)
content = content.replace("        ),\n      ],\n    );\n  }\n\n  Widget _buildStep3Docs() {", "        ),\n      ],\n    ));\n  }\n\n  Widget _buildStep3Docs() {")


# 9. Photo upload box action
photo_box_old = """        _buildUploadBox('फोटो *', 'पासपोर्ट साइज़ फोटो'),"""
photo_box_new = """        _buildUploadBox('फोटो *', 'पासपोर्ट साइज़ फोटो', isPhoto: true),"""
content = content.replace(photo_box_old, photo_box_new)

upload_box_old = """  Widget _buildUploadBox(String title, String subtitle) {
    return Container("""
upload_box_new = """  Widget _buildUploadBox(String title, String subtitle, {bool isPhoto = false}) {
    return Container("""
content = content.replace(upload_box_old, upload_box_new)

upload_action_old = """          TextButton(
            onPressed: () {},
            child: const Text('अपलोड करें', style: TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.bold)),
          ),"""
upload_action_new = """          TextButton(
            onPressed: isPhoto ? _pickImage : () {},
            child: _isUploading && isPhoto
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_photoUrl != null && isPhoto ? 'बदलें' : 'अपलोड करें', style: const TextStyle(color: ThemeConfig.primary, fontWeight: FontWeight.bold)),
          ),"""
content = content.replace(upload_action_old, upload_action_new)

photo_preview = """        const SizedBox(height: 16),
        if (_photoUrl != null) 
           Center(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_photoUrl!, height: 120))),"""
content = content.replace("        _buildUploadBox('फोटो *', 'पासपोर्ट साइज़ फोटो', isPhoto: true),", "        _buildUploadBox('फोटो *', 'पासपोर्ट साइज़ फोटो', isPhoto: true),\n" + photo_preview)

# Review Row update
review_old = """                _buildReviewRow('नाम:', _nameCtrl.text),"""
review_new = """                if (_photoUrl != null)
                  Center(child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(_photoUrl!))),
                const SizedBox(height: 16),
                _buildReviewRow('नाम:', _nameCtrl.text),"""
content = content.replace(review_old, review_new)


with open(file_path, "w") as f:
    f.write(content)

print("Updated ApplyHonourScreen")
