import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../config/theme_config.dart';
import '../../providers/complaint_provider.dart';
import '../../services/api_client.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _category = 'other';
  bool _isSubmitting = false;
  final List<File> _images = [];
  final _picker = ImagePicker();

  String _t(String hi, String en) {
    return Localizations.localeOf(context).languageCode == 'en' ? en : hi;
  }

  final List<Map<String, String>> _categories = [
    {'value': 'road', 'hi': 'सड़क', 'en': 'Road'},
    {'value': 'water', 'hi': 'पानी', 'en': 'Water'},
    {'value': 'electricity', 'hi': 'बिजली', 'en': 'Electricity'},
    {'value': 'sanitation', 'hi': 'स्वच्छता', 'en': 'Sanitation'},
    {'value': 'community_hall', 'hi': 'सामुदायिक भवन', 'en': 'Community Hall'},
    {'value': 'hostel', 'hi': 'छात्रावास', 'en': 'Hostel'},
    {'value': 'exam', 'hi': 'परीक्षा', 'en': 'Exam'},
    {'value': 'result', 'hi': 'परिणाम', 'en': 'Result'},
    {'value': 'app_feature', 'hi': 'ऐप फीचर', 'en': 'App Feature'},
    {'value': 'other', 'hi': 'अन्य', 'en': 'Other'},
  ];

  Future<void> _pickImages() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30, maxWidth: 600);
    if (picked != null) {
      final file = File(picked.path);
      final size = await file.length();
      if (size > 20 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t('फ़ोटो 20KB से कम होनी चाहिए', 'Photo must be under 20KB')),
          backgroundColor: ThemeConfig.error,
        ));
        return;
      }
      setState(() {
        _images.clear();
        _images.add(file);
      });
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return [];
    final dio = ApiClient().dio;
    List<String> urls = [];
    for (final img in _images) {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(img.path, filename: img.path.split('/').last),
        'folder': 'complaints',
      });
      final r = await dio.post('/api/v1/upload/image', data: formData);
      if (r.statusCode == 200 && r.data['url'] != null) {
        urls.add(r.data['url']);
      }
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      List<String> imageUrls = await _uploadImages();
      final provider = context.read<ComplaintProvider>();
      final result = await provider.submitComplaint(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        imageUrls: imageUrls.isEmpty ? null : imageUrls,
      );
      if (!mounted) return;
      if (result != null) {
        _showSuccessDialog(result.complaintNumber ?? '#${result.id}');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String msg = _t('शिकायत दर्ज करने में विफल', 'Failed to submit complaint');
      if (e.response?.statusCode == 429) {
        msg = _t('आप 7 दिनों में केवल 1 शिकायत दर्ज कर सकते हैं', 'You can only submit 1 complaint per 7 days');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: ThemeConfig.error));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('शिकायत दर्ज करने में विफल', 'Failed to submit complaint')), backgroundColor: ThemeConfig.error));
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  void _showSuccessDialog(String number) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ThemeConfig.success.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: ThemeConfig.success, size: 48),
            ),
            const SizedBox(height: 20),
            Text(_t('शिकायत दर्ज हो गई!', 'Complaint Submitted!'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(_t('आपकी शिकायत सफलतापूर्वक दर्ज कर ली गई है।\nहम जल्द से जल्द इस पर कार्यवाही करेंगे।', 'Your complaint has been submitted.\nWe will take action soon.'), textAlign: TextAlign.center, style: const TextStyle(color: ThemeConfig.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            Text(_t('शिकायत संख्या', 'Complaint Number'), style: const TextStyle(color: ThemeConfig.textHint, fontSize: 12)),
            const SizedBox(height: 4),
            Text(number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: ThemeConfig.primary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: ThemeConfig.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_t('मेरी शिकायतें देखें', 'View My Complaints'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              child: Text(_t('होम पर जाएं', 'Go Home'), style: const TextStyle(color: ThemeConfig.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: Text(_t('नई शिकायत दर्ज करें', 'New Complaint'), style: const TextStyle(color: ThemeConfig.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConfig.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Dropdown
              Text(_t('शिकायत श्रेणी *', 'Category *'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: ThemeConfig.border)),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat['value'], child: Text(isEn ? cat['en']! : cat['hi']!));
                }).toList(),
                onChanged: (v) => setState(() => _category = v ?? 'other'),
              ),
              const SizedBox(height: 20),

              // Title
              Text(_t('शिकायत का विषय *', 'Subject *'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: _t('मुख्य सड़क / पानी की समस्या...', 'Main road / water issue...'),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLength: 200,
                validator: (v) => v == null || v.trim().isEmpty ? _t('कृपया विषय लिखें', 'Please enter subject') : null,
              ),
              const SizedBox(height: 12),

              // Description
              Text(_t('विवरण *', 'Description *'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  hintText: _t('अपनी शिकायत का विस्तृत विवरण लिखें...', 'Describe your complaint in detail...'),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (v) => v == null || v.trim().isEmpty ? _t('कृपया विवरण लिखें', 'Please enter description') : null,
              ),
              const SizedBox(height: 12),

              // Location
              Text(_t('स्थान (ऐच्छिक)', 'Location (Optional)'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: _t('मुहल्ला, वार्ड नं., शहर...', 'Locality, ward no., city...'),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.location_on_outlined, color: ThemeConfig.textHint),
                ),
              ),
              const SizedBox(height: 20),

              // Photos
              Text(_t('फ़ोटो सबूत (ऐच्छिक)', 'Photo Evidence (Optional)'), style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeConfig.textPrimary)),
              const SizedBox(height: 4),
              Text(_t('JPG, PNG (केवल 1 फ़ोटो, अधिकतम 20KB)', 'JPG, PNG (only 1 photo, max 20KB)'), style: const TextStyle(color: ThemeConfig.textHint, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._images.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(entry.value, width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.removeAt(entry.key)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  if (_images.isEmpty)
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: ThemeConfig.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, color: ThemeConfig.textHint),
                            Text(_t('फ़ाइल चुनें', 'Choose'), style: const TextStyle(fontSize: 10, color: ThemeConfig.textHint)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConfig.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: ThemeConfig.primary.withValues(alpha: 0.5),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(_t('शिकायत दर्ज करें', 'Submit Complaint'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
